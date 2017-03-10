`default_nettype none

  module vga_ctrl (
                   input wire        clk_p,
                   input wire        CPU_RESETN,
                   input wire        GPIO_SW_C,
                   input wire        GPIO_SW_W,
                   input wire        GPIO_SW_E,
                   input wire        GPIO_SW_N,
                   input wire        GPIO_SW_S,
                   input wire [7:0]  SW,
                   inout wire        PS2_CLK,
                   inout wire        PS2_DATA,

                   output wire       VGA_HS_O,
                   output wire       VGA_VS_O,
                   output wire [3:0] VGA_RED_O,
                   output wire [3:0] VGA_BLUE_O,
                   output wire [3:0] VGA_GREEN_O,
                   output wire [6:0] SEG,
                   output wire [7:0] AN,
                   output wire       DP
                   );

   reg                               irst;
   wire [7:0]                        readch, scancode;
   reg [31:0]                        keycode;

   ps2 keyb_mouse(
                  .clk(clk_p),
                  .rst(irst),
                  .PS2_K_CLK_IO(PS2_CLK),
                  .PS2_K_DATA_IO(PS2_DATA),
                  .PS2_M_CLK_IO(),
                  .PS2_M_DATA_IO(),
                  .ascii_code(readch[6:0]),
                  .ascii_data_ready(readch[7]),
                  .rx_translated_scan_code(scancode),
                  .rx_ascii_read(readch[7]));

   always @(posedge clk_p) if (readch[7])
     begin     
        keycode <= {readch[6:0], scancode, keycode[31:16]};
     end
   
   seg7decimal sevenSeg (
                         .x(keycode[31:0]),
                         .clk(clk_p),
                         .seg(SEG[6:0]),
                         .an(AN[7:0]),
                         .dp(DP) 
                         );

   wire [7:0] writech = readch[7:0];
   
   wire [7:0] red, green, blue, doutb;
   wire       reset = GPIO_SW_W & GPIO_SW_N;
   
   reg [7:0]  dinb;
   reg [12:0] reset_delay;
   reg [12:0] addrb_int;
   wire [12:0] addrb = irst ? reset_delay[12:0] : addrb_int;
   reg [0:0]   web, enb;
   
   reg         writech_read;

   fstore2 the_fstore(
                      .pixel2_clk(clk_p),
                      .blank(),
                      .DVI_D(),
                      .DVI_XCLK_P(),
                      .DVI_XCLK_N(),
                      .DVI_H(),
                      .DVI_V(),
                      .DVI_DE(),
                      .vsyn(VGA_VS_O),
                      .hsyn(VGA_HS_O),
                      .red(red),
                      .green(green),
                      .blue(blue),
                      .doutb(doutb),
                      .dinb(dinb),
                      .addrb(addrb),
                      .web(web),
                      .enb(enb),
                      .irst(irst),
                      .clk_data(clk_p),
                      .GPIO_SW_C(GPIO_SW_C),
                      .GPIO_SW_N(GPIO_SW_N),
                      .GPIO_SW_S(GPIO_SW_S),
                      .GPIO_SW_E(GPIO_SW_E),
                      .GPIO_SW_W(GPIO_SW_W)                   
                      );

   assign VGA_RED_O = red[7:4];
   assign VGA_GREEN_O = green[7:4];
   assign VGA_BLUE_O = blue[7:4];

   always @(posedge clk_p)
     begin
        if (reset || ~(&reset_delay))
          begin
             reset_delay = reset ? 0 : reset_delay + 1;
             irst <= 1;
             web <= 1;
             enb <= 1;
             addrb_int <= 0;
             dinb = 8'h20;
             writech_read <= 0;
          end
        else
          begin
             irst <= 0;
             writech_read <= writech[7];
             if ((writech[7] && !writech_read) && !(&addrb_int))
               begin
                  dinb = {1'b0,writech[6:0]};
                  addrb_int <= (dinb==10 && !(&addrb_int[10:5]) ? addrb_int|127 : addrb_int) + 1;
                  web <= dinb!=10;
               end
             else
               web <= 0;
          end
     end

endmodule
`default_nettype wire
