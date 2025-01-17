module alu
  (
    input [31:0] op1,
    input [31:0] op2,
    input [3:0] alu_op,
    output reg zero,
    output reg [31:0] result
  );
  
  parameter[3:0] ALUOP_AND = 4'b0000;	// AND opperation
  parameter[3:0] ALUOP_OR  = 4'b0001;	// OR opperation
  parameter[3:0] ALUOP_ADD = 4'b0010;	// Addition opperation
  parameter[3:0] ALUOP_SUB = 4'b0110;	// Subtraction opperation
  parameter[3:0] ALUOP_SML = 4'b0100; 	// Smaller Than opperation
  parameter[3:0] ALUOP_LSR = 4'b1000;	// Logical Shift Right
  parameter[3:0] ALUOP_LSL = 4'b1001;	// Logical Shift Left
  parameter[3:0] ALUOP_ASR = 4'b1010;	// Arithmetical Shift Right
  parameter[3:0] ALUOP_XOR = 4'b0101;	// XOR opperation
  
  always @(op1 or op2 or alu_op) begin	// Enter when one of the input values is updated
    case (alu_op)
      ALUOP_AND : result = op1 & op2;
      ALUOP_OR  : result = op1 | op2;
      ALUOP_ADD : result = op1 + op2;
      ALUOP_SUB : result = op1 - op2;
      ALUOP_SML : result = ($signed(op1) < $signed(op2)) ? 32'b1 : 32'b0;
      ALUOP_LSR : result = op1 >> op2[4:0];
      ALUOP_LSL : result = op1 << op2[4:0];
      ALUOP_ASR : result = $unsigned($signed(op1) >>> op2[4:0]);
      ALUOP_XOR : result = op1 ^ op2;
      default : result = 32'b0;
    endcase
    zero = (result == 32'b0);
  end
  
endmodule

