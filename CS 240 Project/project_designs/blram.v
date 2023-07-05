module blram(clk, rst, i_we, i_addr, i_ram_data_in, o_ram_data_out);

parameter SIZE = 13, DEPTH = 8192;

input clk;
input rst;
input i_we;
input [SIZE-1:0] i_addr;
input [15:0] i_ram_data_in;
output reg [15:0] o_ram_data_out;

reg [15:0] memory[0:DEPTH-1];

always @(posedge clk) begin
  o_ram_data_out <= #1 memory[i_addr[SIZE-1:0]];
  if (i_we)
		memory[i_addr[SIZE-1:0]] <= #1 i_ram_data_in;
end 

initial begin
  `include "projectCPU2022_program.v"
end 

endmodule
