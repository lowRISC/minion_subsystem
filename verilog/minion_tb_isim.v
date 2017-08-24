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
wire  [7:0] AN;

   // clock and reset
   
    wire       uart_rts;
    wire       uart_cts;

    wire       CA;
    wire       CB;
    wire       CC;
    wire       CD;
    wire       CE;
    wire       CF;
    wire       CG;
    wire       DP;
 
    wire   redled;

wire  [15:0] i_dip = 16'h88;

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
   
initial
    begin
    @(posedge dut.o_etx_en);
    @(negedge dut.o_etx_en)
    #50000 $stop;
    end

always @(posedge dut.s_axi_bvalid)
  begin
     $display("axi_write(0x%X,0x%X,0x%X);", dut.s_axi_awaddr, dut.s_axi_wdata, dut.s_axi_wstrb);
  end

always @(posedge dut.s_axi_rready)
  begin
     $display("axi_read(0x%X,0x%X);", dut.s_axi_araddr, dut.s_axi_rdata);
  end
	 
endmodule // minion_soc
