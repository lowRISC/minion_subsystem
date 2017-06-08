`default_nettype none
`timescale 1ns/1ps

  module minion_tb();
   
   wire 	   uart_tx;
   wire		   uart_rx;
   wire		   u_break;
   // clock and reset
   reg 		   clk;
   reg 		   rstn;
   wire [7:0] 	   to_led;
   reg [15:0] 	   from_dip;
   wire 	   sd_sclk;
   reg 		   sd_detect;
   wire [3:0] 	   sd_dat;
   wire 	   sd_cmd;
   wire 	   sd_reset;
   wire [31:0] 	   core_lsu_addr;
   wire [31:0] 	   core_lsu_addr_dly;
   wire [31:0] 	   core_lsu_wdata;
   wire [3:0] 	   core_lsu_be;
   wire 	   ce_d;
   wire 	   we_d;
   wire 	   shared_sel;
   reg [31:0] 	   shared_rdata;
   // push button array
   reg 		   GPIO_SW_C;
   reg 		   GPIO_SW_W;
   reg 		   GPIO_SW_E;
   reg 		   GPIO_SW_N;
   reg 		   GPIO_SW_S;
   //keyboard
   wire 	   PS2_CLK;
   wire 	   PS2_DATA;
   
   // display
   wire 	   VGA_HS_O;
   wire 	   VGA_VS_O;
   wire [3:0] 	   VGA_RED_O;
   wire [3:0] 	   VGA_BLUE_O;
   wire [3:0] 	   VGA_GREEN_O;
			   
minion_soc dut
  (
   .uart_tx(uart_tx),
   .uart_rx(uart_rx),
   .u_break(u_break),
   .clk_200MHz(clk),
   .pxl_clk(clk),
   .msoc_clk(clk),
   .rstn(rstn),
   .to_led(to_led),
   .from_dip(from_dip),
   .sd_sclk(sd_sclk),
   .sd_detect(sd_detect),
   .sd_dat(sd_dat),
   .sd_cmd(sd_cmd),
   .sd_reset(sd_reset),
   .core_lsu_addr(core_lsu_addr),
   .core_lsu_addr_dly(core_lsu_addr_dly),
   .core_lsu_wdata(core_lsu_wdata),
   .core_lsu_be(core_lsu_be),
   .ce_d(ce_d),
   .we_d(we_d),
   .shared_sel(shared_sel),
   .shared_rdata(shared_rdata),
   .GPIO_SW_C(GPIO_SW_C),
   .GPIO_SW_W(GPIO_SW_W),
   .GPIO_SW_E(GPIO_SW_E),
   .GPIO_SW_N(GPIO_SW_N),
   .GPIO_SW_S(GPIO_SW_S),
   .PS2_CLK(PS2_CLK),
   .PS2_DATA(PS2_DATA),
   .VGA_HS_O(VGA_HS_O),
   .VGA_VS_O(VGA_VS_O),
   .VGA_RED_O(VGA_RED_O),
   .VGA_BLUE_O(VGA_BLUE_O),
   .VGA_GREEN_O(VGA_GREEN_O)
 );

   assign uart_rx = uart_tx;
   
initial
  begin
     clk = 0;
     rstn = 0;
     from_dip = 0;
     sd_detect = 0;
     shared_rdata = 0;
     GPIO_SW_C = 0;
     GPIO_SW_W = 0;
     GPIO_SW_E = 0;
     GPIO_SW_N = 0;
     GPIO_SW_S = 0;
     forever begin
	#500 clk = 1;
	#500 clk = 0;
	#500 clk = 1;
	#500 clk = 0;
	#500 clk = 1;
	#500 clk = 0;
	#500 clk = 1;
	#500 clk = 0;
	#500 clk = 1;
	#500 clk = 0;
	#500 clk = 1;
	#500 clk = 0;
	#500 clk = 1;
	#500 clk = 0;
	#500 clk = 1;
	#500 clk = 0;
	#500 clk = 1;
	#500 clk = 0;
	#500 clk = 1;
	#500 clk = 0;
	rstn = 1;
	if (u_break) $finish;
     end
  end
   
endmodule // minion_soc
