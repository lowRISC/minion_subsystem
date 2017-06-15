`default_nettype wire

  module crc32_tb();

   reg [7:0] 	 data;
   reg [31:0] 	 crc;
   wire [31:0] 	 newcrc;

   crc32_wrapper dut(
   .data(data),
   .oldcrc(crc),
   .crc(newcrc));
   
   initial
     begin
	crc = {32{1'b1}};
	data = 8'b0;
	#1
	  $display("crc = %b, data = %b, newcrc = %b", crc, data, newcrc);
     end
   
endmodule 
