----------------------------------------------------------------------------
--! @file
--! @copyright  Copyright 2015 GNSS Sensor Ltd. All right reserved.
--! @author     Sergey Khabarov
--! @brief      8-bits memory block with the generic data size parameter.
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use std.textio.all;
library commonlib;
use commonlib.types_common.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity sram8_xilinx is
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
end;

architecture arch_sram8_xilinx of sram8_xilinx is

signal adr : std_logic_vector(13 downto 0);

begin

  reg : process (clk, address, wdata) begin
    if rising_edge(clk) then 
      adr <= address;
    end if;
  end process;

  raminst : for n in 0 to 7 generate

    RAMB16_S1_S1_inst : RAMB16_S1_S1 port map (
            CLKA => clk,      -- Port A Clock
            DOA => rdata(n downto n),  -- Port A 1-bit Data Output
            ADDRA => address(13 downto 0),    -- Port A 14-bit Address Input
            DIA => wdata(n downto n),   -- Port A 1-bit Data Input
            ENA => '1',    -- Port A RAM Enable Input
            SSRA => '0',     -- Port A Synchronous Set/Reset Input
            WEA => we,         -- Port A Write Enable Input
            CLKB => clkb,      -- Port B Clock
            DOB => dob(n downto n),  -- Port B 1-bit Data Output
            ADDRB => addrb(13 downto 0),    -- Port B 14-bit Address Input
            DIB => dib(n downto n),   -- Port B 1-bit Data Input
            ENB => enb(n),    -- Port B RAM Enable Input
            SSRB => '0',     -- Port B Synchronous Set/Reset Input
            WEB => web         -- Port B Write Enable Input
            );
    
  end generate;
 
end;
