`timescale 1ns / 1ps

module datamem(
                input clk,
                input [31:0] dina,
                input [13:0] addra,
                input [0:0] wea,
                input [3:0] ena,
                output [31:0] douta,
                input [31:0] dinb,
                input [13:0] addrb,
                input [0:0] web,
                input [3:0] enb,
                output [31:0] doutb
                );

    reg [31:0] mem [16384:0];
    initial $readmemh("data.mem1", mem);

    wire [31:0] maska, maskb;

    always @(posedge clk) begin
       maska = { {8{ena[3]}}, {8{ena[2]}}, {8{ena[1]}}, {8{ena[0]}} };
       if (ena) begin
          if (wea) begin
              mem[addra] = dina & maska;
          end else begin
              douta = mem[addra] & maska;
         end
       end

       maskb = { {8{enb[3]}}, {8{enb[2]}}, {8{enb[1]}}, {8{enb[0]}} };
       if (enb) begin
          if (web) begin
              mem[addrb] = dinb & maskb;
          end else begin
              doutb = mem[addrb] & maskb;
          end
       end
    end
endmodule

module progmem(
                input clk,
                input [31:0] dina,
                input [13:0] addra,
                input [0:0] wea,
                input [3:0] ena,
                output [31:0] douta,
                input [31:0] dinb,
                input [13:0] addrb,
                input [0:0] web,
                input [3:0] enb,
                output [31:0] doutb
                );

    reg [31:0] mem [16384:0];
    initial $readmemh("code.mem1", mem);

    wire [31:0] maska, maskb;

    always @(posedge clk) begin
       maska = { {8{ena[3]}}, {8{ena[2]}}, {8{ena[1]}}, {8{ena[0]}} };
       if (ena) begin
          if (wea) begin
              mem[addra] = dina & maska;
          end else begin
              douta = mem[addra] & maska;
          end
       end

       maskb = { {8{enb[3]}}, {8{enb[2]}}, {8{enb[1]}}, {8{enb[0]}} };
       if (enb) begin
          if (web) begin
              mem[addrb] = dinb & maskb;
          end else begin
              doutb = mem[addrb] & maskb;
          end
       end
    end
endmodule
