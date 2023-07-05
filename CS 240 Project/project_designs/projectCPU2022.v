module projectCPU2022(
  clk,
  rst,
  wrEn,
  data_fromRAM,
  addr_toRAM,
  data_toRAM,
  PC,
  W
);

input clk, rst;

input [15:0] data_fromRAM;
output [15:0] data_toRAM;
output wrEn;

// 12 can be made smaller so that it fits in the FPGA
output [12:0] addr_toRAM;
output [12:0] PC; // This has been added as an output for TB purposes
output [15:0] W; // This has been added as an output for TB purposes

// Your design goes in here

endmodule
