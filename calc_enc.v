module alu_op_generator
  (
    input wire btnc, btnr, btnl,
    output wire [3:0] alu_op
  );
  
  // Wires for intermediate signals
  wire not_btnc, not_btnr, not_btnl;
  wire and0, and1, and2, and3, and4, and5, and6, and7, and8, and9;

  // Generate NOT gates for btnc, btnr, btnl
  not u0(not_btnc, btnc);
  not u1(not_btnr, btnr);
  not u2(not_btnl, btnl);

  // alu_op[0] = (~btnc & btnr) | (btnr & btnl)
  and u3(and0, not_btnc, btnr);
  and u4(and1, btnr, btnl);
  or u5(alu_op[0], and0, and1);

  // alu_op[1] = (~btnl & btnc) | (btnc & ~btnr)
  and u6(and2, not_btnl, btnc);
  and u7(and3, btnc, not_btnr);
  or u8(alu_op[1], and2, and3);

  // alu_op[2] = (btnc & btnr) | ((btnl & ~btnc) & ~btnr)
  and u9(and4, btnc, btnr);
  and u10(and5, btnl, not_btnc, not_btnr);
  or u11(alu_op[2], and4, and5);

  // alu_op[3] = ((btnl & ~btnc) & btnr) | ((btnl & btnc) & ~btnr)
  and u12(and6, btnl, not_btnc, btnr);
  and u13(and7, btnl, btnc, not_btnr);
  or u14(alu_op[3], and6, and7);
  
endmodule

