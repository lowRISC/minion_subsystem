open Printf;;

let romgen f width name offset (merge:bool) minimize fake_model (bigbuf:int64 array) =
  let ramtot = ref 0 in
  begin
    fprintf f "`timescale 1ns/1ps\n";
    fprintf f "\n";
    fprintf f "`ifdef %s_tb\n" name;
    fprintf f "\n";
    fprintf f "module tb();\n";
    fprintf f "\n";
    fprintf f "parameter rwidth = 14;\n";
    fprintf f "\n";
    fprintf f "reg   clk;\n";
    fprintf f "reg   [%d:0] din;\n" (width-1);
    fprintf f "reg   [rwidth-1:0] addr, addr2;\n";
    fprintf f "reg   [0:0] we;\n";
    fprintf f "reg   [%d:0] en;\n" ((width+7)/8-1);
    fprintf f "reg   [%d:0] mem[0:(2<<rwidth-1)-1];\n" (width-1);
    fprintf f "wire  [%d:0] dout;\n" (width-1);
    fprintf f "\n";
    fprintf f "%s rom1(.clk(clk), .din(din), .addr(addr), .we(we), .dout(dout), .en(en)%s);\n"
      name
      (if fake_model then ", .gsr(gsr)" else "");
    fprintf f "\n";
    fprintf f "   integer  i, last;\n";
    fprintf f "\n";
    fprintf f "   initial\n";
    fprintf f "      begin\n";
    fprintf f "	 clk = 0;\n";
    fprintf f "	 din = 0;\n";
    fprintf f "	 addr = 0;\n";
    fprintf f "	 we = 0;\n";
    fprintf f "	 en = 1;\n";
    fprintf f "	 for (i = 0; i < (2<<rwidth-1); i=i+1)\n";
    fprintf f "	    begin\n";
    fprintf f "	       #1000 clk = 1;\n";
    fprintf f "	       #1000 clk = 0;\n";
    fprintf f "	       mem[addr] = dout;\n";
    fprintf f "	       addr = addr + 1;\n";
    fprintf f "	       if (dout > 0) last = addr;\n";
    fprintf f "	    end;\n";
    fprintf f "\n";
    fprintf f "	 addr2 = 0;\n";
    fprintf f "	 en = 0;\n";
    fprintf f "	 for (i = 0; i <= last; i=i+1)\n";
    fprintf f "	    begin\n";
    fprintf f "	       #1000 clk = 1;\n";
    fprintf f "	       #1000 clk = 0;\n";
    fprintf f "	       if (i%%8 == 0)\n";
    fprintf f "	         begin\n";
    fprintf f "	           if (i > 0) $display;\n";
    fprintf f "	           $write(\"%%X \", addr2);\n";
    fprintf f "	         end;\n";
    fprintf f "	       $write(\" %%X\", mem[addr2]);\n";
    fprintf f "	       addr2 = addr2 + 1;\n";
    fprintf f "	    end;\n";
    fprintf f "     $display;\n";
    fprintf f "	  end\n";
    fprintf f "   \n";
    fprintf f "endmodule\n";
    fprintf f "\n";
    fprintf f "`endif\n";
    fprintf f "\n";
    fprintf f "module %s(clk, din, addr, we, dout, en%s);\n" name (if fake_model then ", gsr" else "");
    fprintf f "\n";
    fprintf f "parameter rwidth = 14;\n";
    fprintf f "parameter debug_verbose = 0;\n";
    fprintf f "\n";
    fprintf f "input clk;\n";
    fprintf f "input [%d:0] din;\n" (width-1);
    fprintf f "input [rwidth-1:0] addr;\n";
    fprintf f "input [0:0] we;\n";
    fprintf f "input [%d:0] en;\n" ((width+7)/8-1);
    fprintf f "output [%d:0] dout;\n" (width-1);
    if fake_model then
      begin
	fprintf f "input gsr;\n";
      end;
    fprintf f "\n";
    fprintf f "reg read;\n";
    fprintf f "reg [rwidth-1:0] prevaddr;\n";
    fprintf f "\n";
    if merge then begin
      fprintf f "// synopsys translate_off\n";
      fprintf f "\n";
      fprintf f "function [7:0] merge;\n";
      fprintf f "\n";
      fprintf f "	input [31:0] mergeaddr;\n";
      fprintf f "\n";
      fprintf f "	reg [%d:0] merge1;\n" (width-1);
      fprintf f "	reg [4:0] shift1;\n";
      fprintf f "\n";
      fprintf f "	begin\n";
      fprintf f "	merge1 = {\n";
      for i = width -1 downto 0 do
	fprintf f "		  RAMB16_S1_inst_%d.mem[mergeaddr[rwidth+1:2]]%s\n" i (if i > 0 then "," else "");
      done;
      fprintf f "};\n";
      fprintf f "	shift1 = {mergeaddr[1:0],3'b000};\n";
      fprintf f "	merge = merge1 >> shift1;\n";
      fprintf f "	end\n";
      fprintf f "\n";
      fprintf f "endfunction\n";
      fprintf f "\n";
      fprintf f "task memdebug;\n";
      fprintf f "\n";
      fprintf f "	input [31:0] addr;\n";
      fprintf f "\n";
      fprintf f "	integer i;\n";
      fprintf f "	reg[7:0] c;\n";
      fprintf f "\n";
      fprintf f "	begin\n";
      fprintf f "	c = \" \";\n";
      fprintf f "	for (i = 0; (i < 32) && (c >= 32); i=i+1)\n";
      fprintf f "	        begin\n";
      fprintf f "	        c = merge(addr+i);\n";
      fprintf f "		$write(\"%%c\", c);\n";
      fprintf f "	        end\n";
      fprintf f "	$display;\n";
      fprintf f "	end\n";
      fprintf f "\n";
      fprintf f "endtask\n";
      fprintf f "\n";
      fprintf f "// synopsys translate_on\n"
    end;
    fprintf f "\n";
    fprintf f "always @(negedge clk) if (debug_verbose)\n";
    fprintf f "	begin\n";
    fprintf f "	if (%s(en > 0))\n" (if fake_model then "(!gsr) && " else "");
    fprintf f "		begin\n";
    fprintf f "		if (we)\n";
    fprintf f "			$display(\"Wrote %%X to address %%X\", din, addr);\n";
    fprintf f "		else\n";
    fprintf f "			begin\n";
    fprintf f "			prevaddr <= addr;\n";
    fprintf f "			read <= 1;\n";
    fprintf f "			end\n";
    fprintf f "		end\n";
    fprintf f "	else if (%s(read))\n" (if fake_model then "(!gsr) && " else "");
    fprintf f "		begin\n";
    fprintf f "			$display(\"Read %%X from address %%X\", dout, prevaddr);\n";
    fprintf f "			prevaddr <= 0;\n";
    fprintf f "			read <= 0;\n";
    fprintf f "		end\n";
    fprintf f "	end\n";
    for i=0 to width-1 do
      let empty = ref minimize
      and init = Array.make_matrix 64 64 '0' in for j=0 to 63
	do
	  for k = 0 to 63
	  do
	    let m = ref 0 in
	    for l = 0 to 3
	    do
	      let adr = (63-k)*4+j*256+l+offset in
	      let sel = if adr < Array.length bigbuf then bigbuf.(adr) else Int64.zero
	      and mask1 = Int64.shift_left Int64.one i
	      and mask2 = 1 lsl l in
	      m := !m lor (if (Int64.logand sel mask1) <> Int64.zero then mask2 else 0);
	    done;
	    init.(j).(k) <- "0123456789ABCDEF".[!m];
            if !m <> 0 then empty := false;
	  done;
	done;
      if not (!empty) then
	begin
	  incr ramtot;
	  fprintf f "\n";
	  fprintf f "   RAMB16_S1 #(\n";
	  if fake_model then
	    begin
	      fprintf f "// synopsys translate_off\n";
	      fprintf f "      .rwidth(rwidth),  // RAM addr width (14 = Xilinx compatible)\n";
	      fprintf f "// synopsys translate_on\n";
	    end;
	  fprintf f "      .INIT(1'b0),  // Value of output RAM registers on Port A at startup\n";
	  fprintf f "      .SRVAL(1'b0), // Port A output value upon SSR assertion\n";
	  fprintf f "      .WRITE_MODE(\"NO_CHANGE\"), // WRITE_FIRST, READ_FIRST or NO_CHANGE\n";
	  fprintf f "\n";
	  fprintf f "      // The following INIT_xx declarations specify the initial contents of the RAM\n";
	  for j=0 to 63
	  do
	    fprintf f "      .INIT_%.2X(256'h" j;
	    for k = 0 to 63 do output_char f init.(j).(k); done;
	    output_char f ')';
	    if j<63 then fprintf f ",";
	    output_char f '\n';
	  done;
	  fprintf f "   ) RAMB16_S1_inst_%d (\n"  i;
	  fprintf f "      .CLK(clk),      // Port A Clock\n";
	  if fake_model then
	    begin
	      fprintf f "// synopsys translate_off\n";
	      fprintf f "      .GSR(gsr),      // Simulation of global reset\n";
	      fprintf f "// synopsys translate_on\n";
	    end;
	  fprintf f "      .DO(dout[%d]),  // Port A 1-bit Data Output\n" i;
	  fprintf f "      .ADDR(addr),    // Port A 14-bit Address Input\n";
	  fprintf f "      .DI(din[%d]),   // Port A 1-bit Data Input\n" i;
	  fprintf f "      .EN(en[%d]),    // Port A RAM Enable Input\n" (i/8);
	  fprintf f "      .SSR(1'b0),     // Port A Synchronous Set/Reset Input\n";
	  fprintf f "      .WE(we)         // Port A Write Enable Input\n";
	  fprintf f "   );\n";
	end
      else
	fprintf f "assign dout[%d] = 1'b0;  // Port A 1-bit Data Output\n" i;
    done;
    fprintf f "\n";
    fprintf f "endmodule\n";
    !ramtot
  end
