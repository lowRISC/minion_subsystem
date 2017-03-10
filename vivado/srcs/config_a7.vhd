-----------------------------------------------------------------------------
--! @file
--! @copyright  Copyright 2015 GNSS Sensor Ltd. All right reserved.
--! @author     Sergey Khabarov - sergeykhbr@gmail.com
--! @brief	FPGA artix7 specific constants definition.
------------------------------------------------------------------------------
library techmap;
use techmap.gencomp.all;

package config_target is
-- Technology and synthesis options
  constant CFG_FABTECH : integer := artix7;
  constant CFG_MEMTECH : integer := artix7;
  constant CFG_PADTECH : integer := artix7;
  constant CFG_JTAGTECH : integer := artix7;
  constant CFG_RMII : integer := 1;
end;
