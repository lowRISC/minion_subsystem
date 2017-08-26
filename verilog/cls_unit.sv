module cls_cmp_unit
(
  // Clock and Reset
  input  logic        clk,
  input  logic        rst,

  output logic        fault,
  output logic        valid,

  // Instruction memory interface
  input  logic        instr_req_ms,
  input  logic [31:0] instr_addr_ms,

  // Data memory interface
  input  logic        data_req_ms,
  input  logic        data_we_ms,
  input  logic [3:0]  data_be_ms,
  input  logic [31:0] data_addr_ms,
  input  logic [31:0] data_wdata_ms,

  // CPU Control Signals
  input  logic        core_busy_ms,

  // Instruction memory interface
  input  logic        instr_req_sl1,
  input  logic [31:0] instr_addr_sl1,

  // Data memory interface
  input  logic        data_req_sl1,
  input  logic        data_we_sl1,
  input  logic [3:0]  data_be_sl1,
  input  logic [31:0] data_addr_sl1,
  input  logic [31:0] data_wdata_sl1,

  // CPU Control Signals
  input  logic        core_busy_sl1,

  // Instruction memory interface
  input  logic        instr_req_sl2,
  input  logic [31:0] instr_addr_sl2,

  // Data memory interface
  input  logic        data_req_sl2,
  input  logic        data_we_sl2,
  input  logic [3:0]  data_be_sl2,
  input  logic [31:0] data_addr_sl2,
  input  logic [31:0] data_wdata_sl2,

  // CPU Control Signals
  input  logic        core_busy_sl2
);

wire [2:0] core_data_req  = { data_req_ms, data_req_sl1, data_req_sl2 };
wire [2:0] core_instr_req = { instr_req_ms, instr_req_sl1, instr_req_sl2 };

wire [2:0] core_data_we   = { data_we_ms, data_we_sl1, data_we_sl2 };

always @(*)
  if (!rst) begin
	   fault <= 0;
     $display("CMP in rst\n");
	end else begin

    if(core_data_req != 0 &&
                core_data_req != 3'b111) begin
      fault = 1;
      $display("Error in data req\n");
    end else if(core_data_req != 0 &&
                (data_addr_ms != data_addr_sl1 ||
                 data_addr_ms != data_addr_sl2)) begin
      fault <= 1;
      $display("Error in data address\n");
    end else if(core_data_req != 0 &&
                (core_data_we != 3'b000 && core_data_we != 3'b111)) begin
      fault <= 1;
      $display("Error in data we\n");
    end else if(core_data_req != 0 &&
                (core_data_we == 3'b111 &&
                (data_wdata_ms != data_wdata_sl1 ||
                 data_wdata_ms != data_wdata_sl2))) begin
      fault <= 1;
      $display("Error in data write\n");
    end else if(core_instr_req != 0 &&
       core_instr_req != 3'b111) begin
      fault = 1;
      $display("Error in instruction req\n");
    end else if(core_instr_req != 0 &&
                (instr_addr_ms != instr_addr_sl1 ||
                 instr_addr_ms != instr_addr_sl2)) begin
      fault = 1;
      $display("Error in instruction address\n");
    end else begin
      fault = 0;
    end
  end

endmodule

module cls_handler_unit
(
  input  wire clk,
  input  wire rst_i,

  input  wire fault,
  output reg  rst_o
);

reg [1:0] state = WORKING;

parameter WORKING  = 2'b00, FAULT_DETECTED = 2'b01, RST_CYCLE = 2'b11 ;

always @(negedge rst_i or posedge clk) begin
  if (!rst_i) begin
     rst_o <= rst_i;
     state <= WORKING;
     $display("In reset\n");
  end else begin
    if(state == WORKING && fault) begin
      rst_o <= 0;
      state <= FAULT_DETECTED;
      $display("Fault detected, lets reset everything\n");
    end else if (state == FAULT_DETECTED) begin
      state <= RST_CYCLE;
      rst_o <= 0;
      $display("Wait for it...g\n");
    end else if (state == RST_CYCLE) begin
      state <= WORKING;
      rst_o <= 1;
      $display("Back to normal\n");
    end else if(state == WORKING) begin
      rst_o <= 1;
      state <= WORKING;
      //$display("Dont worry be happy\n");
    end
  end
end

endmodule
