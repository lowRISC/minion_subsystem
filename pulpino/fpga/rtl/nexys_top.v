module nexys_top(
  LD_o,
  sw_i,
  btn_i,
  oled_sclk_io,
  oled_sdin_io,
  oled_dc_o,
  oled_res_o,
  oled_vbat_o,
  oled_vdd_o,
  ext_tck_i,
  ext_trstn_i,
  ext_tdi_i,
  ext_tms_i,
  ext_tdo_o
  );

  output  [7:0] LD_o;
  input   [7:0] sw_i;
  input   [4:0] btn_i;
  inout         oled_sclk_io;
  inout         oled_sdin_io;
  output        oled_dc_o;
  output        oled_res_o;
  output        oled_vbat_o;
  output        oled_vdd_o;

  input         ext_tck_i;
  input         ext_trstn_i;
  input         ext_tdi_i;
  input         ext_tms_i;
  output        ext_tdo_o;

  wire [31:0] end_of_operation;
  wire [31:0] fetch_enable;
  wire        ps7_clk;
  wire        ps7_rst_n;
  wire        ps7_rst_clking_n;

  wire        ref_clk_i;               // input
  wire        rst_ni;                  // input
  wire        fetch_en;                // input

  wire        tck_i;                   // input
  wire        trst_ni;                 // input
  wire        tms_i;                   // input
  wire        td_i;                    // input
  wire        td_o;                    // output

  wire        spi_mosi;
  wire        spi_miso;
  wire        spi_sck;
  wire        spi_cs;

  wire [31:0] gpio_dir;                // output
  wire [31:0] gpio_in;                 // input
  wire [31:0] gpio_in_ps7;             // output of ps7 => to pulpino
  wire [31:0] gpio_out;                // output

  wire        scl_oen;
  wire        scl_in;
  wire        scl_out;
  wire        sda_oen;
  wire        sda_in;
  wire        sda_out;

  reg   [7:0] LD_q;

  wire        clking_axi_aclk;    // input
  wire        clking_axi_aresetn; // input
  wire [10:0] clking_axi_awaddr;  // input
  wire  [2:0] clking_axi_awprot;  // input
  wire        clking_axi_awvalid; // input
  wire        clking_axi_awready; // output
  wire [31:0] clking_axi_wdata;   // input
  wire  [3:0] clking_axi_wstrb;   // input
  wire        clking_axi_wvalid;  // input
  wire        clking_axi_wready;  // output
  wire  [1:0] clking_axi_bresp;   // output
  wire        clking_axi_bvalid;  // output
  wire        clking_axi_bready;  // input
  wire [10:0] clking_axi_araddr;  // input
  wire  [2:0] clking_axi_arprot;  // input
  wire        clking_axi_arvalid; // input
  wire        clking_axi_arready; // output
  wire [31:0] clking_axi_rdata;   // output
  wire  [1:0] clking_axi_rresp;   // output
  wire        clking_axi_rvalid;  // output
  wire        clking_axi_rready;  // input

  wire        uart_tx;            // output
  wire        uart_rx;            // input

  // GPIO signals
  always @(posedge s_clk_pulpino or negedge s_rstn_pulpino)
  begin
    if (~s_rstn_pulpino)
      LD_q <= 8'b0;
    else
      LD_q <= gpio_out[15:8];
  end

  assign LD_o = LD_q;

  assign gpio_in[7:0]   = sw_i;
  assign gpio_in[15:8]  = 8'b0;
  assign gpio_in[20:16] = btn_i;
  assign gpio_in[31:21] = gpio_in_ps7[31:21];

  // I2C for LCD
  assign oled_sclk_io = (~scl_oen) ? scl_out : 1'bz;
  assign scl_in       = oled_sclk_io;
  assign oled_sdin_io = (~sda_oen) ? sda_out : 1'bz;
  assign sda_in       = oled_sdin_io;

  assign oled_vbat_o  = 1'b1;
  assign oled_vdd_o   = 1'b1;

  assign oled_dc_o    = gpio_out[16];
  assign oled_res_o   = gpio_out[17];

  clk_rst_gen clk_rst_gen_i (
    .ref_clk_i               ( ref_clk_i               ),
    .rst_ni                  ( rst_ni                  ),

    .clking_axi_aclk         ( clking_axi_aclk         ),
    .clking_axi_aresetn      ( clking_axi_aresetn      ),
    .clking_axi_awaddr       ( clking_axi_awaddr       ),
    .clking_axi_awvalid      ( clking_axi_awvalid      ),
    .clking_axi_awready      ( clking_axi_awready      ),
    .clking_axi_wdata        ( clking_axi_wdata        ),
    .clking_axi_wstrb        ( clking_axi_wstrb        ),
    .clking_axi_wvalid       ( clking_axi_wvalid       ),
    .clking_axi_wready       ( clking_axi_wready       ),
    .clking_axi_bresp        ( clking_axi_bresp        ),
    .clking_axi_bvalid       ( clking_axi_bvalid       ),
    .clking_axi_bready       ( clking_axi_bready       ),
    .clking_axi_araddr       ( clking_axi_araddr       ),
    .clking_axi_arvalid      ( clking_axi_arvalid      ),
    .clking_axi_arready      ( clking_axi_arready      ),
    .clking_axi_rdata        ( clking_axi_rdata        ),
    .clking_axi_rresp        ( clking_axi_rresp        ),
    .clking_axi_rvalid       ( clking_axi_rvalid       ),
    .clking_axi_rready       ( clking_axi_rready       ),

    .rstn_pulpino_o          ( s_rstn_pulpino          ),
    .clk_pulpino_o           ( s_clk_pulpino           )
);

  // PULPino SoC
  pulpino pulpino_wrap_i (
    .clk               ( s_clk_pulpino  ),
    .rst_n             ( s_rstn_pulpino ),

    .fetch_enable_i    ( fetch_en       ),

    .tck_i             ( tck_i          ),
    .trstn_i           ( trst_ni        ),
    .tms_i             ( tms_i          ),
    .tdi_i             ( td_i           ),
    .tdo_o             ( td_o           ),

    .spi_clk_i         ( spi_sck        ),
    .spi_cs_i          ( spi_cs         ),
    .spi_mode_o        (                ),
    .spi_sdi0_i        ( spi_mosi       ),
    .spi_sdi1_i        ( 1'b0           ),
    .spi_sdi2_i        ( 1'b0           ),
    .spi_sdi3_i        ( 1'b0           ),
    .spi_sdo0_o        ( spi_miso       ),
    .spi_sdo1_o        (                ),
    .spi_sdo2_o        (                ),
    .spi_sdo3_o        (                ),

    .spi_master_clk_o  (                ),
    .spi_master_csn0_o (                ),
    .spi_master_csn1_o (                ),
    .spi_master_csn2_o (                ),
    .spi_master_csn3_o (                ),
    .spi_master_mode_o (                ),
    .spi_master_sdi0_i ( 1'b0           ),
    .spi_master_sdi1_i ( 1'b0           ),
    .spi_master_sdi2_i ( 1'b0           ),
    .spi_master_sdi3_i ( 1'b0           ),
    .spi_master_sdo0_o (                ),
    .spi_master_sdo1_o (                ),
    .spi_master_sdo2_o (                ),
    .spi_master_sdo3_o (                ),

    .scl_i             ( scl_in         ),
    .scl_o             ( scl_out        ),
    .scl_oen_o         ( scl_oen        ),
    .sda_i             ( sda_in         ),
    .sda_o             ( sda_out        ),
    .sda_oen_o         ( sda_oen        ),

    .gpio_in           ( gpio_in        ),
    .gpio_out          ( gpio_out       ),
    .gpio_dir          ( gpio_dir       ),

    .uart_tx           ( uart_tx        ), // output
    .uart_rx           ( uart_rx        ), // input
    .uart_rts          (                ), // output
    .uart_dtr          (                ), // output
    .uart_cts          ( 1'b0           ), // input
    .uart_dsr          ( 1'b0           )  // input
  );

endmodule
