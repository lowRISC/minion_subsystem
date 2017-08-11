// Copyright 2015 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`define OKAY   2'b00
`define EXOKAY 2'b01
`define SLVERR 2'b10
`define DECERR 2'b11

module coremem
  (
   // Clock and Reset
   input logic  clk_i,
   input logic  rst_ni,

   input logic  data_req_i,
   output logic data_gnt_o,
   output logic data_rvalid_o,
   input logic  data_we_i,
   output logic CE, WE
   );

   logic        aw_valid_o;
   logic        w_valid_o;
   logic        b_valid_i;
   logic        ar_valid_o;
   logic        r_valid_i;

   enum         logic [2:0] { IDLE, READ_WAIT, WRITE_WAIT } CS, NS;

   assign CE = aw_valid_o | ar_valid_o;
   assign WE = aw_valid_o;

   // main FSM
   always_comb
     begin
        NS         = CS;
        data_gnt_o    = 1'b0;
        data_rvalid_o      = 1'b0;

        aw_valid_o = 1'b0;
        ar_valid_o = 1'b0;

        case (CS)
          // wait for a request to come in from the core
          IDLE: begin
             // the same logic is also inserted in READ_WAIT and WRITE_WAIT, if you
             // change it here, take care to change it there too!
             if (data_req_i)
               begin
                  // send address over aw channel for writes,
                  // over ar channels for reads
                  data_gnt_o = 1'b1;

                  if (data_we_i)
                    begin
                       aw_valid_o = 1'b1;

                       NS = WRITE_WAIT;
                    end else begin
                       ar_valid_o = 1'b1;

                       NS = READ_WAIT;
                    end
               end else begin
                  NS = IDLE;
               end
          end

          // we have sent the address and data and just wait for the write data to
          // be done
          WRITE_WAIT:
            begin
               if (b_valid_i)
                 begin
                    data_rvalid_o = 1'b1;

                    NS = IDLE;
                 end
            end

          // we wait for the read response, address has been sent successfully
          READ_WAIT:
            begin
               if (r_valid_i)
                 begin
                    data_rvalid_o     = 1'b1;

                    NS = IDLE;
                 end
            end

          default:
            begin
               NS = IDLE;
            end
        endcase
     end

   // registers
   always_ff @(posedge clk_i, negedge rst_ni)
     begin
        if (~rst_ni)
          begin
             CS     <= IDLE;
             r_valid_i <= 1'b0;
             b_valid_i <= 1'b0;
          end
        else
          begin
             CS     <= NS;
             r_valid_i <= data_gnt_o && ar_valid_o;
             b_valid_i <= data_gnt_o && aw_valid_o;
          end
     end

endmodule
