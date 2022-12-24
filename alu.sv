module ALU(input [15:0] val_A, input [15:0] val_B,
 input [1:0] ALU_op, output [15:0] ALU_out, output [2:0] znv);
 
reg [15:0] ALU_ot;
assign ALU_out = ALU_ot;
always_comb begin 
case(ALU_op)
2'b00: ALU_ot = val_A+val_B;
2'b01: ALU_ot = val_A-val_B;
2'b10: ALU_ot = val_A & val_B;
2'b11: ALU_ot =~val_B;
default ALU_ot = 16'd0;
endcase
end

reg overFlow;

//wire overFlow, underFlow;

//assign overFlow = val_A[15] && val_B[15] && ~ALU_out[15];
//assign underFlow = ~val_A[15] && ~val_B[15] && ALU_out[15];

//assign  defFLow = overFlow||underFlow;

assign znv[2] = (ALU_out)? 1'b0:1'b1;
assign znv[1] = (ALU_out[15])? 1'b1: 1'b0;
assign znv[0] = (overFlow);
//assign znv[0] = (defFLow)? 1'b1: 1'b0;


always_comb begin 
case({val_A[15], val_B[15], ALU_op, znv[1]})
5'b1_0_01_0: overFlow = 1'b1; //  -x - +y  -- > if output is +, overflow
5'b0_1_01_1: overFlow = 1'b1;//  +x - -y -- > if output is -, overflow
5'b1_1_00_0: overFlow = 1'b1; //  -x + -y if output is +, overflow
5'b0_0_00_1: overFlow = 1'b1; //  +x + +y -- > if output is -, overflow
default:  overFlow = 1'b0;

endcase
end

endmodule: ALU

