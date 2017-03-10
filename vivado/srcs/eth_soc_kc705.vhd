-----------------------------------------------------------------------------
--! @file
--! @copyright  Copyright 2015 GNSS Sensor Ltd. All right reserved.
--! @author     Sergey Khabarov
--! @brief      Network on Chip design top level.
--! @details    RISC-V "Rocket Core" based system with the AMBA AXI4 (NASTI) 
--!             system bus and integrated peripheries.
------------------------------------------------------------------------------
--! Standard library
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library techmap;
use techmap.gencomp.all;
use techmap.types_mem.all;

--! Data transformation and math functions library
library commonlib;
use commonlib.types_common.all;

--! Technology definition library.
library techmap;
--! Technology constants definition.
use techmap.gencomp.all;
--! "Virtual" PLL declaration.
use techmap.types_pll.all;
--! "Virtual" buffers declaration.
use techmap.types_buf.all;

--! AMBA system bus specific library
library ambalib;
--! AXI4 configuration constants.
use ambalib.types_amba4.all;

--! Rocket-chip specific library
library rocketlib;
--! SOC top-level component declaration.
use rocketlib.types_rocket.all;
--! Ethernet related declarations.
use rocketlib.grethpkg.all;

 --! Top-level implementaion library
library work;
--! Target dependable configuration: RTL, FPGA or ASIC.
use work.config_target.all;
--! Target independable configuration.
use work.config_common.all;

--! @brief   SOC Top-level entity declaration.
--! @details This module implements full SOC functionality and all IO signals
--!          are available on FPGA/ASIC IO pins.
entity eth_soc is port 
( 
  --! Input reset. Active High. Usually assigned to button "Center".
  i_rst       : in std_logic;
  clkb    : in  std_ulogic;
  addrb   : in  std_logic_vector(13 downto 0);
  dob     : out std_logic_vector(127 downto 0);
  web     : in  std_logic;
  dib     : in  std_logic_vector(127 downto 0);
  enb     : in  std_logic_vector(127 downto 0);
  o_erefclk   : out   std_ulogic; -- RMII clock out
  i_gmiiclk_p : in    std_ulogic; -- GMII clock in
  i_gmiiclk_n : in    std_ulogic;
  o_egtx_clk  : out   std_ulogic;
  i_etx_clk   : in    std_ulogic;
  i_erx_clk   : in    std_ulogic;
  i_erxd      : in    std_logic_vector(3 downto 0);
  i_erx_dv    : in    std_ulogic;
  i_erx_er    : in    std_ulogic;
  i_erx_col   : in    std_ulogic;
  i_erx_crs   : in    std_ulogic;
  i_emdint    : in    std_ulogic;
  o_etxd      : out   std_logic_vector(3 downto 0);
  o_etx_en    : out   std_ulogic;
  o_etx_er    : out   std_ulogic;
  o_emdc      : out   std_ulogic;
  io_emdio    : inout std_logic;
  o_erstn     : out   std_ulogic;
  wPllLocked  : in std_ulogic; -- PLL status signal. 0=Unlocked; 1=locked.
  i_clk50_quad : in std_ulogic;
  i_clk50    : in std_ulogic
);
  --! @}

end eth_soc;

--! @brief SOC top-level  architecture declaration.
architecture arch_eth_soc of eth_soc is

  --! @name Buffered in/out signals.
  --! @details All signals that are connected with in/out pads must be passed
  --!          through the dedicated buffere modules. For FPGA they are implemented
  --!          as an empty devices but ASIC couldn't be made without buffering.
  --! @{
  signal ib_gmiiclk : std_logic;
  --! @}

  signal wSysReset  : std_ulogic; -- Internal system reset. MUST NOT USED BY DEVICES.
  signal wReset     : std_ulogic; -- Global reset active HIGH
  signal wNReset    : std_ulogic; -- Global reset active LOW
  signal soft_rst   : std_logic; -- reset from exteranl debugger
  signal bus_nrst   : std_ulogic; -- Global reset and Soft Reset active LOW
  signal wClkBus    : std_ulogic; -- bus clock from the internal PLL (100MHz virtex6/40MHz Spartan6)

  signal aximi   : nasti_master_in_type;
  signal aximo   : nasti_master_out_type;
  signal axisi   : nasti_slave_in_type;
  signal axiso   : nasti_slave_out_type;

  signal eth_i : eth_in_type;
  signal eth_o : eth_out_type;

  constant xconfig : nasti_slave_config_type := (
     xindex => 0,
     xaddr => conv_std_logic_vector(16#00000#, CFG_NASTI_CFG_ADDR_BITS),
     xmask => conv_std_logic_vector(16#00000#, CFG_NASTI_CFG_ADDR_BITS),
     vid => VENDOR_GNSSSENSOR,
     did => GNSSSENSOR_SRAM,
     descrtype => PNP_CFG_TYPE_SLAVE,
     descrsize => PNP_CFG_SLAVE_DESCR_BYTES
  );

  type registers is record
    bank_axi : nasti_slave_bank_type;
  end record;
  
  type ram_in_type is record
    raddr : global_addr_array_type;
    waddr : global_addr_array_type;
    we    : std_logic;
    wstrb : std_logic_vector(CFG_NASTI_DATA_BYTES-1 downto 0);
    wdata : std_logic_vector(CFG_NASTI_DATA_BITS-1 downto 0);
  end record;

signal r, rin : registers;

signal rdata_mux : std_logic_vector(CFG_NASTI_DATA_BITS-1 downto 0);
signal rami : ram_in_type;

signal    clk  : std_logic;
signal    nrst : std_logic;
signal    cfg  : nasti_slave_config_type;
signal    i    : nasti_slave_in_type;
signal    o    : nasti_slave_out_type;

--! reduced name of configuration constant:
constant dw : integer := CFG_NASTI_ADDR_OFFSET;
constant abits : integer := 16;

type local_addr_type is array (0 to CFG_NASTI_DATA_BYTES-1) of
   std_logic_vector(abits-dw-1 downto 0);

signal address : local_addr_type;
signal wr_ena : std_logic_vector(CFG_NASTI_DATA_BYTES-1 downto 0);

  constant MSTZERO : std_logic := '0';

 component sram8_xilinx is
    port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector(13 downto 0);
    rdata   : out std_logic_vector(7 downto 0);
    we      : in  std_logic;
    wdata   : in  std_logic_vector(7 downto 0);
    clkb    : in  std_ulogic;
    addrb   : in  std_logic_vector(13 downto 0);
    dob     : out std_logic_vector(7 downto 0);
    web     : in  std_logic;
    dib     : in  std_logic_vector(7 downto 0);
    enb     : in  std_logic_vector(7 downto 0)
    );
  end component;

begin

    aximi.grant    <= aximo.ar_valid or aximo.aw_valid;
    aximi.aw_ready <= axiso.aw_ready;
    aximi.w_ready  <= axiso.w_ready;
    aximi.b_valid  <= axiso.b_valid;
    aximi.b_resp   <= axiso.b_resp;
    aximi.b_id     <= axiso.b_id;
    aximi.b_user   <= axiso.b_user;
    aximi.ar_ready <= axiso.ar_ready;
    aximi.r_valid  <= axiso.r_valid;
    aximi.r_resp   <= axiso.r_resp;
    aximi.r_data   <= axiso.r_data;
    aximi.r_last   <= axiso.r_last;
    aximi.r_id     <= axiso.r_id;
    aximi.r_user   <= axiso.r_user;

    axisi.aw_valid <= aximo.aw_valid;
    axisi.aw_bits  <= aximo.aw_bits;
    axisi.aw_id    <= aximo.aw_id;
    axisi.aw_user  <= aximo.aw_user;
    axisi.w_valid  <= aximo.w_valid;
    axisi.w_data   <= aximo.w_data;
    axisi.w_last   <= aximo.w_last;
    axisi.w_strb   <= aximo.w_strb;
    axisi.w_user   <= aximo.w_user;
    axisi.b_ready  <= aximo.b_ready;
    axisi.ar_valid <= aximo.ar_valid;
    axisi.ar_bits  <= aximo.ar_bits;
    axisi.ar_id    <= aximo.ar_id;
    axisi.ar_user  <= aximo.ar_user;
    axisi.r_ready  <= aximo.r_ready;

clk <= wClkBus;
nrst <= wNReset;
--cfg <= slv_cfg(CFG_NASTI_SLAVE_SRAM);
i <= axisi;
axiso <= o;

  diffclk: if CFG_RMII = 0 generate 
  igbebuf0 : igdsbuf_tech generic map (CFG_PADTECH) port map (
            i_gmiiclk_p, i_gmiiclk_n, ib_gmiiclk);
  end generate;

wClkBus <= i_clk50;
o_erefclk <= i_clk50_quad;
eth_i.rmii_clk <= i_clk50; 
wSysReset <= i_rst or not wPllLocked;

  ------------------------------------
  --! @brief System Reset device instance.
  rst0 : reset_global port map (
    inSysReset  => wSysReset,
    inSysClk    => wClkBus,
    inPllLock   => wPllLocked,
    outReset    => wReset
  );
  wNReset <= not wReset;
  bus_nrst <= not (wReset or soft_rst);

  --! @brief Ethernet MAC with the AXI4 interface.
  --! @details Map address:
  --!          0x80040000..0x8007ffff (256 KB total)
  --!          EDCL IP: 192.168.0.51 = C0.A8.00.33
  eth0_rmii_ena1 : if CFG_RMII = 1 generate 
    eth_i.rx_crs <= i_erx_dv;
  end generate;
  eth0_rmii_ena0 : if CFG_RMII = 0 generate -- plain MII
    eth_i.rx_dv <= i_erx_dv;
    eth_i.rx_crs <= i_erx_crs;
  end generate;

    eth_i.tx_clk <= i_etx_clk;
    eth_i.rx_clk <= i_erx_clk;
    eth_i.rx_er <= i_erx_er;
    eth_i.rx_col <= i_erx_col;
    eth_i.rxd <= i_erxd;
    eth_i.mdint <= i_emdint;

    mac0 : grethaxi generic map (
      xslvindex => 0,
      xmstindex => 0,
      xaddr => 16#FFFFF#,
      xmask => 16#FFFFF#,
      xirq => 0,
      memtech => CFG_MEMTECH,
      mdcscaler => 50,  --! System Bus clock in MHz
      enable_mdio => 1,
      fifosize => 16,
      nsync => 1,
      edcl => 1,
      edclbufsz => 16,
      macaddrh => 16#20789#,
      macaddrl => 16#123#,
      ipaddrh => 16#C0A8#,
      ipaddrl => 16#0033#,
      phyrstadr => 7,
      enable_mdint => 1,
      maxsize => 1518,
      rmii => CFG_RMII
   ) port map (
      rst => wNReset,
      clk => wClkBus,
      msti => aximi,
      msto => aximo,
      mstcfg => open, -- mst_cfg(CFG_NASTI_MASTER_ETHMAC),
      msto2 => open,    -- EDCL separate access is disabled
      mstcfg2 => open,  -- EDCL separate access is disabled
      slvi => axisi,
      slvo => open,
      slvcfg => open,
      ethi => eth_i,
      etho => eth_o,
      irq => open
    );
 
  emdio_pad : iobuf_tech generic map(
      CFG_PADTECH
  ) port map (
      o  => eth_i.mdio_i,
      io => io_emdio,
      i  => eth_o.mdio_o,
      t  => eth_o.mdio_oe
  );
  o_egtx_clk <= eth_i.gtx_clk;--eth_i.tx_clk_90;
  o_etxd <= eth_o.txd;
  o_etx_en <= eth_o.tx_en;
  o_etx_er <= eth_o.tx_er;
  o_emdc <= eth_o.mdc;
  o_erstn <= wNReset;


  comblogic : process(i, r, rdata_mux)
    variable v : registers;
    variable vrami : ram_in_type;
    variable rdata : std_logic_vector(CFG_NASTI_DATA_BITS-1 downto 0);
  begin

    v := r;

    procedureAxi4(i, xconfig, r.bank_axi, v.bank_axi);
    
    vrami.raddr := functionAddressReorder(v.bank_axi.raddr(0)(3 downto 2),
                                          v.bank_axi.raddr);

    vrami.we := '0';
    if (i.w_valid = '1' and r.bank_axi.wstate = wtrans 
        and r.bank_axi.wresp = NASTI_RESP_OKAY) then
      vrami.we := '1';
    end if;

    procedureWriteReorder(vrami.we,
                          r.bank_axi.waddr(0)(3 downto 2),
                          r.bank_axi.waddr,
                          i.w_strb,
                          i.w_data,
                          vrami.waddr,
                          vrami.wstrb,
                          vrami.wdata);

    rdata := functionDataRestoreOrder(r.bank_axi.raddr(0)(3 downto 2),
                                      rdata_mux);

    o <= functionAxi4Output(r.bank_axi, rdata);
    
    rami <= vrami;
    rin <= v;
  end process;

  cfg  <= xconfig;
  
  -- registers:
  regs : process(clk, nrst)
  begin 
     if nrst = '0' then
        r.bank_axi <= NASTI_SLAVE_BANK_RESET;
     elsif rising_edge(clk) then 
        r <= rin;
     end if; 
  end process;

    rx : for n in 0 to CFG_NASTI_DATA_BYTES-1 generate

      wr_ena(n) <= rami.we and rami.wstrb(n);
      address(n) <= rami.waddr(n / CFG_ALIGN_BYTES)(abits-1 downto dw) when rami.we = '1'
                else rami.raddr(n / CFG_ALIGN_BYTES)(abits-1 downto dw);

      x0 : sram8_xilinx port map (
          clk, 
          address => '0' & '0' & address(n),
          rdata => rdata_mux(8*(n+1)-1 downto 8*n),
          we => wr_ena(n), 
          wdata => rami.wdata(8*(n+1)-1 downto 8*n),
          clkb => clkb,
          addrb => addrb,
          dob => dob(8*(n+1)-1 downto 8*n),
          web => web,
          dib => dib(8*(n+1)-1 downto 8*n),
          enb => enb(8*(n+1)-1 downto 8*n)
      );
      
    end generate; -- cycle
 
end arch_eth_soc;
