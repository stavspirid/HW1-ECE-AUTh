`include "alu.v"
`include "regfile.v"

module datapath #(parameter [31:0] INITIAL_PC = 32'h00400000)
  (
    input wire clk, 
    input wire rst, 
    input wire [31:0] instr, 
    input wire PCSrc, 
    input wire ALUSrc, 
    input wire RegWrite, 
    input wire MemToReg, 
    input wire [3:0] ALUCtrl,
    input wire loadPC,
    input wire [31:0] dReadData,
    output wire [31:0] PC, 
    output wire Zero,
    output reg [31:0] dAddress, 
    output reg [31:0] dWriteData, 
    output reg [31:0] WriteBackData
	);
  
//   wire [6:0] control_instr = instr[6:0];
//   wire [4:0] readReg1_instr = instr[19:15];
//   wire [4:0] readReg2_instr = instr[24:20];
//   wire [4:0] writeReg_instr = instr[11:7];
  wire [31:0] readData1, readData2;
  reg [31:0] op2;
  reg [31:0] tempPC = INITIAL_PC;
  wire [31:0] tempResult;
  reg [31:0] immediate;
  
  localparam [6:0] IMMEDIATE = 7'b0010011;
  localparam [6:0] LW = 7'b0000011;
  localparam [6:0] SW = 7'b0100011;
  localparam [6:0] BEQ = 7'b1100011;
  
  wire [31:0] immI = {{20{instr[31]}}, instr[31:20]};
  wire [31:0] immB = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
  wire [31:0] immS = {{20{instr[31]}}, instr[31:25], instr[11:7]};

  // Inputs to Register File
  regfile registers(
    .clk(clk), 
    .write(RegWrite), 
    .readReg1(instr[19:15]),
    .readReg2(instr[24:20]),
    .writeReg(instr[11:7]),
    .writeData(WriteBackData), 
    .readData1(readData1), 
    .readData2(readData2)
	);
  
  // Inputs to ALU
  alu opperations(
    .op1(readData1),
    .op2(op2),	// varies if IMMEDIATE
    .alu_op(ALUCtrl),
	.zero(Zero),
	.result(tempResult)
  );
  
  assign PC = tempPC;
  
  always @(*) begin        
    case (instr[6:0])
      7'b0100011 : immediate = immS;	// Code for SW
      7'b1100011 : immediate = immB;	// Code for BEQ
      7'b0010011 : immediate = immI;	// Code for *I
      7'b0000011 : immediate = immI;	// Code for LW
//       default : immediate = 32'b0;		
    endcase 
  end
  
  always @(posedge clk) begin
    if(rst) begin
      tempPC <= INITIAL_PC;
    end 
    else if (loadPC) begin
      tempPC = PCSrc ? (tempPC + immediate) : (tempPC + 4);
    end
  end
  
  always @(*) begin
    // If instruction is IMMEDIATE
    op2 = ALUSrc ? immediate : readData2;
    
    dWriteData = readData2;
    dAddress = tempResult;
    
    // Write Back MUX
    WriteBackData = MemToReg ? dReadData : tempResult;
  end
endmodule
