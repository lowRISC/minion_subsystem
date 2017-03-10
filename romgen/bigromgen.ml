open Printf
open Big_int

let romgen f width name (merge:bool) minimize (bigbuf:big_int array) idsarr =
  let verbose = false in
  let rwidth = 14 in
  let chunk = 1 lsl rwidth in
  let ramtot = ref 0 in
  let cnt = try int_of_string(Sys.getenv "BIGMEMCNT")-1 with _ -> (Array.length bigbuf - 1)/chunk in
  let rec log2 n = if n < 1 then 0 else 1 + log2(n lsr 1) in
  let topa = rwidth-1+(log2 cnt) in
  begin
    fprintf f "`timescale 10ns/10ns\n";
    fprintf f "\n";
    fprintf f "`ifdef %s_tb\n" name;
    fprintf f "\n";
    fprintf f "module tb();\n";
    fprintf f "\n";
    fprintf f "parameter topa = %d;\n" topa;
    fprintf f "parameter rwidth = %d;\n" rwidth;
    fprintf f "\n";
    fprintf f "reg   clk;\n";
    fprintf f "reg   [%d:0] dina;\n" (width-1);
    fprintf f "reg   [topa:0] addr, addr2;\n";
    fprintf f "reg   [0:0] we;\n";
    fprintf f "reg   [%d:0] en;\n" ((width+7)/8-1);
    fprintf f "reg   [%d:0] mem[0:(2<<topa)-1];\n" (width-1);
    fprintf f "wire  [%d:0] dout;\n" (width-1);
    fprintf f "\n";
    fprintf f "%s rom1(.clk(clk), .dina(din), .addra(addr), .wea(we), .douta(dout), .ena(en));\n" name;
    fprintf f "\n";
    fprintf f "   integer  i, last;\n";
    fprintf f "\n";
    fprintf f "   initial\n";
    fprintf f "      begin\n";
    fprintf f "	 clk = 0;\n";
    fprintf f "	 din = 0;\n";
    fprintf f "	 addr = 0;\n";
    fprintf f "	 we = 0;\n";
    fprintf f "	 en = -1;\n";
    fprintf f "	 for (i = 0; i < (2<<topa); i=i+1)\n";
    fprintf f "	    begin\n";
    fprintf f "	       #100 clk = 1;\n";
    fprintf f "	       #100 clk = 0;\n";
    fprintf f "	       mem[addr] = dout;\n";
    fprintf f "	       addr = addr + 1;\n";
    fprintf f "	       if (dout > 0) last = addr;\n";
    if verbose then 
      begin
	for offset = 0 to cnt do
	  fprintf f "	       $display(\"%%d: %%x\", i, rom1.douta%d);\n" offset;
	done;
	fprintf f "	       $display(\"%%d: %%x\", i, rom1.douta);\n";
      end;
    fprintf f "	    end;\n";
    if verbose then fprintf f "	 $display(\"last = %%d\", last);\n";
    fprintf f "\n";
    fprintf f "	 addr2 = 0;\n";
    fprintf f "	 en = 0;\n";
    fprintf f "	 for (i = 0; i <= last; i=i+1)\n";
    fprintf f "	    begin\n";
    fprintf f "	       #100 clk = 1;\n";
    fprintf f "	       #100 clk = 0;\n";
    fprintf f "	       $display(\"%%x\", mem[addr2]);\n";
    fprintf f "	       addr2 = addr2 + 1;\n";
    fprintf f "	    end;\n";
    fprintf f "	  end\n";
    fprintf f "   \n";
    fprintf f "endmodule\n";
    fprintf f "\n";
    fprintf f "`endif\n";
    fprintf f "\n";
    fprintf f "module %s(clk, dina, addra, wea, douta, ena, dinb, addrb, web, doutb, enb);\n" name;
    fprintf f "\n";
    fprintf f "parameter rwidth = %d;\n" rwidth;
    fprintf f "\n";
    fprintf f "input clk;\n";
    fprintf f "input [%d:0] dina;\n" (width-1);
    fprintf f "input [%d:0] addra;\n" topa;
    fprintf f "input [0:0] wea;\n";
    fprintf f "input [%d:0] ena;\n" ((width+7)/8-1);
    fprintf f "output [%d:0] douta;\n" (width-1);
    fprintf f "input [%d:0] dinb;\n" (width-1);
    fprintf f "input [%d:0] addrb;\n" topa;
    fprintf f "input [0:0] web;\n";
    fprintf f "input [%d:0] enb;\n" ((width+7)/8-1);
    fprintf f "output [%d:0] doutb;\n" (width-1);
    fprintf f "\n";
    fprintf f "reg read;\n";
    fprintf f "reg [rwidth-1:0] prevaddr;\n";
    if topa >= rwidth then fprintf f "wire [%d:0] ena = 1 << addra[%d:%d];\n" cnt topa rwidth;
    fprintf f "\n";
    if topa >= rwidth then
      begin
	fprintf f "reg [%d:0] douta;\n" (width-1);
	for offset = 0 to cnt do fprintf f "wire  [%d:0] douta%d;\n" (width-1) offset done;
	fprintf f "\n";
	fprintf f "reg [%d:%d] addr0;\n" topa rwidth;
	fprintf f "\n";
	fprintf f "always @(posedge clk)\n";
	fprintf f "     addr0 <= addr[%d:%d];\n\n" topa rwidth;
	fprintf f "always @(addr0";
	for offset = 0 to cnt do fprintf f " or douta%d" offset done;
        fprintf f ") case(addr0[%d:%d])\n" topa rwidth;
	for offset = 0 to cnt do fprintf f "\t%d'd%d: douta = douta%d;\n" (topa-rwidth+1) offset offset done;
	fprintf f "     endcase\n";
      end;
    for offset = 0 to cnt do
    for i=0 to width-1 do
      let ids n = if n < Array.length idsarr then idsarr.(n) else "" in
      let empty = ref true
      and full = ref true
      and init = Array.make_matrix 64 64 '0' in for j=0 to 63
	do
	  for k = 0 to 63
	  do
	    let m = ref 0 in
	    for l = 0 to 3
	    do
	      let adr = (63-k)*4+j*256+l+offset*chunk in
	      let sel = if adr < Array.length bigbuf then bigbuf.(adr) else zero_big_int
	      and mask1 = shift_left_big_int unit_big_int i
	      and mask2 = 1 lsl l in
	      m := !m lor (if compare_big_int (and_big_int sel mask1) zero_big_int <> 0 then mask2 else 0);
	    done;
	    init.(j).(k) <- "0123456789ABCDEF".[!m];
            if !m <> 0 then empty := false;
            if !m <> 15 then full := false;
	  done;
	done;
      if (not (!empty) && not (!full)) || not minimize then
	begin
	  incr ramtot;
	  fprintf f "\n";
	  fprintf f "   RAMB16_S1_S1 #(\n";
	  fprintf f "      // The following INIT_xx declarations specify the initial contents of the RAM\n";
	  for j=0 to 63
	  do
	    fprintf f "      .INIT_%.2X(256'h" j;
	    for k = 0 to 63 do output_char f init.(j).(k); done;
	    output_char f ')';
	    if j<63 then fprintf f ",";
	    output_char f '\n';
	  done;
	  fprintf f "   ) RAMB16_S1_S1_inst_%d_%d_%d (\n" width offset i;
	  fprintf f "      .CLKA(clk),      // Port A Clock\n";
	  fprintf f "      .DOA(douta%s[%d]),  // Port A 1-bit Data Output\n" (if topa >= rwidth then string_of_int offset else "") i;
	  fprintf f "      .ADDRA(addra[%d:0]),    // Port A 14-bit Address Input\n" (rwidth-1);
	  fprintf f "      .DIA(dina[%d]),   // Port A 1-bit Data Input\n" i;
	  fprintf f "      .ENA(%sena[%d]),    // Port A RAM Enable Input\n" (if topa >= rwidth then "ena["^string_of_int offset^"] & " else "") (i/8);
	  fprintf f "      .SSRA(1'b0),     // Port A Synchronous Set/Reset Input\n";
	  fprintf f "      .WEA(wea),         // Port A Write Enable Input\n";
	  fprintf f "      .CLKB(clk),      // Port B Clock\n";
	  fprintf f "      .DOB(doutb%s[%d]),  // Port B 1-bit Data Output\n" (if topa >= rwidth then string_of_int offset else "") i;
	  fprintf f "      .ADDRB(addrb[%d:0]),    // Port B 14-bit Address Input\n" (rwidth-1);
	  fprintf f "      .DIB(dinb[%d]),   // Port B 1-bit Data Input\n" i;
	  fprintf f "      .ENB(%senb[%d]),    // Port B RAM Enable Input\n" (if topa >= rwidth then "ena["^string_of_int offset^"] & " else "") (i/8);
	  fprintf f "      .SSRB(1'b0),     // Port B Synchronous Set/Reset Input\n";
	  fprintf f "      .WEB(web)         // Port B Write Enable Input\n";
	  fprintf f "   ); // %s\n" (ids i);
	  if !empty then
	    begin
	      fprintf f "/* assign douta%s[%d] = 1'b0; */ // %s: Port A 1-bit Data Output\n" (if topa >= rwidth then string_of_int offset else "") i (ids i);
	    end;
	  if !full then
	    begin
	      fprintf f "/* assign douta[%d] = 1'b1; */ // %s: Port A 1-bit Data Output\n" i (ids i);
	    end
	end
      else if !empty then
	begin
	  fprintf f "assign douta%s[%d] = 1'b0; // %s: Port A 1-bit Data Output\n" (if topa >= rwidth then string_of_int offset else "") i (ids i);
	end
      else
	begin
	  fprintf f "assign douta[%d] = 1'b1; // %s: Port A 1-bit Data Output\n" i (ids i);
	end
    done;
    fprintf f "\n";
    done;
    fprintf f "endmodule\n";
    !ramtot
  end
