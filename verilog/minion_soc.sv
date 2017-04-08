// Copyright 2015 ETH Zurich, University of Bologna, and University of Cambridge
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
 output wire 	   uart_tx,
 input wire 	   uart_rx,
 // clock and reset
 input wire        clk_200MHz,
 input wire        pxl_clk,
 input wire 	   msoc_clk,
 input wire 	   rstn,
 output reg [7:0]  to_led,
 input wire [15:0] from_dip,
 output wire 	   sd_sclk,
 input wire 	   sd_detect,
 inout wire [3:0]  sd_dat,
 inout wire 	   sd_cmd,
 output reg 	   sd_reset,
 output wire [31:0] 	   core_lsu_addr,
 output reg  [31:0] 	   core_lsu_addr_dly,
 output wire [31:0] 	   core_lsu_wdata,
 output wire [3:0] 	   core_lsu_be,
 output wire	   ce_d,
 output wire	   we_d,
 output wire	   shared_sel,
 input wire [31:0] 	   shared_rdata,
 // pusb button array
 input wire GPIO_SW_C,
 input wire GPIO_SW_W,
 input wire GPIO_SW_E,
 input wire GPIO_SW_N,
 input wire GPIO_SW_S,
 //keyboard
 inout wire PS2_CLK,
 inout wire PS2_DATA,
 
   // display
 output           VGA_HS_O,
 output           VGA_VS_O,
 output  [3:0]    VGA_RED_O,
 output  [3:0]    VGA_BLUE_O,
 output  [3:0]    VGA_GREEN_O
 );
 
 wire [19:0] dummy;
 wire        irst, ascii_ready;
 wire [7:0]  readch, scancode;
 wire        keyb_almostfull, keyb_full, keyb_rderr, keyb_wrerr, keyb_empty;   
 wire [11:0] keyb_wrcount, keyb_rdcount;
 reg [31:0]  keycode;
 wire [31:0] keyb_fifo_status = {keyb_empty,keyb_almostfull,keyb_full,keyb_rderr,keyb_wrerr,keyb_rdcount,keyb_wrcount};
 wire [35:0] keyb_fifo_out;
 
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
logic         core_instr_req;
logic         core_instr_gnt;
logic         core_instr_rvalid;
logic [31:0]  core_instr_addr;

logic         core_lsu_req;
logic         core_lsu_gnt;
logic         core_lsu_rvalid;
logic         core_lsu_we;
logic [31:0]  core_lsu_rdata;

  logic                  debug_req = 1'b0;
  logic                  debug_gnt;
  logic                  debug_rvalid;
  logic [14:0]           debug_addr = 15'b0;
  logic                  debug_we = 1'b0;
  logic [31: 0]          debug_wdata = 32'b0;
  logic [31: 0]          debug_rdata;
  logic [31: 0]          core_instr_rdata;

  logic        fetch_enable_i = 1'b1;
  logic [31:0] irq_i = 32'b0;
  logic        core_busy_o;
  logic        clock_gating_i = 1'b1;
  logic [31:0] boot_addr_i = 32'h80;
  logic  [7:0] core_lsu_rx_byte;

  logic [15:0] one_hot_data_addr;
  logic [31:0] one_hot_rdata[15:0];

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

   logic 	ce_i;
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
	     
reg u_trans;
reg u_recv;
reg [15:0] u_baud;
wire received, recv_err, is_recv, is_trans, uart_maj;
wire uart_almostfull, uart_full, uart_rderr, uart_wrerr, uart_empty;   
wire [11:0] uart_wrcount, uart_rdcount;
wire [8:0] uart_fifo_data_out;
reg  [7:0] u_tx_byte;

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

   wire    tx_rd_fifo;
   wire    rx_wr_fifo;
   wire       sd_data_busy, data_crc_ok, sd_dat_oe;
   wire [3:0] sd_dat_to_mem, sd_dat_to_host, sd_dat_to_host_maj;
   wire       sd_cmd_to_mem, sd_cmd_to_host, sd_cmd_to_host_maj, sd_cmd_oe;
   wire       sd_clk_o;       
   wire       sd_cmd_finish, sd_data_finish, sd_cmd_crc_ok, sd_cmd_index_ok;

   reg [2:0]  sd_data_start_reg;
   reg [1:0]  sd_align_reg;
   reg [15:0] sd_blkcnt_reg;
   reg [11:0] sd_blksize_reg;
   
   reg [15:0] clock_divider_sd_clk_reg;
   reg [2:0]  sd_cmd_setting_reg;
   reg [5:0]  sd_cmd_i_reg;
   reg [31:0] sd_cmd_arg_reg;
   reg [31:0] sd_cmd_timeout_reg;

   reg sd_cmd_start_reg;

   reg [2:0]  sd_data_start;
   reg [1:0]  sd_align;
   reg [15:0] sd_blkcnt;
   reg [11:0] sd_blksize;
   
   reg [15:0] clock_divider_sd_clk;
   reg [2:0]  sd_cmd_setting;
   reg [5:0]  sd_cmd_i;
   reg [31:0] sd_cmd_arg;
   reg [31:0] sd_cmd_timeout;

   reg 	   sd_cmd_start, sd_cmd_rst, sd_data_rst, sd_clk_rst;
   reg [15:0] from_dip_reg;

logic [6:0] sd_clk_daddr;
logic       sd_clk_dclk, sd_clk_den, sd_clk_drdy, sd_clk_dwe, sd_clk_locked;
logic [15:0] sd_clk_din, sd_clk_dout;

assign sd_clk_dclk = msoc_clk;

always @(posedge msoc_clk or negedge rstn)
  if (!rstn)
    begin
    from_dip_reg <= 0;
	u_recv <= 0;
	core_lsu_addr_dly <= 0;
	sd_align_reg <= 0;
	sd_blkcnt_reg <= 0;
	sd_blksize_reg <= 0;
	sd_data_start_reg <= 0;
	sd_clk_din <= 0;
	sd_clk_den <= 0;
	sd_clk_dwe <= 0;
	sd_clk_daddr <= 0;
	sd_cmd_i_reg <= 0;
	sd_cmd_arg_reg <= 0;
	sd_cmd_setting_reg <= 0;
	sd_cmd_start_reg <= 0;
	sd_reset <= 0;
	sd_data_rst <= 0;
	sd_cmd_rst <= 0;
	sd_clk_rst <= 0;
	sd_cmd_timeout_reg <= 0;
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
	if (core_lsu_req&core_lsu_we&one_hot_data_addr[6])
	  case(core_lsu_addr[5:2])
	    0: sd_align_reg <= core_lsu_wdata;
	    1: sd_clk_din <= core_lsu_wdata;
	    2: sd_cmd_arg_reg <= core_lsu_wdata;
	    3: sd_cmd_i_reg <= core_lsu_wdata;
	    4: {sd_data_start_reg,sd_cmd_setting_reg[2:0]} <= core_lsu_wdata;
	    5: sd_cmd_start_reg <= core_lsu_wdata;
	    6: {sd_reset,sd_clk_rst,sd_data_rst,sd_cmd_rst} <= core_lsu_wdata;
	    7: sd_blkcnt_reg <= core_lsu_wdata;
	    8: sd_blksize_reg <= core_lsu_wdata;
	    9: sd_cmd_timeout_reg <= core_lsu_wdata;
	   10: {sd_clk_dwe,sd_clk_den,sd_clk_daddr} <= core_lsu_wdata;
	  endcase
	if (core_lsu_req&core_lsu_we&one_hot_data_addr[7])
	  to_led <= core_lsu_wdata;
	u_trans <= 1'b0;
    if (core_lsu_req&core_lsu_we&one_hot_data_addr[2])
      case(core_lsu_addr[5:2])
        0: begin u_trans <= 1'b1; u_tx_byte <= core_lsu_wdata[7:0]; end
        1: u_baud <= core_lsu_wdata;
      endcase
     end

always @(posedge sd_clk_o)
    begin
	sd_align <= sd_align_reg;
	sd_cmd_arg <= sd_cmd_arg_reg;
	sd_cmd_i <= sd_cmd_i_reg;
	{sd_data_start,sd_cmd_setting} <= {sd_data_start_reg,sd_cmd_setting_reg};
	sd_cmd_start <= sd_cmd_start_reg;
	sd_blkcnt <= sd_blkcnt_reg;
	sd_blksize <= sd_blksize_reg;
	sd_cmd_timeout <= sd_cmd_timeout_reg;
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
   wire data_rst = ~(sd_data_rst&rstn);
   
   parameter iostd = "LVTTL";
   parameter slew = "FAST";
   parameter iodrv = 24;
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
       .T(~sd_cmd_oe)      // 3-state enable input, high=input, low=output
    );

    rx_delay cmd_rx_dly(
        .clk(clk_200MHz),
        .in(sd_cmd_to_host),             
        .maj(sd_cmd_to_host_maj));

   IOBUF #(
        .DRIVE(iodrv), // Specify the output drive strength
        .IBUF_LOW_PWR("FALSE"),  // Low Power - "TRUE", High Performance = "FALSE" 
        .IOSTANDARD(iostd), // Specify the I/O standard
        .SLEW(slew) // Specify the output slew rate
     ) IOBUF_clk_inst (
        .O(),     // Buffer output
        .IO(sd_sclk),   // Buffer inout port (connect directly to top-level port)
        .I(~sd_clk_o),     // Buffer input
        .T(~sd_clk_rst)      // 3-state enable input, high=input, low=output
   );

    genvar sd_dat_ix;
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
            .T(~sd_dat_oe)      // 3-state enable input, high=input, low=output
        );
        rx_delay dat_rx_dly(
            .clk(clk_200MHz),
            .in(sd_dat_to_host[sd_dat_ix]),             
            .maj(sd_dat_to_host_maj[sd_dat_ix]));
        end
        
   endgenerate					
				   
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
  .wr_clk(sd_clk_o),      // input wire write clk
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

   logic [133:0]    sd_cmd_response, sd_cmd_response_reg;
   logic [31:0] 	sd_cmd_resp_sel, sd_status_reg;
   logic [31:0] 	sd_status, sd_cmd_wait, sd_data_wait, sd_cmd_wait_reg, sd_data_wait_reg;
   logic [6:0] 	    sd_cmd_crc_val;
   logic [47:0] 	sd_cmd_packet, sd_cmd_packet_reg;
   logic [15:0] 	sd_transf_cnt, sd_transf_cnt_reg;
   logic            sd_detect_reg;
   
   wire [31:0]  rx_fifo_status = {rx_almostfull,rx_full,rx_rderr,rx_wrerr,rx_rdcount,rx_wrcount};
   wire [31:0]  tx_fifo_status = {tx_almostfull,tx_full,tx_rderr,tx_wrerr,tx_rdcount,tx_wrcount};
   	
   always @(posedge msoc_clk)
     begin
     sd_status_reg = sd_status;
     sd_cmd_response_reg = sd_cmd_response;
     sd_cmd_wait_reg = sd_cmd_wait;
     sd_data_wait_reg = sd_data_wait;
     sd_cmd_packet_reg = sd_cmd_packet;
     sd_transf_cnt_reg = sd_transf_cnt;	
     case(core_lsu_addr[6:2])
       0: sd_cmd_resp_sel = sd_cmd_response_reg[38:7];
       1: sd_cmd_resp_sel = sd_cmd_response_reg[70:39];
       2: sd_cmd_resp_sel = sd_cmd_response_reg[102:71];
       3: sd_cmd_resp_sel = sd_cmd_response_reg[133:103];
       4: sd_cmd_resp_sel = sd_cmd_wait_reg;
       5: sd_cmd_resp_sel = sd_status_reg;
       6: sd_cmd_resp_sel = sd_cmd_packet_reg[31:0];
       7: sd_cmd_resp_sel = sd_cmd_packet_reg[47:32];       
       8: sd_cmd_resp_sel = sd_data_wait_reg;
       9: sd_cmd_resp_sel = sd_transf_cnt_reg;
      10: sd_cmd_resp_sel = rx_fifo_status;
      11: sd_cmd_resp_sel = tx_fifo_status;
      12: sd_cmd_resp_sel = sd_detect_reg;
      15: sd_cmd_resp_sel = {sd_clk_locked,sd_clk_drdy,sd_clk_dout};
 	  16: sd_cmd_resp_sel = sd_align_reg;
      17: sd_cmd_resp_sel = sd_clk_din;
      18: sd_cmd_resp_sel = sd_cmd_arg_reg;
      19: sd_cmd_resp_sel = sd_cmd_i_reg;
      20: sd_cmd_resp_sel = {sd_data_start_reg,sd_cmd_setting_reg};
      21: sd_cmd_resp_sel = sd_cmd_start_reg;
      22: sd_cmd_resp_sel = {sd_reset,sd_clk_rst,sd_data_rst,sd_cmd_rst};
      23: sd_cmd_resp_sel = sd_blkcnt_reg;
      24: sd_cmd_resp_sel = sd_blksize_reg;
      25: sd_cmd_resp_sel = sd_cmd_timeout_reg;
      26: sd_cmd_resp_sel = {sd_clk_dwe,sd_clk_den,sd_clk_daddr};
     default: sd_cmd_resp_sel = 32'HDEADBEEF;
     endcase // case (core_lsu_addr[6:2])
     end
   
   assign sd_status[3:0] = {tx_full,tx_empty,rx_full,rx_empty};

   assign one_hot_rdata[5] = sd_status_reg; // legacy setting
   assign one_hot_rdata[6] = sd_cmd_resp_sel;
   assign one_hot_rdata[7] = from_dip_reg;
   assign one_hot_rdata[8] = shared_rdata;

clk_wiz_1 sd_clk_div
     (
     // Clock in ports
      .clk_in1(msoc_clk),      // input clk_in1
      // Clock out ports
      .clk_sdclk(sd_clk_o),     // output clk_sdclk
      // Dynamic reconfiguration ports
      .daddr(sd_clk_daddr), // input [6:0] daddr
      .dclk(sd_clk_dclk), // input dclk
      .den(sd_clk_den), // input den
      .din(sd_clk_din), // input [15:0] din
      .dout(sd_clk_dout), // output [15:0] dout
      .drdy(sd_clk_drdy), // output drdy
      .dwe(sd_clk_dwe), // input dwe
      // Status and control signals
      .reset(~(sd_clk_rst&rstn)), // input reset
      .locked(sd_clk_locked));      // output locked

sd_top sdtop(
    .sd_clk     (sd_clk_o),
    .cmd_rst    (~(sd_cmd_rst&rstn)),
    .data_rst   (data_rst),
    .setting_i  (sd_cmd_setting),
    .timeout_i  (sd_cmd_timeout),
    .cmd_i      (sd_cmd_i),
    .arg_i      (sd_cmd_arg),
    .start_i    (sd_cmd_start),
    .sd_data_start_i(sd_data_start),
    .sd_align_i(sd_align),
    .sd_blkcnt_i(sd_blkcnt),
    .sd_blksize_i(sd_blksize),
    .sd_data_i(data_out_tx_fifo),
    .sd_dat_to_host(sd_dat_to_host_maj),
    .sd_cmd_to_host(sd_cmd_to_host_maj),
    .finish_cmd_o(sd_cmd_finish),
    .finish_data_o(sd_data_finish),
    .response0_o(sd_cmd_response[38:7]),
    .response1_o(sd_cmd_response[70:39]),
    .response2_o(sd_cmd_response[102:71]),
    .response3_o(sd_cmd_response[133:103]),
    .crc_ok_o   (sd_cmd_crc_ok),
    .index_ok_o (sd_cmd_index_ok),
    .transf_cnt_o(sd_transf_cnt),
    .wait_o(sd_cmd_wait),
    .wait_data_o(sd_data_wait),
    .status_o(sd_status[31:4]),
    .packet0_o(sd_cmd_packet[31:0]),
    .packet1_o(sd_cmd_packet[47:32]),
    .crc_val_o(sd_cmd_crc_val),
    .crc_actual_o(sd_cmd_response[6:0]),
    .sd_rd_o(tx_rd_fifo),
    .sd_we_o(rx_wr_fifo),
    .sd_data_o(data_in_rx_fifo),    
    .sd_dat_to_mem(sd_dat_to_mem),
    .sd_cmd_to_mem(sd_cmd_to_mem),
    .sd_dat_oe(sd_dat_oe),
    .sd_cmd_oe(sd_cmd_oe)
    );

endmodule // chip_top
`default_nettype wire
