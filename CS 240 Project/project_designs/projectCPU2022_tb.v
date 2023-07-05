`timescale 1ns / 1ps

// This tb accompanies projectCPU2022_test.asm. Since that program is obtained by porting
// a VSCPU asm program to projectCPU, the memCheck functions below are based on
// VSCPU instructions.

// YOU SHOULD SUCCESSFULLY PASS:
// SIMULATION AND SYNTHESIS

module projectCPU_tb;

reg clk;
initial begin
  clk = 1;
  forever
    #5 clk = ~clk;
end

reg wrEnReg;

always @(posedge clk) begin
  wrEnReg <= wrEn;
end

integer ff;
reg rst;
initial begin
  ff = $fopen("outputLog.txt", "w");
  // $dumpvars;
  rst = 1;
  repeat (10) @(posedge clk);
  rst <= #1 0;
  repeat (1000) @(posedge clk);
  repeat (1000) begin
    @(posedge clk);
    if (instrCount == 322) begin
      PCCheck(321, "'321: BZ 2'");
      $fwrite(ff, "Total Tests = 31, Total Tests Done = %d, Total Tests Passed = %d, Total Tests Failed = %d, Wrong PC = %d, Unexpected Checks = %d", testCount, correctCount, errorCount, pcErrorCount, unexpCount);
      $display("Total Tests = 31, Total Tests Done = %d, Total Tests Passed = %d, Total Tests Failed = %d, Wrong PC = %d, Unexpected Checks = %d", testCount, correctCount, errorCount, pcErrorCount, unexpCount);
      if ((testCount == 31) && (correctCount == 31) && (errorCount == 0) && (pcErrorCount == 0) && (unexpCount == 0)) begin
        $fwrite(ff, "Simulation Succeessfully Completed");
        $display("Simulation Succeessfully Completed");
        $finish;
      end
      $fwrite(ff, "Simulation Failed");
      $display("Simulation Failed");
      $fclose(ff); 
      $finish;
    end
  end
  $fwrite(ff, "Simulation finished due to Time Limit.\nTotal Tests = 31, Total Tests Done = %d,\nTotal Tests Passed = %d, Total Tests Failed = %d,\nWrong PC = %d, Unexpected Checks = %d", testCount, correctCount, errorCount, pcErrorCount, unexpCount);
  $display("Simulation finished due to Time Limit.\nTotal Tests = 31, Total Tests Done = %d,\nTotal Tests Passed = %d, Total Tests Failed = %d,\nWrong PC = %d, Unexpected Checks = %d", testCount, correctCount, errorCount, pcErrorCount, unexpCount);
  $fclose(ff);
  $finish;
end

wire [12:0] addr_toRAM;
wire [15:0] data_toRAM, data_fromRAM;
wire [12:0] PC;
wire [15:0] W;

projectCPU2022 projectCPU(
  .clk(clk),
  .rst(rst),
  .wrEn(wrEn),
  .data_fromRAM(data_fromRAM),
  .addr_toRAM(addr_toRAM),
  .data_toRAM(data_toRAM),
  .PC(PC), // Added as an output for TB purposes
  .W(W) // Added as an output for TB purposes
);

blram blram(
  .clk(clk),
  .rst(rst),
  .i_we(wrEn),
  .i_addr(addr_toRAM),
  .i_ram_data_in(data_toRAM),
  .o_ram_data_out(data_fromRAM)
);

reg [8:0] instrCount = 0;
reg [8:0] testCount = 0;
reg [8:0] correctCount = 0;
reg [8:0] errorCount = 0;
reg [8:0] pcErrorCount = 0;
reg [8:0] unexpCount = 0;

always @(PC) begin
  if (instrCount == 0) begin
    //do nothing, just avoiding an unexpected check.
  end else begin
    case(instrCount - 1)
      0: WCheck(5, "'0: CP2W 3'");
      1: PCCheck(5, "'1: BZ 2'");
      
      // ADD Test 0 -- Regular
      5,7,8,9: begin end
      6: WCheck(37, "'6: ADD 11'");
      
      // ADD Test 1 -- Subtraction
      20,22,23,24: begin end
      21: WCheck(16, "'21: ADD 26'");
      
      // NOR Test 0
      30,32,33,34: begin end
      31: WCheck(16'hFFF8, "'31: NOR 36'");
      
      // NOR Test 1
      40,42,43,44: begin end
      41: WCheck(0, "'41: NOR 46'");
      
      // SRL Test 0 -- Shift Right
      50,52,53,54: begin end
      51: WCheck(8, "'51: SRL 56'");
      
      // SRL Test 1 -- Shift Left
      60,62,63,64: begin end
      61: WCheck(128, "'61: SRL 66'");
      
      // SRL Test 2 -- Shift Left lower4bits
      70,72,73,74: begin end
      71: WCheck(192, "'71: SRL 76'");
      
      // RRL Test 0 -- Rotate Right
      80,82,83,84: begin end
      81: WCheck(16'hDF00, "'81: RRL 86'");
      
      // RRL Test 1 -- Rotate Left
      90,92,93,94: begin end
      91: WCheck(16'hEEFB, "'91: RRL 96'");
      
      // RRL Test 2 -- Rotate Left lower4bits
      100,102,103,104: begin end
      101: WCheck(16'hEEFB, "'101: RRL 106'");
      
      // CMP Test 0 -- W < A
      110,112,113,114: begin end
      111: WCheck(16'hFFFF, "'111: CMP 116'");
      
      // CMP Test 1 -- W == A
      120,122,123,124: begin end
      121: WCheck(0, "'121: CMP 126'");
      
      // CMP Test 2 -- W > A
      130,132,133,134: begin end
      131: WCheck(1, "'131: CMP 136'");
      
      // CP2W and CPfW Test 0
      140: WCheck(152, "'140: CP2W 145'");
      141: memCheck(146, 152, "'141: CPfW 146'");
      142: memCheck(147, 152, "'142: CPfW 147'");
      143,144: begin end
      
      // BZ Test 0 - Skip
      150: begin end
      151: PCCheck(160, "'151: BZ 156'");
      152: printWrongPC("'152: CP2W 157'"); //ERROR
      153: printWrongPC("'153: CP2W 158'"); //ERROR
      154: printWrongPC("'154: BZ 2'"); //ERROR
      
      // BZ Test 1 - Don't Skip
      160,163,164: begin end
      161: PCCheck(162, "'161: BZ 166'");
      162: WCheck(16'h600D, "'162: CP2W 167'");
      
      // Indirect Adressing Tests
      
      // ADD Indirect Test
      170,171,172,174,175,176: begin end
      173: WCheck(16, "'173: ADD 0'");
      
      // NOR Indirect Test
      190,191,192,194,195,196: begin end
      193: WCheck(16'hF000, "'193: NOR 0'");
      
      // SRL Indirect Test
      210,211,212,214,215,216: begin end
      213: WCheck(16'h00C0, "'213: SRL 0'");
      
      // RRL Indirect Test
      230,231,232,234,235,236: begin end
      233: WCheck(16'hDEC0, "'233: RRL 0'");
      
      // CMP Indirect Test
      250,251,252,254,255,256: begin end
      253: WCheck(1, "'253: CMP 0'");
      
      // BZ Indirect Test
      270,271,272,276,277: begin end
      273: PCCheck(290, "'273: BZ 0'");
      274: printWrongPC("'274: CP2W 281'"); //ERROR
      275: printWrongPC("'275: CPfW 282'"); //ERROR
      
      // CP2W Indirect Test
      290,291,292,294,295,296: begin end
      293: WCheck(16'hFEED, "'293: CP2W 0'");
      
      // CPfW Indirect Test
      310,311,312,314,315: begin end
      313: memCheck(318, 16'hDEAF, "'313: CPfW 0'");
      
      320: WCheck(321, "'320: CP2W 322'");
      321: begin
        PCCheck(321, "'321: BZ 2'");
        $fwrite(ff, "Total Tests = 31, Total Tests Done = %d, Total Tests Passed = %d, Total Tests Failed = %d, Wrong PC = %d, Unexpected Checks = %d", testCount, correctCount, errorCount, pcErrorCount, unexpCount);
        $fclose(ff);
        $display("Total Tests = 31, Total Tests Done = %d, Total Tests Passed = %d, Total Tests Failed = %d, Wrong PC = %d, Unexpected Checks = %d", testCount, correctCount, errorCount, pcErrorCount, unexpCount);
        $finish;
      end
      default: begin
        $display("Unexpected CHECK at time %d ns!", $time);
        unexpCount = unexpCount + 1;
      end	
    endcase
  end
  instrCount = PC + 1;
end

task memCheck;
input [12:0] memLocation;
input [15:0] expectedValue;
input [143:0] instMnemonic;
begin
  testCount = testCount + 1;
  #2;
  if(blram.memory[memLocation] !== expectedValue) begin
    $fwrite(
      ff,"Error Found at instrCount %d,\t Test: %s,\t Time: %d ns,\t RAM Addr %d: expected %d, received %d\n",
      instrCount -1, instMnemonic, $time, memLocation, expectedValue, blram.memory[memLocation]
    );
    $display(
      "Error Found at instrCount %d,\t Test: %s,\t Time: %d ns,\t RAM Addr %d: expected %h, received %h",
    instrCount -1, instMnemonic, $time, memLocation, expectedValue, blram.memory[memLocation]
    );
    errorCount = errorCount +1;
  end else begin
    $fwrite(
      ff,"Test Correct at instrCount %d,\t Test: %s,\t Time: %d ns,\t RAM Addr %d: expected %d, received %d\n",
      instrCount -1, instMnemonic, $time, memLocation, expectedValue, blram.memory[memLocation]
    );
    $display(
      "Test Correct at instrCount %d,\t Test: %s,\t Time: %d ns,\t RAM Addr %d: expected %h, received %h",
    instrCount -1, instMnemonic, $time, memLocation, expectedValue, blram.memory[memLocation]
    );
    correctCount = correctCount + 1;
  end
end
endtask

task PCCheck;
input [31:0] PCExpected;
input [143:0] instMnemonic;
begin
  testCount = testCount + 1;
  #2;
  if((PC !== PCExpected) || (wrEnReg)) begin
    $fwrite(
      ff,"Error Found at instrCount %d,\t Test: %s,\t Time: %d ns,\t expected PC=%d, observed PC=%d\n",
      instrCount -1, instMnemonic, $time, PCExpected, PC
    );
    $display(
      "Error Found at instrCount %d,\t Test: %s,\t Time: %d ns,\t expected PC=%d, observed PC=%d",
      instrCount -1, instMnemonic, $time, PCExpected, PC
    );
    
    $fwrite(ff,"If the expected PC and observed PC are the same, you must be writing something to the memory when you should not.");
    $display("If the expected PC and observed PC are the same, you must be writing something to the memory when you should not.");
    
    errorCount = errorCount + 1;
  end else begin
    $fwrite(
      ff,"Test Correct at instrCount %d,\t Test: %s,\t Time: %d ns,\t expected PC=%d, observed PC=%d\n",
      instrCount -1, instMnemonic, $time, PCExpected, PC
    );
    $display(
      "Test Correct at instrCount %d,\t Test: %s,\t Time: %d ns,\t expected PC=%d, observed PC=%d",
      instrCount -1, instMnemonic, $time, PCExpected, PC
    );
    correctCount = correctCount + 1;
  end
end
endtask

task printWrongPC;
input [143:0] instMnemonic;
begin
  $fwrite("This line should not have been executed, the CPU should not jump to this instruction: %s,\t Time: %d ns", instMnemonic, $time);
  $display("This line should not have been executed, the CPU should not jump to this instruction: %s,\t Time: %d ns", instMnemonic, $time);
  pcErrorCount = pcErrorCount + 1;
end
endtask

task WCheck;
input [15:0] expectedValue;
input [143:0] instMnemonic;
begin
  testCount = testCount + 1;
  #2;
  if((W !== expectedValue) || (wrEnReg)) begin
    $fwrite(
      ff,"Error Found at instrCount %d,\t Test: %s,\t Time: %d ns,\t expected W=%d, observed W=%d\n",
      instrCount -1, instMnemonic, $time, expectedValue, W
    );
    $display(
      "Error Found at instrCount %d,\t Test: %s,\t Time: %d ns,\t expected W=%h, observed W=%h",
      instrCount -1, instMnemonic, $time, expectedValue, W
    );
    
    $fwrite(ff,"If the expected W and observed W are the same, you must be writing something to the memory when you should not.");
    $display("If the expected W and observed W are the same, you must be writing something to the memory when you should not.");
    
    errorCount = errorCount + 1;
  end else begin
    $fwrite(
      ff,"Test Correct at instrCount %d,\t Test: %s,\t Time: %d ns,\t expected W=%d, observed W=%d\n",
      instrCount -1, instMnemonic, $time, expectedValue, W
    );
    $display(
      "Test Correct at instrCount %d,\t Test: %s,\t Time: %d ns,\t expected W=%h, observed W=%h",
      instrCount -1, instMnemonic, $time, expectedValue, W
    );
    correctCount = correctCount + 1;
  end
end
endtask

endmodule
