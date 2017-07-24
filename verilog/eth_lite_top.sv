// See LICENSE for license details.
`default_nettype none

module eth_top
  (
  //! LEDs.
output reg [15:0] o_led,
input wire  [7:0] i_dip,

  //! Ethernet MAC PHY interface signals
output wire   o_erefclk     , // RMII clock out
input wire [1:0] i_erxd    ,
input wire  i_erx_dv       ,
input wire  i_erx_er       ,
input wire  i_emdint       ,
output reg  [1:0] o_etxd   ,
output wire   o_etx_en      ,
output wire   o_emdc        ,
inout wire  io_emdio   ,
output wire   o_erstn    ,   
   
   // clock and reset
   input wire         clk_p,
   input wire         clk_n,
   input wire         rst_top,
   
   output wire 	     uart_tx,
   input wire        uart_rx,
   output wire       uart_rts,
   input wire        uart_cts,

   output wire 	     sd_sclk,
   input wire        sd_detect,
   inout wire [3:0]  sd_dat,
   inout wire        sd_cmd,
   output reg        sd_reset,
// pusb button array
input wire GPIO_SW_C,
input wire GPIO_SW_W,
input wire GPIO_SW_E,
input wire GPIO_SW_N,
input wire GPIO_SW_S,
//keyboard
inout wire PS2_CLK,
inout wire PS2_DATA,

  // display
output wire           VGA_HS_O,
output wire           VGA_VS_O,
output wire  [3:0]    VGA_RED_O,
output wire  [3:0]    VGA_BLUE_O,
output wire  [3:0]    VGA_GREEN_O,

   output wire       CA,
   output wire       CB,
   output wire       CC,
   output wire       CD,
   output wire       CE,
   output wire       CF,
   output wire       CG,
   output wire       DP,
   output wire [7:0] AN,

   output reg   redled
   );

logic clk_locked, clk_200MHz, msoc_clk, i_clk50, i_clk50_quad, clk_100;
logic [31:0] core_lsu_addr;
logic [31:0] core_lsu_addr_dly;
logic [31:0] core_lsu_wdata;
logic [3:0] core_lsu_be;
logic        ce_d, ce_d_dly;
logic        we_d;
logic     tap_sel;
logic [3:0] tap_rdata_pa;   
logic [31:0] tap_rdata, tap_rdata_pkt, tap_wdata_pkt, rx_fcs_o, tx_fcs_o;
logic pxl_clk, tx_enable_i, tx_byte_sent_o, tx_busy_o, rx_frame_o, rx_byte_received_o, rx_error_o;
logic mac_tx_enable, mac_tx_gap, mac_tx_byte_sent, mac_rx_frame, mac_rx_byte_received, mac_rx_error;
logic [47:0] mac_address;
logic  [7:0] rx_data_o1, rx_data_o2, rx_data_o3, rx_data_o, tx_data_i, mac_tx_data, mac_rx_data, mii_rx_data_i;
logic [10:0] rx_frame_size_o, tx_frame_addr, rx_packet_length_o;   
logic [15:0] tx_packet_length, tx_frame_size, o_led_unbuf, i_dip_reg;
reg [12:0] addr_tap, nxt_addr;
reg [23:0] rx_byte, rx_nxt, rx_byte_dly;
reg  [2:0] rx_pair;
reg        mii_rx_byte_received_i, full, byte_sync, mii_rx_frame_i, rx_frame_old, rx_pa;
   // datamem shared port
   logic [3:0] 	sharedmem_en;
   logic [31:0] sharedmem_dout;
   logic [31:0] shared_rdata;
   logic        shared_sel;

// datamem shared port
   logic [0:0] 	datamem_web;
   logic [3:0] 	datamem_enb;
   logic [31:0] datamem_doutb;
  
   // progmem shared port
   logic [0:0] 	progmem_web;
   logic [3:0] 	progmem_enb;
   logic [31:0] progmem_doutb;

   logic     debug_req;
   logic     debug_gnt;
   logic     debug_rvalid;
   logic [31:0] debug_addr;
   logic 	debug_we;
   logic [31:0] debug_wdata;
   logic [31:0] debug_rdata;
   logic        debug_reset;
   logic        debug_runtest;
   logic        debug_halt;
   logic        debug_halted;
   logic        debug_resume;
   logic        debug_clk, debug_clk2, debug_blocksel;
   logic [2:0]  debug_unused;
   
   logic [31:0] core_instr_rdata, debug_dout;

    always @*
        begin      
        progmem_enb = 4'h0; datamem_enb = 4'h0; sharedmem_en = 4'h0; debug_blocksel = 1'b0;
        casez(debug_addr[23:20])
            4'h0: begin progmem_enb = 4'hf; debug_dout = progmem_doutb; end
            4'h1: begin datamem_enb = 4'hf; debug_dout = datamem_doutb; end
            4'h8: begin sharedmem_en = 4'hf; debug_dout = sharedmem_dout; end
            4'hf: begin debug_blocksel = &debug_addr[31:24]; debug_dout = debug_rdata; end
            default: debug_dout = 32'hDEADBEEF;
            endcase
        end
        
jtag_dummy jtag1(
    .DBG({debug_unused[2:0],debug_halt,debug_resume,debug_req}),
    .WREN(debug_we),
    .FROM_MEM(debug_dout),
    .ADDR(debug_addr),
    .TO_MEM(debug_wdata),
    .TCK(debug_clk),
    .TCK2(debug_clk2),
    .RESET(debug_reset),
    .RUNTEST(debug_runtest));

   genvar r;

   wire [3:0] m_enb = (we_d ? core_lsu_be : 4'hF);
   wire m_web = ce_d & shared_sel & we_d;
   logic i_emdio, o_emdio, oe_emdio, o_emdclk, sync, cooked, tx_enable_old, loopback, loopback2;
   logic [1:0] data_dly;   
   logic [10:0] rx_addr;
   logic [7:0] rx_data;
   logic rx_ena, rx_wea;

   generate for (r = 0; r < 4; r=r+1)
     RAMB16_S9_S9
     RAMB16_S9_S9_inst
       (
        .CLKA   ( debug_clk                ),     // Port A Clock
        .DOA    ( sharedmem_dout[r*8 +: 8] ),     // Port A 1-bit Data Output
        .ADDRA  ( debug_addr[12:2]         ),     // Port A 14-bit Address Input
        .DIA    ( debug_wdata[r*8 +:8]     ),     // Port A 1-bit Data Input
        .ENA    ( sharedmem_en[r]          ),     // Port A RAM Enable Input
        .SSRA   ( 1'b0                     ),     // Port A Synchronous Set/Reset Input
        .WEA    ( debug_we                 ),     // Port A Write Enable Input
        .CLKB   ( msoc_clk                 ),     // Port B Clock
        .DOB    ( shared_rdata[r*8 +: 8]   ),     // Port B 1-bit Data Output
        .ADDRB  ( core_lsu_addr[12:2]      ),     // Port B 14-bit Address Input
        .DIB    ( core_lsu_wdata[r*8 +: 8] ),     // Port B 1-bit Data Input
        .ENB    ( m_enb[r]                 ),     // Port B RAM Enable Input
        .SSRB   ( 1'b0                     ),     // Port B Synchronous Set/Reset Input
        .WEB    ( m_web                    )      // Port B Write Enable Input
        );
   endgenerate

wire  [31 : 0] eth_axi_awaddr;
wire  [2 : 0]  eth_axi_awprot;
wire 	       eth_axi_awvalid;
wire  [31 : 0] eth_axi_wdata;
wire  [3 : 0]  eth_axi_wstrb;
wire 	       eth_axi_wvalid;
wire 	       eth_axi_bready;
wire  [31 : 0] eth_axi_araddr;
wire 	       eth_axi_arvalid;
wire 	       eth_axi_rready;
   
wire  [31 : 0] s_axi_awaddr = eth_axi_awaddr;
wire  [2 : 0]  s_axi_awprot = eth_axi_awprot;
wire 	       s_axi_awvalid = eth_axi_awvalid;
   wire        s_axi_awready;
wire  [31 : 0] s_axi_wdata = eth_axi_wdata;
wire  [3 : 0]  s_axi_wstrb = eth_axi_wstrb;
wire 	       s_axi_wvalid = eth_axi_wvalid;
   wire        s_axi_wready;
   wire [1 : 0] s_axi_bresp;
   wire 	s_axi_bvalid;
wire 	       s_axi_bready = eth_axi_bready;
wire  [31 : 0] s_axi_araddr = eth_axi_araddr;
wire 	       s_axi_arvalid = eth_axi_arvalid;
   wire        s_axi_arready;
   wire [31 : 0] s_axi_rdata;
   wire 	 s_axi_rvalid;
   wire [1 : 0]  s_axi_rresp;
wire 	       s_axi_rready = eth_axi_rready;
   wire        s_axi_aclk = msoc_clk;
   wire        s_axi_aresetn;
   
wire 	       eth_axi_awready = s_axi_awready;
wire 	       eth_axi_wready = s_axi_wready;
wire [1 : 0]   eth_axi_bresp = s_axi_bresp;
wire 	       eth_axi_bvalid = s_axi_bvalid;
wire 	       eth_axi_arready = s_axi_arready;
wire [31 : 0]  eth_axi_rdata = s_axi_rdata;
wire 	       eth_axi_rvalid = s_axi_rvalid;
wire [1 : 0]   eth_axi_rresp = s_axi_rresp;

wire 	       m_axi_lite_ch1_awready = s_axi_awready;
wire 	       m_axi_lite_ch1_wready = s_axi_wready;
wire [1 : 0]   m_axi_lite_ch1_bresp = s_axi_bresp;
wire 	       m_axi_lite_ch1_bvalid = s_axi_bvalid;
wire 	       m_axi_lite_ch1_arready = s_axi_arready;
wire [31 : 0]  m_axi_lite_ch1_rdata = s_axi_rdata;
wire 	       m_axi_lite_ch1_rvalid = s_axi_rvalid;
wire [1 : 0]   m_axi_lite_ch1_rresp = s_axi_rresp;
wire io_emdio_i, phy_emdio_o, phy_emdio_t;
reg phy_emdio_i, io_emdio_o, io_emdio_t;

assign o_erstn = clk_locked;

always @(posedge i_clk50)
    begin
    phy_emdio_i <= io_emdio_i;
    io_emdio_o <= phy_emdio_o;
    io_emdio_t <= phy_emdio_t;
    o_led <= o_led_unbuf;
    i_dip_reg <= i_dip;
    end

   IOBUF #(
      .DRIVE(12), // Specify the output drive strength
      .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE" 
      .IOSTANDARD("DEFAULT"), // Specify the I/O standard
      .SLEW("SLOW") // Specify the output slew rate
   ) IOBUF_inst (
      .O(io_emdio_i),     // Buffer output
      .IO(io_emdio),   // Buffer inout port (connect directly to top-level port)
      .I(io_emdio_o),     // Buffer input
      .T(io_emdio_t)      // 3-state enable input, high=input, low=output
   );
       
mii_to_rmii_0_exdes EXDES (
	.clk_50      ( i_clk50 ),
	.clk_100     ( clk_100 ),
	.locked      ( clk_locked ),
    // SMSC ethernet PHY
	.eth_crsdv   ( i_erx_dv ),
	.eth_refclk  ( o_erefclk ),
   
	.eth_txd     ( o_etxd ),
	.eth_txen    ( o_etx_en ),
   
	.eth_rxd     ( i_erxd ),
	.eth_rxerr   ( i_erx_er ),
   
	.eth_mdc     ( o_emdc ),
	.phy_mdio_i  ( phy_emdio_i ),
	.phy_mdio_o  ( phy_emdio_o ),
	.phy_mdio_t  ( phy_emdio_t ),
	.s_axi_aclk              ( s_axi_aclk             ),
	.s_axi_aresetn           ( s_axi_aresetn          ),
        .s_axi_awready           ( s_axi_awready          ),
        .s_axi_awvalid           ( s_axi_awvalid          ),
        .s_axi_awaddr            ( s_axi_awaddr           ),
        .s_axi_wready            ( s_axi_wready           ),
        .s_axi_wvalid            ( s_axi_wvalid           ),
        .s_axi_wstrb             ( s_axi_wstrb            ),
        .s_axi_wdata             ( s_axi_wdata            ),
        .s_axi_bready            ( s_axi_bready           ),
        .s_axi_bvalid            ( s_axi_bvalid           ),
        .s_axi_bresp             ( s_axi_bresp            ),
        .s_axi_arready           ( s_axi_arready          ),
        .s_axi_arvalid           ( s_axi_arvalid          ),
        .s_axi_araddr            ( s_axi_araddr           ),
        .s_axi_rready            ( s_axi_rready           ),
        .s_axi_rvalid            ( s_axi_rvalid           ),
        .s_axi_rdata             ( s_axi_rdata            ),
        .s_axi_rresp             ( s_axi_rresp            )
);
    
//----------------------------------------------------------------------------
//  Output     Output      Phase    Duty Cycle   Pk-to-Pk     Phase
//   Clock     Freq (MHz)  (degrees)    (%)     Jitter (ps)  Error (ps)
//----------------------------------------------------------------------------
// CLK_OUT1___200.000______0.000______50.0______102.086_____87.180
// CLK_OUT2____25.000______0.000______50.0______154.057_____87.180
// CLK_OUT3____50.000______0.000______50.0______132.683_____87.180
// CLK_OUT4____50.000_____90.000______50.0______132.683_____87.180
// CLK_OUT5___120.000______0.000______50.0______112.035_____87.180
// CLK_OUT6___100.000______0.000______50.0______115.831_____87.180

  clk_wiz_nexys4ddr_0 clk_gen
   (
   .clk_in1     ( clk_p         ), // 100 MHz onboard
   .clk_200     ( clk_200MHz    ), // 200 MHz
   .clk_25      ( msoc_clk      ), // 25 MHz (for minion SOC)
   .clk_50      ( i_clk50       ), // 50 MHz
   .clk_50_quad ( i_clk50_quad  ), // 50 MHz
   .clk_120     ( pxl_clk       ), // 120 MHz
   .clk_100     ( clk_100       ), // 100 MHz
    // Status and control signals
      .locked      ( clk_locked    )
      );

   minion_soc
     msoc (
         .*,
         .from_dip(i_dip_reg),
         .to_led(o_led_unbuf),
         .rstn(clk_locked & rst_top)
        );

reg [31:0] bcd_digits;

always @*
    casez(i_dip_reg[1:0])
        2'b00: bcd_digits = debug_addr;
        2'b01: bcd_digits = debug_wdata;
        2'b10: bcd_digits = debug_dout;
        2'b11: bcd_digits = {debug_reset,debug_runtest,debug_we,debug_unused[1:0],debug_blocksel,debug_halt,debug_resume,debug_req};
    endcase
    
   wire [8*7-1:0] digits;
   wire           overflow;

   genvar i;

   generate
      for (i = 0; i < 8; i = i + 1) begin
         sevensegment
            u_seg(.in  (bcd_digits[(i+1)*4-1:i*4]),
                  .out (digits[(i+1)*7-1:i*7]));
      end
   endgenerate

   nexys4ddr_display
     #(.FREQ(25000000))
   u_display(.clk       (clk_100),
             .rst       (~clk_locked),
             .digits    (digits),
             .decpoints (8'b00000000),
             .CA        (CA),
             .CB        (CB),
             .CC        (CC),
             .CD        (CD),
             .CE        (CE),
             .CF        (CF),
             .CG        (CG),
             .DP        (DP),
             .AN        (AN));

endmodule // chip_top
`default_nettype wire
