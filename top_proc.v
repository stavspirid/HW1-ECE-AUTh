`include "datapath.v"

module procedures #(parameter [31:0] INITIAL_PC = 32'h00400000)
  (
  input clk,
  input rst, 
  input wire [31:0] instr,
  input wire [31:0] dReadData,
  input wire [31:0] PC,
  output wire [31:0] dAddress,
  output wire [31:0] dWriteData,
  output reg MemRead,
  output reg MemWrite,
  output wire [31:0] WriteBackData
  );
  
  wire Zero;
  reg IFStage, IDStage, EXStage, MEMStage, WBStage;
  
  reg [2:0] FSM;
  reg PCSrc, ALUSrc, RegWrite, MemToReg, loadPC;
  reg [3:0] ALUCtrl;
  
  datapath #(.INITIAL_PC(INITIAL_PC)) datapath(
    .clk(clk), 
    .rst(rst), 
    .instr(instr), 
    .PCSrc(PCSrc), 
    .ALUSrc(ALUSrc), 
    .RegWrite(RegWrite), 
    .MemToReg(MemToReg), 
    .ALUCtrl(ALUCtrl), 
    .loadPC(loadPC), 
    .PC(PC), 
    .Zero(Zero), 
    .dAddress(dAddress), 
    .dWriteData(dWriteData), 
    .dReadData(dReadData), 
    .WriteBackData(WriteBackData)
  );
  
  wire [6:0] opcode = instr[6:0];
  wire [2:0] funct3 = instr[14:12];
  
  parameter [2:0] IF = 3'b000;
  parameter [2:0] ID = 3'b001;
  parameter [2:0] EX = 3'b010;
  parameter [2:0] MEM = 3'b011;
  parameter [2:0] WB = 3'b100;
  
  // Opcode parameters
  localparam [6:0] 
  	OP_IMMEDIATE = 7'b0010011,
    OP_NON_IMM   = 7'b0110011,
    OP_LW        = 7'b0000011,
    OP_SW        = 7'b0100011,
    OP_BEQ       = 7'b1100011;

  // Function parameters
  localparam [2:0] 
  	FUNC_ADD_SUB = 3'b000,
    FUNC_SLT     = 3'b010,
    FUNC_XOR     = 3'b100,
    FUNC_OR      = 3'b110,
    FUNC_AND     = 3'b111,
    FUNC_SLL     = 3'b001,
    FUNC_SRL     = 3'b101,
  	FUNC_SRA     = 3'b101;

  // ALU operation parameters
  localparam [3:0] ALU_AND  = 4'b0000,
    ALU_OR   = 4'b0001,
    ALU_ADD  = 4'b0010,
    ALU_SUB  = 4'b0110,
    ALU_SLT  = 4'b0100,
    ALU_SRL  = 4'b1000,
    ALU_SLL  = 4'b1001,
    ALU_SRA  = 4'b1010,
    ALU_XOR  = 4'b0101;

  // Reset and Next Stage
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      FSM <= IF;
      RegWrite <= 0;
      loadPC <= 0;
      ALUSrc <= 0;
      PCSrc <= 0;
      MemToReg <= 0;
      MemRead <= 0;
      MemWrite <= 0;
    end 
    else begin
      case (FSM)
        IF:  FSM <= ID;
        ID:  FSM <= EX;
        EX:  FSM <= MEM;
        MEM: FSM <= WB;
        WB:  FSM <= IF;
      endcase
    end
  end

  always @(posedge clk) begin
    case (FSM)
      IF: begin
        {IFStage, IDStage, MEMStage, EXStage, WBStage} = 5'b10000;
        // Control Signals Reset
        loadPC   <= 0;
        MemRead  <= 0;
        MemWrite <= 0;
        RegWrite <= 0;
        MemToReg <= 0;
      end
      ID: {IFStage, IDStage, MEMStage, EXStage, WBStage} = 5'b01000;
      MEM: begin
        {IFStage, IDStage, MEMStage, EXStage, WBStage} = 5'b00100;
        if (opcode == OP_LW)
          MemRead <= 1;
        else if (opcode == OP_SW)
          MemWrite <= 1;
      end
      EX: {IFStage, IDStage, MEMStage, EXStage, WBStage} = 5'b00010;
      WB: begin 
        {IFStage, IDStage, MEMStage, EXStage, WBStage} = 5'b00001;
        loadPC <= 1;
        if (opcode == OP_LW)
          MemToReg <= 1;
        if (opcode != OP_SW && opcode != OP_BEQ)
          RegWrite <= 1;
      end
    endcase
  end
        
  always @(*) begin
    if (opcode == OP_NON_IMM) begin
      case (funct3)
        FUNC_ADD_SUB: ALUCtrl = (instr[30] == 0) ? ALU_ADD : ALU_SUB;
        FUNC_SLT: ALUCtrl = ALU_SLT;
        FUNC_XOR: ALUCtrl = ALU_XOR;
        FUNC_OR:  ALUCtrl = ALU_OR;
        FUNC_SLL: ALUCtrl = ALU_SLL;
        FUNC_AND: ALUCtrl = ALU_AND;
        FUNC_SRL: ALUCtrl = (instr[30] == 0) ? ALU_SRL : ALU_SRA;
        default : ALUCtrl = 4'bxxxx; // Undefined state
      endcase
    end
    else if (opcode == OP_IMMEDIATE) begin
      case (funct3)
            FUNC_ADD_SUB : ALUCtrl = ALU_ADD;
            FUNC_SLT : ALUCtrl = ALU_SLT;
            FUNC_XOR : ALUCtrl = ALU_XOR;
            FUNC_OR : ALUCtrl = ALU_OR;
            FUNC_AND : ALUCtrl = ALU_AND;
            FUNC_SLL : ALUCtrl = ALU_SLL;
            FUNC_SRL : begin
                if ( instr[30] == 0 )
                    ALUCtrl = ALU_SRL;
                else if ( instr[30] == 1 )
                    ALUCtrl = ALU_SRA;
            end
        	default : ALUCtrl = 4'bxxxx; // Undefined state
        endcase
    end
    else if ( opcode == OP_LW || opcode == OP_SW )
        ALUCtrl = ALU_ADD;
    else if ( opcode == OP_BEQ )
        ALUCtrl = ALU_SUB;
end

  always @(*) begin
    // ALUSrc  
    if (opcode == OP_LW || opcode == OP_SW || opcode == OP_IMMEDIATE) begin
      ALUSrc <= 1;
    end
    else begin
      ALUSrc <= 0;
    end
    
    // PCSrc
    if (opcode == OP_BEQ) begin
        PCSrc <= Zero ? 1 : 0;
    end
    else begin
        PCSrc <= 0;
    end
  end

endmodule
