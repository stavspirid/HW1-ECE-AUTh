module regfile #(parameter DATAWIDTH = 32)
  (
  input clk, write,
  input [4:0] readReg1, readReg2, writeReg, 
  input [DATAWIDTH-1:0] writeData, 
  output reg [DATAWIDTH-1:0] readData1, readData2
  );
  
  reg  [DATAWIDTH-1:0] registers [DATAWIDTH-1:0]; // maybe [31:0] registers [DATAWIDTH-1:0]
  integer i;
  wire [DATAWIDTH-1:0] temp_read1, temp_read2;
  
  // Initialize all 32 registers to 0
  initial begin
    for (i = 0; i < DATAWIDTH; i = i + 1) begin
      registers[i] = 32'b0;
    end
  end
  
  always @(posedge clk) begin
    if(write) begin
      registers[writeReg] = writeData;
      if(readReg1 != writeReg) begin
        readData1 = registers[readReg1];
      end
      if(readReg2 != writeReg) begin
        readData2 = registers[readReg2];
      end
    end
  end

endmodule
