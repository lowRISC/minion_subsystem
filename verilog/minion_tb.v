`timescale 1ns/1ps

  module minion_tb();
   
   wire 	   uart_tx;
   wire		   uart_rx;
   wire		   u_break;
   // clock and reset
   reg 		   clk;
   reg 		   rstn;
   wire [7:0] 	   to_led;
   wire 	   sd_sclk;
   reg 		   sd_detect;
   wire [3:0] 	   sd_dat;
   wire 	   sd_cmd;
   wire 	   sd_reset;
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

wire  [9:0] o_led;
wire  [7:0] i_dip = 8'h80;

  //! Ethernet MAC PHY interface signals
wire   o_erefclk     ; // RMII clock out
wire  [1:0] o_etxd   ;
wire   o_etx_en      ;
wire [1:0] i_erxd = o_etxd  ;
wire    i_erx_dv = o_etx_en ;
wire  i_erx_er = 1'b0   ;
wire  i_emdint       ;
wire   o_emdc        ;
wire  io_emdio   ;
wire   o_erstn    ;   
   
   // clock and reset
   wire clk_p = clk;
   
   wire clk_n = ~clk;
   
   wire rst_top = rstn;
			   
eth_top dut
  (
   .uart_tx(uart_tx),
   .uart_rx(uart_rx),
   .sd_sclk(sd_sclk),
   .sd_detect(sd_detect),
   .sd_dat(sd_dat),
   .sd_cmd(sd_cmd),
   .sd_reset(sd_reset),
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
   .VGA_GREEN_O(VGA_GREEN_O),
   .o_led(o_led),
   .i_dip(i_dip),
   .o_erefclk(o_erefclk),
   .i_erxd(i_erxd),
   .i_erx_dv(i_erx_dv),
   .i_erx_er(i_erx_er),
   .i_emdint(i_emdint),
   .o_etxd(o_etxd),
   .o_etx_en(o_etx_en),
   .o_emdc(o_emdc),
   .io_emdio(io_emdio),
   .o_erstn(o_erstn),
   .clk_p(clk_p),
   .clk_n(clk_n),
   .rst_top(rst_top),
   .uart_rts(uart_rts),
   .uart_cts(uart_cts),
   .CA(CA),
   .CB(CB),
   .CC(CC),
   .CD(CD),
   .CE(CE),   
   .CF(CF),
   .CG(CG),
   .DP(DP),
   .AN(AN),
   .redled(redled)
 );

   assign uart_rx = uart_tx;
   
initial
  begin
     $dumpvars;
     clk = 0;
     rstn = 0;
     sd_detect = 0;
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

module clk_wiz_1 
 (
 // Clock in ports
  input         clk_in1,
  // Clock out ports
  output        clk_sdclk,
  // Dynamic reconfiguration ports
  input   [6:0] daddr,
  input         dclk,
  input         den,
  input  [15:0] din,
  output [15:0] dout,
  output        drdy,
  input         dwe,
  // Status and control signals
  input         reset,
  output        locked
 );

   assign clk_sdclk = clk_in1;
   assign locked = ~reset;

endmodule
   
module clk_wiz_nexys4ddr_0 
 (
 // Clock in ports
  input         clk_in1,
  // Clock out ports
  output        clk_200,
  output        clk_25,
  output        clk_50,
  output        clk_50_quad,
  output        clk_120,
  output        clk_100,
  // Status and control signals
  input         resetn,
  output        locked
 );

   assign clk_25 = clk_in1;
   assign clk_50 = clk_in1;
   assign clk_50_quad = clk_in1;
   assign clk_100 = clk_in1;
   assign clk_120 = clk_in1;
   assign locked = resetn;

endmodule
