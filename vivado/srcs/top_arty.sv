`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/11/2017 04:57:34 PM
// Design Name: 
// Module Name: top_arty
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_arty(

    //! LEDs.
    output [7:0] LED,
 
    // clock and reset
    input         CLK100MHZ,
    input         ck_rst,

    output wire 	  uart_rxd_out,
    input wire        uart_txd_in,
    
    // pusb button array
    input wire [3:0]  btn,
    input wire [3:0]  sw,


    output wire [11:0] rgb_led

);
    
      clk_wiz_arty_0 clk_gen
     (
     .clk_in1     ( CLK100MHZ     ), // 100 MHz onboard
     .clk_out1    ( clk_200MHz    ), // 200 MHz
     .clk_out2    ( msoc_clk      ), // 25 MHz (for minion SOC)
     .clk_out3    ( pxl_clk       ),
      // Status and control signals
        .reset      ( !ck_rst       ),
        .locked      ( clk_locked    )
        );
  
     minion_soc
       msoc (
           .clk_200MHz (clk_200MHz),
           .msoc_clk(msoc_clk),
           .pxl_clk(pxl_clk),

           .rstn(clk_locked),
           
           .uart_tx(uart_rxd_out),
           .uart_rx(uart_txd_in),

           .to_led(rgb_led[7:0]),
           .from_dip(btn),
           .GPIO_SW_N(sw[0]),
           .GPIO_SW_E(sw[1]),
           .GPIO_SW_W(sw[2]),
           .GPIO_SW_S(sw[3])
           
  );
endmodule
