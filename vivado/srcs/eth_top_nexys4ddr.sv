// See LICENSE for license details.

module eth_top
  (
  //! LEDs.
output [7:0] o_led,
input  [3:0] i_dip,

  //! Ethernet MAC PHY interface signals
output  o_erefclk     , // RMII clock out
input  i_gmiiclk_p    , // GMII clock in
input  i_gmiiclk_n    ,
output  o_egtx_clk    ,
input  i_etx_clk      ,
input  i_erx_clk      ,
input [3:0] i_erxd    ,
input  i_erx_dv       ,
input  i_erx_er       ,
input  i_erx_col      ,
input  i_erx_crs      ,
input  i_emdint       ,
output [3:0] o_etxd   ,
output  o_etx_en      ,
output  o_etx_er      ,
output  o_emdc        ,
inout   io_emdio   ,
output  o_erstn    ,   
   
   // clock and reset
   input         clk_p,
   input         clk_n,
   input         rst_top,
   
   output wire 	   uart_tx,
   input wire        uart_rx,
   output wire 	     sd_sclk,
   input wire        sd_detect,
   inout wire [3:0]  sd_dat,
   inout wire        sd_cmd,
   output reg        sd_reset,
// pusb button array
input GPIO_SW_C,
input GPIO_SW_W,
input GPIO_SW_E,
input GPIO_SW_N,
input GPIO_SW_S,
//keyboard
inout PS2_CLK,
inout PS2_DATA,

  // display
output           VGA_HS_O,
output           VGA_VS_O,
output  [3:0]    VGA_RED_O,
output  [3:0]    VGA_BLUE_O,
output  [3:0]    VGA_GREEN_O,
output [6:0]SEG,
output [7:0]AN,
output DP
           );

logic clk_locked, clk_200MHz;
logic [127:0] dib, dob, enb;
logic [13:0] addrb;
logic web;
logic [31:0] core_lsu_addr;
logic [31:0] core_lsu_addr_dly;
logic [31:0] core_lsu_wdata;
logic [3:0] core_lsu_be;
logic        ce_d;
logic        we_d;
logic     shared_sel;
logic [31:0] shared_rdata;
logic pxl_clk;

assign disp_seg_o = 0;
assign disp_an_o = 0;

assign addrb = core_lsu_addr[15:4];
assign enb = (we_d ? {{8{core_lsu_be[3]}},{8{core_lsu_be[2]}},{8{core_lsu_be[1]}},{8{core_lsu_be[0]}}} : 32'hFFFFFFFF) << {core_lsu_addr[3:2],5'b00000};
assign web = ce_d & shared_sel & we_d;
assign dib = {4{core_lsu_wdata}};
assign shared_rdata = dob >> {core_lsu_addr_dly[3:2],5'b00000};

eth_soc eth0 
( 
.clkb(msoc_clk),
.addrb(addrb[13:0]),
.dob(dob[127:0]),
.web(web),
.dib(dib[127:0]),
.enb(enb[127:0]),
   //! Input reset. Active High. Usually assigned to button "Center".
  .i_rst       (~rst_top),
  .wPllLocked  (clk_locked),
  //! Differential clock (LVDS) positive signal
  .i_clk50     (i_clk50),
  //! Differential clock (LVDS) negative signal
  .i_clk50_quad(i_clk50_quad),
  //! Ethernet MAC PHY interface signal
  .o_erefclk     (o_erefclk)      , // RMII clock out
  .i_gmiiclk_p   (i_gmiiclk_p)     , // GMII clock in
  .i_gmiiclk_n     (i_gmiiclk_n     ),
  .o_egtx_clk     (o_egtx_clk     ),
  .i_etx_clk       (i_etx_clk       ),
  .i_erx_clk       (i_erx_clk       ),
  .i_erxd          (i_erxd),
  .i_erx_dv        (i_erx_dv        ),
  .i_erx_er        (i_erx_er        ),
  .i_erx_col       (i_erx_col       ),
  .i_erx_crs       (i_erx_crs       ),
  .i_emdint        (i_emdint        ),
  .o_etxd         (o_etxd),
  .o_etx_en       (o_etx_en       ),
  .o_etx_er       (o_etx_er       ),
  .o_emdc         (o_emdc         ),
  .io_emdio      (io_emdio    ),
  .o_erstn       (o_erstn       ) 
);

 //----------------------------------------------------------------------------
//  Output     Output      Phase    Duty Cycle   Pk-to-Pk     Phase
//   Clock     Freq (MHz)  (degrees)    (%)     Jitter (ps)  Error (ps)
//----------------------------------------------------------------------------
// CLK_OUT1___200.000______0.000______50.0______114.829_____98.575
// CLK_OUT2____25.000______0.000______50.0______175.402_____98.575
// CLK_OUT3____50.000______0.000______50.0______151.636_____98.575
// CLK_OUT4____50.000_____90.000______50.0______151.636_____98.575
//
//----------------------------------------------------------------------------
// Input Clock   Freq (MHz)    Input Jitter (UI)
//----------------------------------------------------------------------------
// __primary_________100.000____________0.010

// The following must be inserted into your Verilog file for this
// core to be instantiated. Change the instance name and port connections
// (in parentheses) to your own signal names.

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
 
  clk_wiz_nexys4ddr_0 clk_gen
   (
   .clk_in1     ( clk_p         ), // 100 MHz onboard
   .clk_out1    ( clk_200MHz   ), // 200 MHz
   .clk_out2    ( msoc_clk      ), // 30 MHz (for minion SOC)
   .clk_out3    ( i_clk50       ), // 50 MHz
   .clk_out4    ( i_clk50_quad  ), // 50 MHz
   .clk_out5    ( pxl_clk       ), // 125 MHz
    // Status and control signals
      .resetn      ( rst_top       ),
      .locked      ( clk_locked    )
      );

   minion_soc
     msoc (
         .*,
         .from_dip(i_dip),
         .to_led(o_led),
         .rstn(clk_locked)
        );

endmodule // chip_top
