`default_nettype wire

module crc32_wrapper(
   input [7:0] 	     data,
   input [31:0]      oldcrc,
   input [31:0]      tx_frame_check_sequence,
   output reg [31:0]     fcs, 
   output reg [31:0] crc);
   
    function [31:0] update_crc32;
        input [31:0] old_crc;
        input [7:0] input0;
        reg [7:0] data_out;
        reg 	 feedback;
        reg [31:0] poly, new_crc;
       
        integer 	 i;
       
        begin
	  poly = (1<<26)|(1<<23)|(1<<22)|(1<<16)|
		   (1<<12)|(1<<11)|(1<<10)|(1<<8)|(1<<7)|(1<<5)|(1<<4)|(1<<2)|(1<<1)|(1<<0);
	  new_crc = old_crc;
	  for (i = 0; i < 8; i=i+1)
	    begin
	       feedback = new_crc[31] ^ input0[i];
	       new_crc = feedback ? {new_crc[30:0],1'b0} ^ poly : {new_crc[30:0],1'b0};
	       $display("i = %d, Feedback = %b, poly = %b, newcrc = %b", i, feedback, poly, new_crc);
	    end
	   update_crc32 = new_crc;
	end
       
    endfunction 

    function [7:0] fcs_output_byte;
       input [31:0] fcs;
       input [31:0] byteno;
       reg [31:0] reversed;
       integer 	  i;
       
       begin
	  for (i = 0; i < 32; i=i+1)
	    reversed[31-i] = fcs[i];
	  fcs_output_byte = ~(reversed >> {byteno,3'b000});
       end
    endfunction 
   
    always @ ( oldcrc or data or tx_frame_check_sequence)
      begin
	 crc = update_crc32(oldcrc, data);
	 fcs[7:0] = fcs_output_byte(tx_frame_check_sequence, 0);
	 fcs[15:8] = fcs_output_byte(tx_frame_check_sequence, 1);
	 fcs[23:16] = fcs_output_byte(tx_frame_check_sequence, 2);
	 fcs[31:24] = fcs_output_byte(tx_frame_check_sequence, 3);
      end
   
endmodule 
