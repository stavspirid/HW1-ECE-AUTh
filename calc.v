`timescale 10 ns/1 ns
`include "alu.v"
`include "calc_enc.v"

module calc
  (
    input clk, btnc, btnl, btnu, btnr, btnd,
    input wire [15:0] sw,
    output reg [15:0] led
  );
  
  reg [15:0] accumulator;
  wire [31:0] alu_op1, alu_op2;
  wire [31:0] alu_result;
  wire [3:0] alu_op;
  
  assign alu_op1 = {{16{accumulator[15]}}, accumulator};	// sign extended accumulator
  assign alu_op2 = {{16{sw[15]}}, sw};				// sign extended sw
  
  alu_op_generator op_gen(
    .btnc(btnc), .btnr(btnr), .btnl(btnl), .alu_op(alu_op)
  );
  
  alu alu1 (
    .op1(alu_op1), .op2(alu_op2), .alu_op(alu_op), .zero(), .result(alu_result)
  );
  
  assign led = accumulator;

  always @(posedge clk) begin
    if (btnu) begin
      accumulator <= 16'b0;
    end else if (btnd) begin
      accumulator <= alu_result[15:0];
    end
  end
  
endmodule

