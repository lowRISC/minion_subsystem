module pseudo_random_gen
(
  // Clock and Reset
  input  logic        clk,
  input  logic        rst,

  output reg        fault,
  output reg [7:0]  index
);

  reg [8:0] data_next;
  always_comb begin
    data_next = {fault, index};
    repeat(9) begin
      data_next = {(data_next[8]^data_next[4]), data_next[8:1]};
    end
  end

  always_ff @(posedge clk or negedge rst) begin
    if(!rst) begin
      index <= 9'h1ff;
      fault <= 0;
      $display("Fault injected rseted\n");
    end else begin
      index <= data_next[7:0];
      fault <= data_next[8];
      if(fault == 1)
        $display("Fault injected\n");
    end
  end

endmodule

module fault_injection_assist
(
  // Clock and Reset
  input  logic        clk,
  input  logic        rst,

  input  logic       finj_fault,
  input  logic [9:0] finj_index,

  //Core slave 1
  // Instruction memory interface
  input wire        instr_req_cls1_i,
  input wire [31:0] instr_addr_cls1_i,

  // Data memory interface
  input wire        data_req_cls1_i,
  input logic       data_we_cls1_i,
  input wire [3:0]  data_be_cls1_i,
  input wire [31:0] data_addr_cls1_i,
  input wire [31:0] data_wdata_cls1_i,

  // CPU Control Signals
  input wire       core_busy_cls1_i,

  //Core slave 1
  // Instruction memory interface
  input wire        instr_req_cls2_i,
  input wire [31:0] instr_addr_cls2_i,

  // Data memory interface
  input wire        data_req_cls2_i,
  input logic       data_we_cls2_i,
  input wire [3:0]  data_be_cls2_i,
  input wire [31:0] data_addr_cls2_i,
  input wire [31:0] data_wdata_cls2_i,

  // CPU Control Signals
  input wire       core_busy_cls2_i,

  //Core slave 1
  // Instruction memory interface
  output wire        instr_req_cls1_o,
  output wire [31:0] instr_addr_cls1_o,

  // Data memory interface
  output wire        data_req_cls1_o,
  output logic       data_we_cls1_o,
  output wire [3:0]  data_be_cls1_o,
  output wire [31:0] data_addr_cls1_o,
  output wire [31:0] data_wdata_cls1_o,

  // CPU Control Signals
  output wire       core_busy_cls1_o,

  //Core slave 1
  // Instruction memory interface
  output wire        instr_req_cls2_o,
  output wire [31:0] instr_addr_cls2_o,

  // Data memory interface
  output wire        data_req_cls2_o,
  output logic       data_we_cls2_o,
  output wire [3:0]  data_be_cls2_o,
  output wire [31:0] data_addr_cls2_o,
  output wire [31:0] data_wdata_cls2_o,

  // CPU Control Signals
  output wire       core_busy_cls2_o
);

//assign instr_addr_cls1_o = instr_addr_cls1_i;
//assign data_addr_cls1_o  = data_addr_cls1_i;

fault_injection_mux finj_mux_instr_req_cls1 (
  .sel(finj_fault),// & (finj_index == 1)),
  .in(instr_req_cls1_i),
  .out(instr_req_cls1_o)
);

//fault_injection_mux finj_mux_instr_addr_cls1 (
//  .sel(finj_fault & (finj_index == 2)),
//  .in(instr_addr_cls1_i[7]),
//  .out(instr_addr_cls1_o[7])
//);

//fault_injection_mux finj_mux_data_req_cls1 (
//  .sel(finj_fault & (finj_index == 4)),
//  .in(data_req_cls1_i),
//  .out(data_req_cls1_o)
//);

//fault_injection_mux finj_mux_data_addr_cls1 (
//  .sel(finj_fault & (finj_index == 8)),
//  .in(data_addr_cls1_i[7]),
//  .out(data_addr_cls1_o[7])
//);

endmodule

module fault_injection_mux (
  input  logic sel,

  input  logic in,
  output logic out
);

  always @(sel or in) begin
    if(sel == 0) begin
      out <= in;
    end else begin
      out <= !in;
      $display("Injecting error\n");
    end
  end
endmodule
