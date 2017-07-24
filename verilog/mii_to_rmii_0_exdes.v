// File mii_to_rmii_0_exdes.vhd translated with vhd2vl v2.0 VHDL to Verilog RTL translator
// Copyright (C) 2001 Vincenzo Liguori - Ocean Logic Pty Ltd - http://www.ocean-logic.com
// Modifications (C) 2006 Mark Gonzales - PMC Sierra Inc
// 
// vhd2vl comes with ABSOLUTELY NO WARRANTY
// ALWAYS RUN A FORMAL VERIFICATION TOOL TO COMPARE VHDL INPUT TO VERILOG OUTPUT 
// 
// This is free software, and you are welcome to redistribute it under certain conditions.
// See the license file license.txt included with the source for details.

//Example design Top
// file: exdes_top.vhd
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
//----------------------------------------------------------------------------
// User entered comments
//----------------------------------------------------------------------------
// This is a self-desigined TOP Wrapper developed for MII to RMII Example Design
//
//----------------------------------------------------------------------------

module mii_to_rmii_0_exdes(
clk_50,
clk_100,
locked,
sw,
eth_rstn,
eth_crsdv,
eth_refclk,
eth_txd,
eth_txen,
eth_rxd,
eth_rxerr,
eth_mdc,
phy_mdio_i,
phy_mdio_o,
phy_mdio_t,
atg_done,
Led,
s_axi_aclk,
s_axi_aresetn,
s_axi_awaddr,
s_axi_awvalid,
s_axi_awready,
s_axi_wdata,
s_axi_wstrb,
s_axi_wvalid,
s_axi_wready,
s_axi_bresp,
s_axi_bvalid,
s_axi_bready,
s_axi_araddr,
s_axi_arvalid,
s_axi_arready,
s_axi_rdata,
s_axi_rresp,
s_axi_rvalid,
s_axi_rready,
m_axi_lite_ch1_awaddr,
m_axi_lite_ch1_awprot,
m_axi_lite_ch1_awvalid,
m_axi_lite_ch1_awready,
m_axi_lite_ch1_wdata,
m_axi_lite_ch1_wstrb,
m_axi_lite_ch1_wvalid,
m_axi_lite_ch1_wready,
m_axi_lite_ch1_bresp,
m_axi_lite_ch1_bvalid,
m_axi_lite_ch1_bready,
m_axi_lite_ch1_araddr,
m_axi_lite_ch1_arvalid,
m_axi_lite_ch1_arready,
m_axi_lite_ch1_rdata,
m_axi_lite_ch1_rvalid,
m_axi_lite_ch1_rready,
m_axi_lite_ch1_rresp
);

input clk_50;
input clk_100;
input locked;
input[15:0] sw;
// SMSC ethernet PHY
output eth_rstn;
input eth_crsdv;
output eth_refclk;
output[1:0] eth_txd;
output eth_txen;
input[1:0] eth_rxd;
input eth_rxerr;
output eth_mdc;
input phy_mdio_i;
output phy_mdio_o;
output phy_mdio_t;
output atg_done;
output[15:0] Led;
input s_axi_aclk;
output s_axi_aresetn;
input[12:0] s_axi_awaddr;
input s_axi_awvalid;
output s_axi_awready;
input[31:0] s_axi_wdata;
input[3:0] s_axi_wstrb;
input s_axi_wvalid;
output s_axi_wready;
output[1:0] s_axi_bresp;
output s_axi_bvalid;
input s_axi_bready;
input[12:0] s_axi_araddr;
input s_axi_arvalid;
output s_axi_arready;
output[31:0] s_axi_rdata;
output[1:0] s_axi_rresp;
output s_axi_rvalid;
input s_axi_rready;
output[31:0] m_axi_lite_ch1_awaddr;
output[2:0] m_axi_lite_ch1_awprot;
output m_axi_lite_ch1_awvalid;
input m_axi_lite_ch1_awready;
output[31:0] m_axi_lite_ch1_wdata;
output[3:0] m_axi_lite_ch1_wstrb;
output m_axi_lite_ch1_wvalid;
input m_axi_lite_ch1_wready;
input[1:0] m_axi_lite_ch1_bresp;
input m_axi_lite_ch1_bvalid;
output m_axi_lite_ch1_bready;
output[31:0] m_axi_lite_ch1_araddr;
output m_axi_lite_ch1_arvalid;
input m_axi_lite_ch1_arready;
input[31:0] m_axi_lite_ch1_rdata;
input m_axi_lite_ch1_rvalid;
output m_axi_lite_ch1_rready;
input[1:0] m_axi_lite_ch1_rresp;

wire   clk_50;
wire   clk_100;
wire   locked;
wire  [15:0] sw;
wire   eth_rstn;
wire   eth_crsdv;
wire   eth_refclk;
wire  [1:0] eth_txd;
wire   eth_txen;
wire  [1:0] eth_rxd;
wire   eth_rxerr;
wire   eth_mdc;
wire   phy_mdio_i;
wire   phy_mdio_o;
wire   phy_mdio_t;
wire   atg_done;
reg  [15:0] Led;
wire   s_axi_aclk;
wire   s_axi_aresetn;
wire  [12:0] s_axi_awaddr;
wire   s_axi_awvalid;
wire   s_axi_awready;
wire  [31:0] s_axi_wdata;
wire  [3:0] s_axi_wstrb;
wire   s_axi_wvalid;
wire   s_axi_wready;
wire  [1:0] s_axi_bresp;
wire   s_axi_bvalid;
wire   s_axi_bready;
wire  [12:0] s_axi_araddr;
wire   s_axi_arvalid;
wire   s_axi_arready;
wire  [31:0] s_axi_rdata;
wire  [1:0] s_axi_rresp;
wire   s_axi_rvalid;
wire   s_axi_rready;
wire  [31:0] m_axi_lite_ch1_awaddr;
wire  [2:0] m_axi_lite_ch1_awprot;
wire   m_axi_lite_ch1_awvalid;
wire   m_axi_lite_ch1_awready;
wire  [31:0] m_axi_lite_ch1_wdata;
wire  [3:0] m_axi_lite_ch1_wstrb;
wire   m_axi_lite_ch1_wvalid;
wire   m_axi_lite_ch1_wready;
wire  [1:0] m_axi_lite_ch1_bresp;
wire   m_axi_lite_ch1_bvalid;
wire   m_axi_lite_ch1_bready;
wire  [31:0] m_axi_lite_ch1_araddr;
wire   m_axi_lite_ch1_arvalid;
wire   m_axi_lite_ch1_arready;
wire  [31:0] m_axi_lite_ch1_rdata;
wire   m_axi_lite_ch1_rvalid;
wire   m_axi_lite_ch1_rready;
wire  [1:0] m_axi_lite_ch1_rresp;


wire  phy_tx_en;
wire [3:0] phy_rst_n;
wire [3:0] phy_tx_data;
wire [3:0] phy_tx_clk;
wire  phy_rx_clk;
wire [3:0] phy_col;
wire [31:0] phy_crs;
wire [1:0] phy_dv;
wire [1:0] phy_rx_er;
wire [3:0] phy_rx_data;
wire [31:0] rmii2phy_tx_en;
wire [1:0] rmii2phy_txd;
wire [32:0] const0;
reg [1:0] Count;
wire [3:0] exdes_resetn;
wire  local_rst;
wire [31:0] atg_status;
wire  s_out_d1_cdc_to;
//attribute DONT_TOUCH of s_out_d1_cdc_to : signal is "true";
wire  s_out_d2;
wire  prmry_in_xored;
wire  p_in_d1_cdc_from;
wire  phy_mdc;
wire  zero;

  assign zero = 1'b 0;
  assign eth_txen = rmii2phy_tx_en;
  assign eth_txd = rmii2phy_txd;
  assign eth_rstn = locked;
  assign eth_refclk = clk_50;
  assign eth_mdc = phy_mdc;
  assign s_axi_aresetn = exdes_resetn;
  always @(atg_status or sw) begin
    case(sw[0] )
    1'b 0 : begin
      Led <= atg_status[15:0] ;
    end
    1'b 1 : begin
      Led <= atg_status[31:16] ;
    end
    default : begin
      Led <= 16'b 0000000000000000;
    end
    endcase
  end

  always @(posedge phy_tx_clk) begin
    if(((locked == 1'b 0) || (sw[1]  == 1'b 1))) begin
      Count <= 2'b 00;
    end
    else begin
      if(((locked == 1'b 1) && (Count != 2'b 11))) begin
        Count <= Count + 1;
      end
      else begin
        Count <= Count;
      end
    end
  end

  assign local_rst = Count == 2'b 11 ? 1'b 1 : 1'b 0;
  FDR #(
      .INIT(1'b 0))
  REG_P_IN_cdc_from(
      .Q(p_in_d1_cdc_from),
    .C(phy_tx_clk),
    .D(local_rst),
    .R(zero));

  FDR #(
      .INIT(1'b 0))
  REG_P_IN2_cdc_to(
      .Q(s_out_d1_cdc_to),
    .C(clk_100),
    .D(p_in_d1_cdc_from),
    .R(zero));

  FDR #(
      .INIT(1'b 0))
  P_IN_CROSS2SCNDRY_s_out_d2(
      .Q(exdes_resetn),
    .C(clk_100),
    .D(s_out_d1_cdc_to),
    .R(zero));

  axi_traffic_gen_0 ATG_SRC(
      .s_axi_aclk(s_axi_aclk),
    .s_axi_aresetn(exdes_resetn),
    .m_axi_lite_ch1_awaddr(m_axi_lite_ch1_awaddr),
    .m_axi_lite_ch1_awprot(),
    .m_axi_lite_ch1_awvalid(m_axi_lite_ch1_awvalid),
    .m_axi_lite_ch1_awready(m_axi_lite_ch1_awready),
    .m_axi_lite_ch1_wdata(m_axi_lite_ch1_wdata),
    .m_axi_lite_ch1_wstrb(m_axi_lite_ch1_wstrb),
    .m_axi_lite_ch1_wvalid(m_axi_lite_ch1_wvalid),
    .m_axi_lite_ch1_wready(m_axi_lite_ch1_wready),
    .m_axi_lite_ch1_bresp(m_axi_lite_ch1_bresp),
    .m_axi_lite_ch1_bvalid(m_axi_lite_ch1_bvalid),
    .m_axi_lite_ch1_bready(m_axi_lite_ch1_bready),
    .m_axi_lite_ch1_araddr(m_axi_lite_ch1_araddr),
    .m_axi_lite_ch1_arvalid(m_axi_lite_ch1_arvalid),
    .m_axi_lite_ch1_arready(m_axi_lite_ch1_arready),
    .m_axi_lite_ch1_rdata(m_axi_lite_ch1_rdata),
    .m_axi_lite_ch1_rvalid(m_axi_lite_ch1_rvalid),
    .m_axi_lite_ch1_rready(m_axi_lite_ch1_rready),
    .m_axi_lite_ch1_rresp(m_axi_lite_ch1_rresp),
    .done(atg_done),
    .status(atg_status));

  axi_ethernetlite_0 ETH_SRC(
      .s_axi_aclk(s_axi_aclk),
    .s_axi_aresetn(exdes_resetn),
    .ip2intc_irpt(),
    .s_axi_awaddr(s_axi_awaddr[12:0] ),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awready(s_axi_awready),
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wstrb(s_axi_wstrb),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wready(s_axi_wready),
    .s_axi_bresp(s_axi_bresp),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bready(s_axi_bready),
    .s_axi_araddr(s_axi_araddr[12:0] ),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_arready(s_axi_arready),
    .s_axi_rdata(s_axi_rdata),
    .s_axi_rresp(s_axi_rresp),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rready(s_axi_rready),
    .phy_tx_clk(phy_tx_clk),
    .phy_rx_clk(phy_rx_clk),
    .phy_crs(phy_crs),
    .phy_dv(phy_dv),
    .phy_rx_data(phy_rx_data),
    .phy_col(phy_col),
    .phy_rx_er(phy_rx_er),
    .phy_rst_n(phy_rst_n),
    .phy_tx_en(phy_tx_en),
    .phy_tx_data(phy_tx_data),
    .phy_mdio_i(phy_mdio_i),
    .phy_mdio_o(phy_mdio_o),
    .phy_mdio_t(phy_mdio_t),
    .phy_mdc(phy_mdc));

  mii_to_rmii_0 DUT(
      .rst_n(locked),
    .ref_clk(clk_50),
    .mac2rmii_tx_en(phy_tx_en),
    .mac2rmii_txd(phy_tx_data),
    .mac2rmii_tx_er(zero),
    .rmii2mac_tx_clk(phy_tx_clk),
    .rmii2mac_rx_clk(phy_rx_clk),
    .rmii2mac_col(phy_col),
    .rmii2mac_crs(phy_crs),
    .rmii2mac_rx_dv(phy_dv),
    .rmii2mac_rx_er(phy_rx_er),
    .rmii2mac_rxd(phy_rx_data),
    .phy2rmii_crs_dv(rmii2phy_tx_en),
    .phy2rmii_rx_er(zero),
    .phy2rmii_rxd(rmii2phy_txd),
    .rmii2phy_txd(rmii2phy_txd),
    .rmii2phy_tx_en(rmii2phy_tx_en));


endmodule
