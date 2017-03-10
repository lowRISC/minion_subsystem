----------------------------------------------------------------------------
--! @file
--! @copyright  Copyright 2015 GNSS Sensor Ltd. All right reserved.
--! @author     Sergey Khabarov
--! @brief      Gigabits buffer with the differential signals.
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity igdsbuf_artix7 is
  generic (
    generic_tech : integer := 0
  );
  port (
    gclk_p : in std_logic;
    gclk_n : in std_logic;
    o_clk  : out std_logic
  );
end; 

architecture rtl of igdsbuf_artix7 is

component ibuf_inferred is
  port (
    o  : out std_logic;
    i  : in std_logic
  );
end component; 

begin

bufinf : ibuf_inferred port map
(
  o => o_clk,
  i => gclk_p
);

end;
