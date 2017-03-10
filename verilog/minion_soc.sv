// 
// (c) Copyright 2008 - 2013 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 

// Copyright 2015 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
// See LICENSE for license details.

`include "config.sv"
`default_nettype none

  module minion_soc
    (
     output wire        uart_tx,
     input wire         uart_rx,
     // clock and reset
     input wire         clk_200MHz,
     input wire         pxl_clk,
     input wire         msoc_clk,
     input wire         rstn,
     output reg [7:0]   to_led,
     input wire [15:0]  from_dip,
     output wire        sd_sclk,
     input wire         sd_detect,
     inout wire [3:0]   sd_dat,
     inout wire         sd_cmd,
     output reg         sd_reset,
`ifdef PMOD
     output wire        pmod_sd_sclk,
     input wire         pmod_sd_detect,
     inout wire [3:0]   pmod_sd_dat,
     inout wire         pmod_sd_cmd,
     output reg         pmod_sd_reset,
`endif
     output wire [31:0] core_lsu_addr,
     output reg [31:0]  core_lsu_addr_dly,
     output wire [31:0] core_lsu_wdata,
     output wire [3:0]  core_lsu_be,
     output wire        ce_d,
     output wire        we_d,
     output wire        shared_sel,
     input wire [31:0]  shared_rdata,
     // pusb button array
     input wire         GPIO_SW_C,
     input wire         GPIO_SW_W,
     input wire         GPIO_SW_E,
     input wire         GPIO_SW_N,
     input wire         GPIO_SW_S,
     //keyboard
     inout wire         PS2_CLK,
     inout wire         PS2_DATA,
    
     // display
     output             VGA_HS_O,
     output             VGA_VS_O,
     output [3:0]       VGA_RED_O,
     output [3:0]       VGA_BLUE_O,
     output [3:0]       VGA_GREEN_O,
     output [6:0]       SEG,
     output [7:0]       AN,
     output DP
     );
   
   wire [19:0]          dummy;
   wire                 irst, ascii_ready;
   wire [7:0]           readch, scancode;
   wire                 keyb_almostfull, keyb_full, keyb_rderr, keyb_wrerr, keyb_empty;   
   wire [11:0]          keyb_wrcount, keyb_rdcount;
   reg [31:0]           keycode;
   wire [31:0]          keyb_fifo_status = {keyb_empty,keyb_almostfull,keyb_full,keyb_rderr,keyb_wrerr,keyb_rdcount,keyb_wrcount};
   wire [35:0]          keyb_fifo_out;
   
   assign one_hot_rdata[9] = core_lsu_addr[2] ? {keyb_empty,keyb_fifo_out[15:0]} : keyb_fifo_status;
   
   ps2 keyb_mouse(
                  .clk(msoc_clk),
                  .rst(irst),
                  .PS2_K_CLK_IO(PS2_CLK),
                  .PS2_K_DATA_IO(PS2_DATA),
                  .PS2_M_CLK_IO(),
                  .PS2_M_DATA_IO(),
                  .ascii_code(readch[6:0]),
                  .ascii_data_ready(ascii_ready),
                  .rx_translated_scan_code(scancode),
                  .rx_ascii_read(ascii_ready));
   
   always @(posedge msoc_clk) if (ascii_ready)
     begin     
        keycode <= {readch[6:0], scancode, keycode[31:16]};
     end
   
   my_fifo #(.width(36)) keyb_fifo (
                                    .rd_clk(~msoc_clk),      // input wire read clk
                                    .wr_clk(~msoc_clk),      // input wire write clk
                                    .rst(~rstn),      // input wire rst
                                    .din({19'b0, readch[6:0], scancode}),      // input wire [31 : 0] din
                                    .wr_en(ascii_ready),  // input wire wr_en
                                    .rd_en(core_lsu_req&core_lsu_we&one_hot_data_addr[9]),  // input wire rd_en
                                    .dout(keyb_fifo_out),    // output wire [31 : 0] dout
                                    .rdcount(keyb_rdcount),         // 12-bit output: Read count
                                    .rderr(keyb_rderr),             // 1-bit output: Read error
                                    .wrcount(keyb_wrcount),         // 12-bit output: Write count
                                    .wrerr(keyb_wrerr),             // 1-bit output: Write error
                                    .almostfull(keyb_almostfull),   // output wire almost full
                                    .full(keyb_full),    // output wire full
                                    .empty(keyb_empty)  // output wire empty
                                    );
   
   seg7decimal sevenSeg (
                         .x(keycode[31:0]),
                         .clk(msoc_clk),
                         .seg(SEG[6:0]),
                         .an(AN[7:0]),
                         .dp(DP) 
                         );
   
   wire [7:0] red,  green, blue;
   
   fstore2 the_fstore(
                      .pixel2_clk(pxl_clk),
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
                      .web(ce_d & one_hot_data_addr[10] & we_d),
                      .enb(ce_d),
                      .addrb(core_lsu_addr[14:2]),
                      .dinb(core_lsu_wdata),
                      .doutb(one_hot_rdata[10]),
                      .irst(~rstn),
                      .clk_data(msoc_clk),
                      .GPIO_SW_C(GPIO_SW_C),
                      .GPIO_SW_N(GPIO_SW_N),
                      .GPIO_SW_S(GPIO_SW_S),
                      .GPIO_SW_E(GPIO_SW_E),
                      .GPIO_SW_W(GPIO_SW_W)              
                      );
   
   assign VGA_RED_O = red[7:4];
   assign VGA_GREEN_O = green[7:4];
   assign VGA_BLUE_O = blue[7:4];

   //----------------------------------------------------------------------------//
     // Core Instantiation
   //----------------------------------------------------------------------------//
   // signals from/to core
   logic      core_instr_req;
   logic      core_instr_gnt;
   logic      core_instr_rvalid;
   logic [31:0] core_instr_addr;

   logic        core_lsu_req;
   logic        core_lsu_gnt;
   logic        core_lsu_rvalid;
   logic        core_lsu_we;
   logic [31:0] core_lsu_rdata;

   logic        debug_req = 1'b0;
   logic        debug_gnt;
   logic        debug_rvalid;
   logic [14:0] debug_addr = 15'b0;
   logic        debug_we = 1'b0;
   logic [31: 0] debug_wdata = 32'b0;
   logic [31: 0] debug_rdata;
   logic [31: 0] core_instr_rdata;

   logic         fetch_enable_i = 1'b1;
   logic [31:0]  irq_i = 32'b0;
   logic         core_busy_o;
   logic         clock_gating_i = 1'b1;
   logic [31:0]  boot_addr_i = 32'h80;
   logic [7:0]   core_lsu_rx_byte;

   logic [15:0]  one_hot_data_addr;
   logic [31:0]  one_hot_rdata[15:0];

   assign shared_sel = one_hot_data_addr[8];
   
   always_comb
     begin:onehot
        integer i;
        core_lsu_rdata = 32'b0;
        for (i = 0; i < 16; i++)
          begin
             one_hot_data_addr[i] = core_lsu_addr[23:20] == i;
             core_lsu_rdata |= (one_hot_data_addr[i] ? one_hot_rdata[i] : 32'b0);
          end
     end

   riscv_core
     #(
       .N_EXT_PERF_COUNTERS ( 0 )
       )
   RISCV_CORE
     (
      .clk_i           ( msoc_clk          ),
      .rst_ni          ( rstn              ),

      .clock_en_i      ( 1'b1              ),
      .test_en_i       ( 1'b0              ),

      .boot_addr_i     ( boot_addr_i       ),
      .core_id_i       ( 4'h0              ),
      .cluster_id_i    ( 6'h0              ),

      .instr_addr_o    ( core_instr_addr   ),
      .instr_req_o     ( core_instr_req    ),
      .instr_rdata_i   ( core_instr_rdata  ),
      .instr_gnt_i     ( core_instr_gnt    ),
      .instr_rvalid_i  ( core_instr_rvalid ),

      .data_addr_o     ( core_lsu_addr     ),
      .data_wdata_o    ( core_lsu_wdata    ),
      .data_we_o       ( core_lsu_we       ),
      .data_req_o      ( core_lsu_req      ),
      .data_be_o       ( core_lsu_be       ),
      .data_rdata_i    ( core_lsu_rdata    ),
      .data_gnt_i      ( core_lsu_gnt      ),
      .data_rvalid_i   ( core_lsu_rvalid   ),
      .data_err_i      ( 1'b0              ),

      .irq_i           ( irq_i             ),

      .debug_req_i     ( debug_req         ),
      .debug_gnt_o     ( debug_gnt         ),
      .debug_rvalid_o  ( debug_rvalid      ),
      .debug_addr_i    ( debug_addr        ),
      .debug_we_i      ( debug_we          ),
      .debug_wdata_i   ( debug_wdata       ),
      .debug_rdata_o   ( debug_rdata       ),
      .debug_halted_o  (                   ),
      .debug_halt_i    ( 1'b0              ),
      .debug_resume_i  ( 1'b1              ),

      .fetch_enable_i  ( fetch_enable_i    ),
      .core_busy_o     ( core_busy_o       ),

      .ext_perf_counters_i (  2'b0         )
      );

   //----------------------------------------------------------------------------//
   // Data RAM
   //----------------------------------------------------------------------------//

   coremem coremem_d
     (
      .clk_i(msoc_clk),
      .rst_ni(rstn),
      .data_req_i(core_lsu_req),
      .data_gnt_o(core_lsu_gnt),
      .data_rvalid_o(core_lsu_rvalid),
      .data_we_i(core_lsu_we),
      .CE(ce_d),
      .WE(we_d)
      );

   datamem block_d (
                    .clk(msoc_clk),
                    .wea(ce_d & one_hot_data_addr[1] & we_d),
                    .ena(we_d ? core_lsu_be : 4'b1111),
                    .addra(core_lsu_addr[15:2]),
                    .dina(core_lsu_wdata),
                    .douta(one_hot_rdata[1]),
                    .web(1'b0),
                    .enb(4'b0000),
                    .addrb(core_lsu_addr[15:2]),
                    .dinb(core_lsu_wdata),
                    .doutb()
                    );

   //----------------------------------------------------------------------------//
   // Instruction RAM
   //----------------------------------------------------------------------------//

   logic        ce_i;
   logic        we_i;

   coremem coremem_i
     (
      .clk_i(msoc_clk),
      .rst_ni(rstn),
      .data_req_i(core_instr_req),
      .data_gnt_o(core_instr_gnt),
      .data_rvalid_o(core_instr_rvalid),
      .data_we_i(1'b0),
      .CE(ce_i),
      .WE(we_i)
      );

   progmem block_i (
                    .clk(msoc_clk),
                    .wea(1'b0),
                    .ena(4'b1111),
                    .addra(core_instr_addr[15:2]),
                    .dina(32'b0),
                    .douta(core_instr_rdata),
                    .web(ce_d & one_hot_data_addr[0] & we_d),
                    .enb(we_d ? core_lsu_be : 4'b1111),
                    .addrb(core_lsu_addr[15:2]),
                    .dinb(core_lsu_wdata),
                    .doutb(one_hot_rdata[0])
                    );

   //////////////////////////////////////////////////////////////////
   ///                                                            ///
   /// APB Slave 0: APB UART interface                            ///
   ///                                                            ///
   //////////////////////////////////////////////////////////////////
   
   reg          u_trans;
   reg          u_recv;
   reg [15:0]   u_baud;
   wire         received, recv_err, is_recv, is_trans, uart_maj;
   wire         uart_almostfull, uart_full, uart_rderr, uart_wrerr, uart_empty;   
   wire [11:0]  uart_wrcount, uart_rdcount;
   wire [8:0]   uart_fifo_data_out;
   reg [7:0]    u_tx_byte;

   rx_delay uart_rx_dly(
                        .clk(msoc_clk),
                        .in(uart_rx),                
                        .maj(uart_maj));

   uart i_uart(
               .clk(msoc_clk), // The master clock for this module
               .rst(~rstn), // Synchronous reset.
               .rx(uart_maj), // Incoming serial line
               .tx(uart_tx), // Outgoing serial line
               .transmit(u_trans), // Signal to transmit
               .tx_byte(u_tx_byte), // Byte to transmit
               .received(received), // Indicated that a byte has been received.
               .rx_byte(core_lsu_rx_byte), // Byte received
               .is_receiving(is_recv), // Low when receive line is idle.
               .is_transmitting(is_trans), // Low when transmit line is idle.
               .recv_error(recv_err), // Indicates error in receiving packet.
               .baud(u_baud),
               .recv_ack(u_recv)
               );

   assign one_hot_rdata[3] = {uart_wrcount,uart_almostfull,uart_full,uart_rderr,uart_wrerr,uart_fifo_data_out[8],is_trans,is_recv,~uart_empty,uart_fifo_data_out[7:0]};

   wire         tx_rd_fifo;
   wire         rx_wr_fifo;
   wire         sd_data_busy, data_crc_ok, sd_dat_oe;
`ifdef PMOD
   wire [3:0]   pmod_sd_dat_to_host;
   wire         pmod_sd_cmd_to_host;
`endif
   wire [3:0]   sd_dat_to_mem, sd_dat_to_host, sd_dat_to_host_maj;
   wire         sd_cmd_to_mem, sd_cmd_to_host, sd_cmd_to_host_maj, sd_cmd_oe;
   wire         sd_clk_o;       
   
   wire [7:0]   clock_divider_sd_clk;

   wire         sd_clk_rst, sd_data_rst;
   reg [15:0]   from_dip_reg;

   always @(posedge msoc_clk or negedge rstn)
     if (!rstn)
       begin
          from_dip_reg <= 0;
          u_recv <= 0;
          core_lsu_addr_dly <= 0;
          to_led <= 0;
          u_baud <= 16'd87;
          u_trans <= 1'b0;
          u_tx_byte <= 8'b0;
       end
     else
       begin
          from_dip_reg <= from_dip;
          u_recv <= received;
          core_lsu_addr_dly <= core_lsu_addr;
          if (core_lsu_req&core_lsu_we&one_hot_data_addr[7])
            to_led <= core_lsu_wdata;
          u_trans <= 1'b0;
          if (core_lsu_req&core_lsu_we&one_hot_data_addr[2])
            case(core_lsu_addr[5:2])
              0: begin u_trans <= 1'b1; u_tx_byte <= core_lsu_wdata[7:0]; end
              1: u_baud <= core_lsu_wdata;
            endcase
       end

   my_fifo #(.width(9)) uart_rx_fifo (
                                      .rd_clk(~msoc_clk),      // input wire read clk
                                      .wr_clk(~msoc_clk),      // input wire write clk
                                      .rst(~rstn),      // input wire rst
                                      .din({recv_err,core_lsu_rx_byte}),      // input wire [width-1 : 0] din
                                      .wr_en(received&&!u_recv),  // input wire wr_en
                                      .rd_en(core_lsu_req&core_lsu_we&one_hot_data_addr[3]),  // input wire rd_en
                                      .dout(uart_fifo_data_out),    // output wire [width-1 : 0] dout
                                      .rdcount(uart_rdcount),         // 12-bit output: Read count
                                      .rderr(uart_rderr),             // 1-bit output: Read error
                                      .wrcount(uart_wrcount),         // 12-bit output: Write count
                                      .wrerr(uart_wrerr),             // 1-bit output: Write error
                                      .almostfull(uart_almostfull),   // output wire almost full
                                      .full(uart_full),    // output wire full
                                      .empty(uart_empty)  // output wire empty
                                      );

   //Tx Fifo
   wire [31:0] data_in_rx_fifo;
   wire        tx_almostfull, tx_full, tx_rderr, tx_wrerr, tx_empty;   
   wire [11:0] tx_wrcount, tx_rdcount;
   //Rx Fifo
   wire [31:0] data_out_tx_fifo;
   wire        rx_almostfull, rx_full, rx_rderr, rx_wrerr, rx_empty;   
   wire [11:0] rx_wrcount, rx_rdcount;
   
   parameter iostd = "LVTTL";
   parameter slew = "FAST";
   parameter iodrv = 24;

`ifdef PMOD
   wire pmod_cmd_sel = from_dip_reg[0] ? pmod_sd_cmd_to_host : sd_cmd_to_host;
   wire int_cmd_dis =  from_dip_reg[0] || ~sd_cmd_oe;
   wire int_cmd_sel = ~from_dip_reg[0] || ~sd_cmd_oe;
   wire int_dat_dis =  from_dip_reg[0] || ~sd_dat_oe;
  wire int_clk_rst = ~from_dip_reg[0] || ~sd_clk_rst;
   wire [3:0] sel_to_host = from_dip_reg[0] ? pmod_sd_dat_to_host : sd_dat_to_host;

   IOBUF #(
           .DRIVE(iodrv), // Specify the output drive strength
           .IBUF_LOW_PWR("FALSE"),  // Low Power - "TRUE", High Performance = "FALSE" 
           .IOSTANDARD(iostd), // Specify the I/O standard
           .SLEW(slew) // Specify the output slew rate
           ) IOBUF_cmd_pinst (
                             .O(pmod_sd_cmd_to_host),     // Buffer output
                             .IO(pmod_sd_cmd),   // Buffer inout port (connect directly to top-level port)
                             .I(sd_cmd_to_mem),     // Buffer input
                             .T(int_cmd_sel)      // 3-state enable input, high=input, low=output
                             );

   IOBUF #(
           .DRIVE(iodrv), // Specify the output drive strength
           .IBUF_LOW_PWR("FALSE"),  // Low Power - "TRUE", High Performance = "FALSE" 
           .IOSTANDARD(iostd), // Specify the I/O standard
           .SLEW(slew) // Specify the output slew rate
           ) IOBUF_clk_pinst (
                             .O(),     // Buffer output
                             .IO(pmod_sd_sclk),   // Buffer inout port (connect directly to top-level port)
                             .I(~sd_clk_o),     // Buffer input
                             .T(int_clk_rst)      // 3-state enable input, high=input, low=output
                             );

`else

   wire pmod_cmd_sel = sd_cmd_to_host;
   wire int_cmd_dis = ~sd_cmd_oe;
   wire int_dat_dis = ~sd_dat_oe;
   wire int_clk_rst = ~sd_clk_rst;
   wire [3:0] sel_to_host = sd_dat_to_host;

`endif

   rx_delay cmd_rx_dly(
                       .clk(clk_200MHz),
                       .in(pmod_cmd_sel),             
                       .maj(sd_cmd_to_host_maj));

   // tri-state gate
   IOBUF #(
           .DRIVE(iodrv), // Specify the output drive strength
           .IBUF_LOW_PWR("FALSE"),  // Low Power - "TRUE", High Performance = "FALSE" 
           .IOSTANDARD(iostd), // Specify the I/O standard
           .SLEW(slew) // Specify the output slew rate
           ) IOBUF_cmd_inst (
                             .O(sd_cmd_to_host),     // Buffer output
                             .IO(sd_cmd),   // Buffer inout port (connect directly to top-level port)
                             .I(sd_cmd_to_mem),     // Buffer input
                             .T(int_cmd_dis)      // 3-state enable input, high=input, low=output
                             );

   IOBUF #(
           .DRIVE(iodrv), // Specify the output drive strength
           .IBUF_LOW_PWR("FALSE"),  // Low Power - "TRUE", High Performance = "FALSE" 
           .IOSTANDARD(iostd), // Specify the I/O standard
           .SLEW(slew) // Specify the output slew rate
           ) IOBUF_clk_inst (
                             .O(),     // Buffer output
                             .IO(sd_sclk),   // Buffer inout port (connect directly to top-level port)
                             .I(~sd_clk_o),     // Buffer input
                             .T(int_clk_rst)      // 3-state enable input, high=input, low=output
                             );

   genvar      sd_dat_ix;
   generate for (sd_dat_ix = 0; sd_dat_ix < 4; sd_dat_ix=sd_dat_ix+1)
     begin
        IOBUF #(
                .DRIVE(iodrv), // Specify the output drive strength
                .IBUF_LOW_PWR("FALSE"),  // Low Power - "TRUE", High Performance = "FALSE" 
                .IOSTANDARD(iostd), // Specify the I/O standard
                .SLEW(slew) // Specify the output slew rate
                ) IOBUF_dat_inst (
                                  .O(sd_dat_to_host[sd_dat_ix]),     // Buffer output
                                  .IO(sd_dat[sd_dat_ix]),   // Buffer inout port (connect directly to top-level port)
                                  .I(sd_dat_to_mem[sd_dat_ix]),     // Buffer input
                                  .T(int_dat_dis)      // 3-state enable input, high=input, low=output
                                  );

`ifdef PMOD
wire int_dat_sel = ~from_dip_reg[0] || ~sd_dat_oe;

       IOBUF #(
                .DRIVE(iodrv), // Specify the output drive strength
                .IBUF_LOW_PWR("FALSE"),  // Low Power - "TRUE", High Performance = "FALSE" 
                .IOSTANDARD(iostd), // Specify the I/O standard
                .SLEW(slew) // Specify the output slew rate
                ) IOBUF_dat_pinst (
                                  .O(pmod_sd_dat_to_host[sd_dat_ix]),     // Buffer output
                                  .IO(pmod_sd_dat[sd_dat_ix]),   // Buffer inout port (connect directly to top-level port)
                                  .I(sd_dat_to_mem[sd_dat_ix]),     // Buffer input
                                  .T(int_dat_sel)      // 3-state enable input, high=input, low=output
                                  );
`endif            

        rx_delay dat_rx_dly(
                            .clk(clk_200MHz),
                            .in(sel_to_host[sd_dat_ix]), 
                            .maj(sd_dat_to_host_maj[sd_dat_ix]));
     end
      
   endgenerate                                  
   
   wire data_rst = ~(sd_data_rst&rstn);
   
   my_fifo #(.width(36)) tx_fifo (
                                  .rd_clk(~sd_clk_o),      // input wire read clk
                                  .wr_clk(~msoc_clk),      // input wire write clk
                                  .rst(data_rst),      // input wire rst
                                  .din({dummy[3:0],core_lsu_wdata}),      // input wire [31 : 0] din
                                  .wr_en(core_lsu_req&core_lsu_we&one_hot_data_addr[5]),  // input wire wr_en
                                  .rd_en(tx_rd_fifo),  // input wire rd_en
                                  .dout({dummy[7:4],data_out_tx_fifo}),    // output wire [31 : 0] dout
                                  .rdcount(tx_rdcount),         // 12-bit output: Read count
                                  .rderr(tx_rderr),             // 1-bit output: Read error
                                  .wrcount(tx_wrcount),         // 12-bit output: Write count
                                  .wrerr(tx_wrerr),             // 1-bit output: Write error
                                  .almostfull(tx_almostfull),   // output wire almost full
                                  .full(tx_full),    // output wire full
                                  .empty(tx_empty)  // output wire empty
                                  );

   my_fifo #(.width(36)) rx_fifo (
                                  .rd_clk(~msoc_clk),      // input wire read clk
                                  .wr_clk(~sd_clk_o),      // input wire write clk
                                  .rst(data_rst),      // input wire rst
                                  .din({dummy[11:8],data_in_rx_fifo}),      // input wire [31 : 0] din
                                  .wr_en(rx_wr_fifo),  // input wire wr_en
                                  .rd_en(core_lsu_req&core_lsu_we&one_hot_data_addr[4]),  // input wire rd_en
                                  .dout({dummy[15:12],one_hot_rdata[4]}),    // output wire [31 : 0] dout
                                  .rdcount(rx_rdcount),         // 12-bit output: Read count
                                  .rderr(rx_rderr),             // 1-bit output: Read error
                                  .wrcount(rx_wrcount),         // 12-bit output: Write count
                                  .wrerr(rx_wrerr),             // 1-bit output: Write error
                                  .almostfull(rx_almostfull),   // output wire almost full
                                  .full(rx_full),    // output wire full
                                  .empty(rx_empty)  // output wire empty
                                  );

   wire [31:0] sd_cmd_wait, sd_data_wait;
   wire [12:0] sd_transf_cnt;
   wire [31:0] rx_fifo_status = {rx_almostfull,rx_full,rx_rderr,rx_wrerr,rx_rdcount,rx_wrcount};
   wire [31:0] tx_fifo_status = {tx_almostfull,tx_full,tx_rderr,tx_wrerr,tx_rdcount,tx_wrcount};
   
   assign one_hot_rdata[5] = 32'HDEADBEEF;
   assign one_hot_rdata[7] = from_dip_reg;
   assign one_hot_rdata[8] = shared_rdata;

   sd_clock_divider clock_divider0(
                                   .CLK (msoc_clk),
                                   .DIVIDER (clock_divider_sd_clk),
                                   .RST  (~(sd_clk_rst&rstn)),
                                   .SD_CLK  (sd_clk_o)
                                   );

   sd_bus sdbus(
                .msoc_clk(msoc_clk),
                .sd_clk(sd_clk_o),
                .rstn(rstn),
                .core_lsu_addr(core_lsu_addr),
                .core_lsu_wdata(core_lsu_wdata),
                .core_sd_we(core_lsu_req&core_lsu_we&one_hot_data_addr[6]),
                .sd_detect(sd_detect),
                .fifo_status({tx_full,tx_empty,rx_full,rx_empty}),
                .rx_fifo_status(rx_fifo_status),
                .tx_fifo_status(tx_fifo_status), 
                .data_out_tx_fifo(data_out_tx_fifo),
                .sd_dat_to_host(sd_dat_to_host_maj),
                .sd_cmd_to_host(sd_cmd_to_host_maj),
                //---------------Output ports---------------
                .sd_cmd_resp_sel(one_hot_rdata[6]),
                .data_in_rx_fifo(data_in_rx_fifo),
                .tx_rd_fifo(tx_rd_fifo),
                .rx_wr_fifo(rx_wr_fifo),
                .sd_transf_cnt(sd_transf_cnt),
                .sd_data_rst(sd_data_rst),
                .sd_reset(sd_reset),
                .clock_divider_sd_clk(clock_divider_sd_clk),
                .sd_clk_rst(sd_clk_rst),
                .sd_dat_to_mem(sd_dat_to_mem),
                .sd_cmd_to_mem(sd_cmd_to_mem),
                .sd_dat_oe(sd_dat_oe),
                .sd_cmd_oe(sd_cmd_oe)
                );

endmodule // chip_top
`default_nettype wire
