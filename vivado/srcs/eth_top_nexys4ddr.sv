// See LICENSE for license details.
`default_nettype none

module eth_top
  (
  //! LEDs.
output wire  [9:0] o_led,
input wire  [7:0] i_dip,

  //! Ethernet MAC PHY interface signals
output wire   o_erefclk     , // RMII clock out
input wire  i_gmiiclk_p    , // GMII clock in
input wire  i_gmiiclk_n    ,
output wire   o_egtx_clk    ,
input wire  i_etx_clk      ,
input wire  i_erx_clk      ,
input wire [1:0] i_erxd    ,
input wire  i_erx_dv       ,
input wire  i_erx_er       ,
input wire  i_erx_col      ,
input wire  i_erx_crs      ,
input wire  i_emdint       ,
output reg  [1:0] o_etxd   ,
output wire   o_etx_en      ,
output wire   o_etx_er      ,
output wire   o_emdc        ,
inout wire  io_emdio   ,
output wire   o_erstn    ,   
   
   // clock and reset
   input wire         clk_p,
   input wire         clk_n,
   input wire         rst_top,
   
   output wire 	     uart_tx,
   input wire        uart_rx,
   output wire       uart_rts,
   input wire        uart_cts,

   output wire 	     sd_sclk,
   input wire        sd_detect,
   inout wire [3:0]  sd_dat,
   inout wire        sd_cmd,
   output reg        sd_reset,
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
output wire           VGA_HS_O,
output wire           VGA_VS_O,
output wire  [3:0]    VGA_RED_O,
output wire  [3:0]    VGA_BLUE_O,
output wire  [3:0]    VGA_GREEN_O,

   output wire       CA,
   output wire       CB,
   output wire       CC,
   output wire       CD,
   output wire       CE,
   output wire       CF,
   output wire       CG,
   output wire       DP,
   output wire [7:0] AN,

   output reg   redled
   );

logic clk_locked, clk_200MHz, msoc_clk, i_clk50, i_clk50_quad, clk_100;
logic [31:0] core_lsu_addr;
logic [31:0] core_lsu_addr_dly;
logic [31:0] core_lsu_wdata;
logic [3:0] core_lsu_be;
logic        ce_d;
logic        we_d;
logic     tap_sel;
logic [31:0] tap_rdata, tap_rdata_pkt, tap_wdata_pkt, rx_fcs_o, tx_fcs_o;
logic pxl_clk, tx_enable_i, tx_byte_sent_o, tx_busy_o, rx_frame_o, rx_byte_received_o, rx_error_o;
logic mac_tx_enable, mac_tx_gap, mac_tx_byte_sent, mac_rx_frame, mac_rx_byte_received, mac_rx_error;
logic [47:0] mac_address;
logic  [7:0] rx_data_o0, rx_data_o1, rx_data_o2, rx_data_o, tx_data_i, mac_tx_data, mac_rx_data;
logic [12:0] rx_frame_size_o;   
logic [15:0] rx_packet_length, tx_packet_length, tx_frame_size, tx_frame_addr;
reg [13:0] addr_tap, nxt_addr;
reg [15:0] rx_byte, rx_nxt;
reg  [7:0] rx_byte_dly;
reg  [1:0] rx_pair;
reg        rx_wren, full, byte_sync;
   // datamem shared port
   logic [3:0] 	sharedmem_en;
   logic [31:0] sharedmem_dout;
   logic [31:0] shared_rdata;
   logic        shared_sel;

// datamem shared port
   logic [0:0] 	datamem_web;
   logic [3:0] 	datamem_enb;
   logic [31:0] datamem_doutb;
  
   // progmem shared port
   logic [0:0] 	progmem_web;
   logic [3:0] 	progmem_enb;
   logic [31:0] progmem_doutb;

   logic     debug_req;
   logic     debug_gnt;
   logic     debug_rvalid;
   logic [31:0] debug_addr;
   logic 	debug_we;
   logic [31:0] debug_wdata;
   logic [31:0] debug_rdata;
   logic        debug_reset;
   logic        debug_runtest;
   logic        debug_halt;
   logic        debug_halted;
   logic        debug_resume;
   logic        debug_clk, debug_clk2, debug_blocksel;
   logic [2:0]  debug_unused;
   
   logic [31:0] core_instr_rdata, debug_dout;

    always @*
        begin      
        progmem_enb = 4'h0; datamem_enb = 4'h0; sharedmem_en = 4'h0; debug_blocksel = 1'b0;
        casez(debug_addr[23:20])
            4'h0: begin progmem_enb = 4'hf; debug_dout = progmem_doutb; end
            4'h1: begin datamem_enb = 4'hf; debug_dout = datamem_doutb; end
            4'h8: begin sharedmem_en = 4'hf; debug_dout = sharedmem_dout; end
            4'hf: begin debug_blocksel = &debug_addr[31:24]; debug_dout = debug_rdata; end
            default: debug_dout = 32'hDEADBEEF;
            endcase
        end
        
jtag_dummy jtag1(
    .DBG({debug_unused[2:0],debug_halt,debug_resume,debug_req}),
    .WREN(debug_we),
    .FROM_MEM(debug_dout),
    .ADDR(debug_addr),
    .TO_MEM(debug_wdata),
    .TCK(debug_clk),
    .TCK2(debug_clk2),
    .RESET(debug_reset),
    .RUNTEST(debug_runtest));

   genvar                       r;

   wire [3:0] m_enb = (we_d ? core_lsu_be : 4'hF);
   wire m_web = ce_d & shared_sel & we_d;
   logic i_emdio, o_emdio, oe_emdio, o_emdclk, sync, cooked, tx_enable_old, loopback, loopback2;

   logic rx_en0, rx_en1, rx_en2, rx_en3, rx_en4;
   
   generate for (r = 0; r < 4; r=r+1)
     RAMB16_S9_S9
     RAMB16_S9_S9_inst
       (
        .CLKA   ( debug_clk                ),     // Port A Clock
        .DOA    ( sharedmem_dout[r*8 +: 8] ),     // Port A 1-bit Data Output
        .ADDRA  ( debug_addr[12:2]         ),     // Port A 14-bit Address Input
        .DIA    ( debug_wdata[r*8 +:8]     ),     // Port A 1-bit Data Input
        .ENA    ( sharedmem_en[r]          ),     // Port A RAM Enable Input
        .SSRA   ( 1'b0                     ),     // Port A Synchronous Set/Reset Input
        .WEA    ( debug_we                 ),     // Port A Write Enable Input
        .CLKB   ( msoc_clk                 ),     // Port B Clock
        .DOB    ( shared_rdata[r*8 +: 8]   ),     // Port B 1-bit Data Output
        .ADDRB  ( core_lsu_addr[12:2]      ),     // Port B 14-bit Address Input
        .DIB    ( core_lsu_wdata[r*8 +: 8] ),     // Port B 1-bit Data Input
        .ENB    ( m_enb[r]                 ),     // Port B RAM Enable Input
        .SSRB   ( 1'b0                     ),     // Port B Synchronous Set/Reset Input
        .WEB    ( m_web                    )      // Port B Write Enable Input
        );
   endgenerate

   always @(negedge i_clk50)
    begin
        if (byte_sync ? rx_en4 : (loopback ? o_etx_en : i_erx_dv))
            begin
            full = &addr_tap;
            {rx_en0,rx_pair} <= loopback ? {o_etx_en,o_etxd} : {i_erx_dv,i_erxd[1:0]};
            rx_nxt = {rx_pair,rx_byte[15:2]};
            {rx_en1,rx_byte} <= {rx_en0,rx_nxt};
            if ((rx_nxt == 16'HD555) && (byte_sync == 0))
                begin
                byte_sync <= 1'b1;
                rx_wren <= 1'b1;
                addr_tap <= {addr_tap[13:2],2'b00};
                end
            else
                begin
                if (full == 0)
                    begin
                    nxt_addr = addr_tap+1;
                    addr_tap <= byte_sync ? nxt_addr : nxt_addr&3;
                    end
                rx_wren <= &addr_tap[1:0];
                end // else: !if((rx_nxt == 16'HD555) && (byte_sync == 0))
	    if (rx_wren)
	      begin
		 rx_byte_dly <= byte_sync ? rx_byte : 8'H55;
		 rx_en4 <= rx_en3;
		 rx_en3 <= rx_en2;
		 rx_en2 <= rx_en1;
	      end
            end
        else
            begin
            full = 1;
            addr_tap <= 0;
            rx_wren <= 0;
            byte_sync <= 0;
	    {rx_en4,rx_en3,rx_en2,rx_byte_dly} <= 11'H55;
            end
    end

   assign o_led[8] = rx_error_o;
   assign o_led[9] = rx_frame_o;
   assign mac_tx_byte_sent = &tx_frame_size[1:0];
   assign tx_frame_addr = tx_frame_size[12:2] - 7;
   
   framing framing_inst_0 (
			.rx_reset_i             ( ~clk_locked ),
			.tx_clock_i             ( i_clk50 ),
			.tx_reset_i             ( ~clk_locked ),
			.rx_clock_i             ( i_clk50 ),
			.mac_address_i          ( mac_address ),
			.tx_enable_i            ( tx_enable_i ),
			.tx_data_i              ( tx_data_i ),
			.tx_byte_sent_o         ( tx_byte_sent_o ),
			.tx_busy_o              ( tx_busy_o ),
			.tx_fcs_o               ( tx_fcs_o ),
			.rx_frame_o             ( rx_frame_o ),
			.rx_data_o              ( rx_data_o0 ),
			.rx_byte_received_o     ( rx_byte_received_o ),
			.rx_error_o             ( rx_error_o ),
			.rx_frame_size_o        ( rx_frame_size_o ),
			.rx_fcs_o               ( rx_fcs_o ),
			.mii_tx_enable_o        ( mac_tx_enable ),
			.mii_tx_gap_o           ( mac_tx_gap ),
			.mii_tx_data_o          ( mac_tx_data ),
			.mii_tx_byte_sent_i     ( mac_tx_byte_sent ),
			.mii_rx_frame_i         ( rx_en2|rx_en4 ),
			.mii_rx_data_i          ( rx_byte_dly ),
			.mii_rx_byte_received_i ( rx_wren ),
			.mii_rx_error_i         ( loopback ? o_etx_er : i_erx_er )
		);

   always @(posedge i_clk50)
     begin
     if (tx_enable_i & (tx_enable_old == 0))
       tx_frame_size <= 0;
     if (tx_busy_o)
        begin
           tx_frame_size <= tx_frame_size + 1;
	   o_etxd <= mac_tx_data >> {tx_frame_size[1:0],1'b0};
        end
     tx_enable_old <= tx_enable_i;
     if (rx_frame_o & rx_byte_received_o)
	rx_packet_length <= rx_frame_size_o;
     end

   assign o_etx_en = mac_tx_enable & ~mac_tx_gap;
   assign o_etx_er = 1'b0;
   assign o_erstn = clk_locked;

   logic [10:0] rx_addr;
   logic [7:0] rx_data;
   logic rx_ena, rx_wea;

   always @(posedge i_clk50) if (rx_byte_received_o)
     begin
	rx_data_o <= rx_data_o2;
	rx_data_o2 <= rx_data_o1;
	rx_data_o1 <= rx_data_o0;
     end
   
   always @* casez({loopback2,cooked})
     2'b1?: begin
	rx_addr = tx_frame_size[12:2];
	rx_data = mac_tx_data;
	rx_ena = tx_busy_o;
	rx_wea = mac_tx_byte_sent;
        end
     2'b01: begin
	rx_addr = rx_frame_size_o;
	rx_data = rx_data_o;
	rx_ena = rx_frame_o;
	rx_wea = rx_byte_received_o;
        end
     2'b00: begin
	rx_addr = addr_tap[12:2];
	rx_data = rx_byte[7:0];
	rx_ena = full==0;
	rx_wea = rx_wren;
        end
     endcase
           
   RAMB16_S9_S36 RAMB16_S1_inst_rx (
                                    .CLKA(i_clk50),               // Port A Clock
                                    .CLKB(msoc_clk),              // Port A Clock
                                    .DOA(),                       // Port A 9-bit Data Output
                                    .ADDRA(rx_addr),              // Port A 11-bit Address Input
                                    .DIA(rx_data),                // Port A 8-bit Data Input
                                    .DIPA(1'b0),                  // Port A parity unused
                                    .SSRA(1'b0),                  // Port A Synchronous Set/Reset Input
                                    .ENA(rx_ena),                 // Port A RAM Enable Input
                                    .WEA(rx_wea),                 // Port A Write Enable Input
                                    .DOB(tap_rdata_pkt),          // Port B 32-bit Data Output
                                    .DOPB(),                      // Port B parity unused
                                    .ADDRB(core_lsu_addr[10:2]),  // Port B 9-bit Address Input
                                    .DIB(core_lsu_wdata),         // Port B 32-bit Data Input
                                    .DIPB(4'b0),                  // Port B parity unused
                                    .ENB(ce_d & tap_sel & (core_lsu_addr[12:11]==2'b00)),
                                                                  // Port B RAM Enable Input
                                    .SSRB(1'b0),                  // Port B Synchronous Set/Reset Input
                                    .WEB(we_d)                    // Port B Write Enable Input
                                    );

   RAMB16_S9_S36 RAMB16_S1_inst_tx (
                                   .CLKA(i_clk50),               // Port A Clock
                                   .CLKB(msoc_clk),              // Port A Clock
                                   .DOA(tx_data_i),              // Port A 9-bit Data Output
                                   .ADDRA(tx_frame_addr),        // Port A 11-bit Address Input
                                   .DIA(8'b0),                   // Port A 8-bit Data Input
                                   .DIPA(1'b0),                  // Port A parity unused
                                   .SSRA(1'b0),                  // Port A Synchronous Set/Reset Input
                                   .ENA(tx_enable_i),            // Port A RAM Enable Input
                                   .WEA(1'b0),                   // Port A Write Enable Input
                                   .DOB(tap_wdata_pkt),          // Port B 32-bit Data Output
                                   .DOPB(),                      // Port B parity unused
                                   .ADDRB(core_lsu_addr[10:2]),  // Port B 9-bit Address Input
                                   .DIB(core_lsu_wdata),         // Port B 32-bit Data Input
                                   .DIPB(4'b0),                  // Port B parity unused
                                   .ENB(ce_d & tap_sel & (core_lsu_addr[12:11]==2'b10)),
				                                 // Port B RAM Enable Input
                                   .SSRB(1'b0),                  // Port B Synchronous Set/Reset Input
                                   .WEB(we_d)                    // Port B Write Enable Input
                                   );

assign io_emdio = (oe_emdio ? o_emdio : 1'bz);
assign i_emdio = io_emdio;
assign o_emdc = o_emdclk;
assign o_erefclk = i_clk50_quad;

always @(posedge msoc_clk or negedge clk_locked)
  if (!clk_locked)
    begin
    mac_address <= 48'H230100890702;
    tx_packet_length <= 0;
    tx_enable_i <= 0;
    cooked <= 1'b0;
    loopback <= 1'b0;
    loopback2 <= 1'b0;
    oe_emdio <= 1'b0;
    o_emdio <= 1'b0;
    o_emdclk <= 1'b0;
    end
   else
     begin
     if (tap_sel&we_d&core_lsu_addr[11])
     case(core_lsu_addr[5:2])
        0: mac_address[31:0] <= core_lsu_wdata;
        1: {loopback2,loopback,cooked,mac_address[47:32]} <= core_lsu_wdata[18:0];
        2: begin tx_enable_i <= 1; tx_packet_length <= core_lsu_wdata; end
        3: tx_enable_i <= 0;
        4: begin {oe_emdio,o_emdio,o_emdclk} <= core_lsu_wdata[3:0]; end
        6: begin sync = 0; end
      endcase
      sync |= byte_sync;
      if (tx_busy_o && (tx_frame_size[12:2] > tx_packet_length))
          tx_enable_i <= 0;
     end

always @* casez(core_lsu_addr_dly[12:2])
    11'b01??????000 : tap_rdata = mac_address[31:0];
    11'b01??????001 : tap_rdata = {loopback2,loopback,cooked,mac_address[47:32]};
    11'b01??????010 : tap_rdata = {tx_frame_addr,tx_packet_length};
    11'b01??????011 : tap_rdata = {tx_fcs_o};
    11'b01??????100 : tap_rdata = {i_emdio,oe_emdio,o_emdio,o_emdclk};
    11'b01??????101 : tap_rdata = {rx_fcs_o};
    11'b01??????110 : tap_rdata = {sync};
    11'b01??????111 : tap_rdata = {rx_error_o,rx_packet_length};
    11'b00????????? : tap_rdata = tap_rdata_pkt;
    11'b10????????? : tap_rdata = tap_wdata_pkt;
    endcase
    
//----------------------------------------------------------------------------
//  Output     Output      Phase    Duty Cycle   Pk-to-Pk     Phase
//   Clock     Freq (MHz)  (degrees)    (%)     Jitter (ps)  Error (ps)
//----------------------------------------------------------------------------
// CLK_OUT1___200.000______0.000______50.0______102.086_____87.180
// CLK_OUT2____25.000______0.000______50.0______154.057_____87.180
// CLK_OUT3____50.000______0.000______50.0______132.683_____87.180
// CLK_OUT4____50.000_____90.000______50.0______132.683_____87.180
// CLK_OUT5___120.000______0.000______50.0______112.035_____87.180
// CLK_OUT6___100.000______0.000______50.0______115.831_____87.180

  clk_wiz_nexys4ddr_0 clk_gen
   (
   .clk_in1     ( clk_p         ), // 100 MHz onboard
   .clk_200     ( clk_200MHz    ), // 200 MHz
   .clk_25      ( msoc_clk      ), // 25 MHz (for minion SOC)
   .clk_50      ( i_clk50       ), // 50 MHz
   .clk_50_quad ( i_clk50_quad  ), // 50 MHz
   .clk_120     ( pxl_clk       ), // 120 MHz
   .clk_100     ( clk_100       ), // 100 MHz
    // Status and control signals
      .resetn      ( rst_top       ),
      .locked      ( clk_locked    )
      );
      
   minion_soc
     msoc (
         .*,
         .from_dip(i_dip),
         .to_led(o_led[7:0]),
         .rstn(clk_locked)
        );

reg [31:0] bcd_digits;

always @*
    casez(i_dip[1:0])
        2'b00: bcd_digits = debug_addr;
        2'b01: bcd_digits = debug_wdata;
        2'b10: bcd_digits = debug_dout;
        2'b11: bcd_digits = {debug_reset,debug_runtest,debug_we,debug_unused[1:0],debug_blocksel,debug_halt,debug_resume,debug_req};
    endcase
    
   wire [8*7-1:0] digits;
   wire           overflow;

   genvar i;

   generate
      for (i = 0; i < 8; i = i + 1) begin
         sevensegment
            u_seg(.in  (bcd_digits[(i+1)*4-1:i*4]),
                  .out (digits[(i+1)*7-1:i*7]));
      end
   endgenerate

   nexys4ddr_display
     #(.FREQ(25000000))
   u_display(.clk       (clk_100),
             .rst       (~clk_locked),
             .digits    (digits),
             .decpoints (8'b00000000),
             .CA        (CA),
             .CB        (CB),
             .CC        (CC),
             .CD        (CD),
             .CE        (CE),
             .CF        (CF),
             .CG        (CG),
             .DP        (DP),
             .AN        (AN));

endmodule // chip_top
`default_nettype wire
