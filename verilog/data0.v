module datamem(clk, dina, addra, wea, douta, ena, dinb, addrb, web, doutb, enb);

parameter rwidth = 14;

input clk;
input [31:0] dina;
input [13:0] addra;
input [0:0] wea;
input [3:0] ena;
output [31:0] douta;
input [31:0] dinb;
input [13:0] addrb;
input [0:0] web;
input [3:0] enb;
output [31:0] doutb;

   reg [31:0] mem [(1<<rwidth) -1:0]; // instantiate memory
   reg [rwidth-1:0] ra, rb;                 // register read address
   
   // read operation
   always @(posedge clk)
     if (ena)
       begin
	  ra <= addra;
	  if (wea) mem[addra] <= dina;
       end
   
   assign douta = mem[ra];
   assign doutb = mem[rb];
   
   // write operation
   always@(posedge clk)
     if (enb)
       begin
	  rb <= addrb;
	  if (web) mem[addrb] <= dinb;
       end

   initial
     $readmemh("/local/scratch/jrrk2/minion_subsystem/software/bootstrap/data.mem1", mem);
   
endmodule   
