// Copyright 2015 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

////////////////////////////////////////////////////////////////////////////////
// Engineer:       Antonio Pullini - pullinia@iis.ee.ethz.ch                  //
//                                                                            //
// Additional contributions by:                                               //
//                 Sven Stucki - svstucki@student.ethz.ch                     //
//                                                                            //
// Design Name:    RISC-V register file                                       //
// Project Name:   RI5CY                                                      //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Register file with 31x 32 bit wide registers. Register 0   //
//                 is fixed to 0. This register file is based on latches and  //
//                 is thus smaller than the flip-flop based register file.    //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module riscv_register_file
#(
  parameter ADDR_WIDTH    = 5,
  parameter DATA_WIDTH    = 32
)
(
  // Clock and Reset
  input  logic                   clk,
  input  logic                   rst_n,

  input  logic                   test_en_i,

  //Read port R1
  input  logic [ADDR_WIDTH-1:0]  raddr_a_i,
  output logic [DATA_WIDTH-1:0]  rdata_a_o,

  //Read port R2
  input  logic [ADDR_WIDTH-1:0]  raddr_b_i,
  output logic [DATA_WIDTH-1:0]  rdata_b_o,

  //Read port R3
  input  logic [ADDR_WIDTH-1:0]  raddr_c_i,
  output logic [DATA_WIDTH-1:0]  rdata_c_o,

  // Write port W1
  input  logic [ADDR_WIDTH-1:0]   waddr_a_i,
  input  logic [DATA_WIDTH-1:0]   wdata_a_i,
  input  logic                    we_a_i,

  // Write port W2
  input  logic [ADDR_WIDTH-1:0]   waddr_b_i,
  input  logic [DATA_WIDTH-1:0]   wdata_b_i,
  input  logic                    we_b_i
);

  localparam    NUM_WORDS = 2**ADDR_WIDTH;

  logic [DATA_WIDTH-1:0]      mem[NUM_WORDS];

  logic [NUM_WORDS-1:1]       waddr_onehot_a;
  logic [NUM_WORDS-1:1]       waddr_onehot_b, waddr_onehot_b_q;

  logic [NUM_WORDS-1:1]       mem_clocks;
  logic [DATA_WIDTH-1:0]      wdata_a_q;
  logic [DATA_WIDTH-1:0]      wdata_b_q;

  logic clk_int;

  int unsigned i;
  int unsigned j;
  int unsigned k;

  genvar x;
  genvar y;

  //-----------------------------------------------------------------------------
  //-- READ : Read address decoder RAD
  //-----------------------------------------------------------------------------
  assign rdata_a_o = mem[raddr_a_i];
  assign rdata_b_o = mem[raddr_b_i];
  assign rdata_c_o = mem[raddr_c_i];


  //-----------------------------------------------------------------------------
  // WRITE : SAMPLE INPUT DATA
  //---------------------------------------------------------------------------

  cluster_clock_gating CG_WE_GLOBAL
  (
    .clk_i     ( clk             ),
    .en_i      ( we_a_i | we_b_i ),
    .test_en_i ( test_en_i       ),
    .clk_o     ( clk_int         )
  );

  // use clk_int here, since otherwise we don't want to write anything anyway
  always_ff @(posedge clk_int, negedge rst_n)
  begin : sample_waddr
    if (~rst_n) begin
      wdata_a_q        <= '0;
      wdata_b_q        <= '0;
      waddr_onehot_b_q <= '0;
    end else begin
      if(we_a_i)
        wdata_a_q <= wdata_a_i;

      if(we_b_i)
        wdata_b_q <= wdata_b_i;

      waddr_onehot_b_q <= waddr_onehot_b;
    end
  end

  //-----------------------------------------------------------------------------
  //-- WRITE : Write Address Decoder (WAD), combinatorial process
  //-----------------------------------------------------------------------------
  always_comb
  begin : p_WADa
    for(i = 1; i < NUM_WORDS; i++)
    begin : p_WordItera
      if ( (we_a_i == 1'b1 ) && (waddr_a_i == i) )
        waddr_onehot_a[i] = 1'b1;
      else
        waddr_onehot_a[i] = 1'b0;
    end
  end

  always_comb
  begin : p_WADb
    for(j = 1; j < NUM_WORDS; j++)
    begin : p_WordIterb
      if ( (we_b_i == 1'b1 ) && (waddr_b_i == j) )
        waddr_onehot_b[j] = 1'b1;
      else
        waddr_onehot_b[j] = 1'b0;
    end
  end

  //-----------------------------------------------------------------------------
  //-- WRITE : Clock gating (if integrated clock-gating cells are available)
  //-----------------------------------------------------------------------------
  generate
    for(x = 1; x < NUM_WORDS; x++)
    begin : CG_CELL_WORD_ITER
      cluster_clock_gating CG_Inst
      (
        .clk_i     ( clk_int                               ),
        .en_i      ( waddr_onehot_a[x] | waddr_onehot_b[x] ),
        .test_en_i ( test_en_i                             ),
        .clk_o     ( mem_clocks[x]                         )
      );
    end
  endgenerate

  //-----------------------------------------------------------------------------
  //-- WRITE : Write operation
  //-----------------------------------------------------------------------------
  //-- Generate M = WORDS sequential processes, each of which describes one
  //-- word of the memory. The processes are synchronized with the clocks
  //-- ClocksxC(i), i = 0, 1, ..., M-1
  //-- Use active low, i.e. transparent on low latches as storage elements
  //-- Data is sampled on rising clock edge

  always_latch
  begin : latch_wdata
    // Note: The assignment has to be done inside this process or Modelsim complains about it
    mem[0] = '0;

    for(k = 1; k < NUM_WORDS; k++)
    begin : w_WordIter
      if(mem_clocks[k] == 1'b1)
        mem[k] = waddr_onehot_b_q[k] ? wdata_b_q : wdata_a_q;
    end
  end


endmodule
