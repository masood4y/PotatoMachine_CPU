module datapath(input clk, input [15:0] mdata, input [7:0] pc, input [1:0] wb_sel,
                input [2:0] w_addr, input w_en, input [2:0] r_addr, input en_A,
                input en_B, input [1:0] shift_op, input sel_A, input sel_B,
                input [1:0] ALU_op, input en_C, input en_status,
		input [15:0] sximm8, input [15:0] sximm5,
                output [15:0] datapath_out, output Z_out, output N_out, output V_out);
 
 
  reg [15:0] r_data, w_data, val_A, val_B, ALU_out,
shift_in, shift_out, reg_A_out; 
wire [2:0] znv;

// marker 1
regfile regfile1 (.w_data(w_data), .w_addr(w_addr), .w_en(w_en),
.r_addr(r_addr),.clk(clk), .r_data(r_data) );

// marker2 
ALU ALU1(.val_A(val_A), .val_B(val_B), .ALU_op(ALU_op),
.ALU_out(ALU_out), .znv(znv));

// marker3
sixteen_bit_reg regA(.clk(clk), .in(r_data), .en(en_A), .out(reg_A_out) );
// marker4
sixteen_bit_reg regB(.clk(clk), .in(r_data), .en(en_B), .out(shift_in) );
// marker5
sixteen_bit_reg regC(.clk(clk), .in(ALU_out), .en(en_C), .out(datapath_out) );

// markers 6 and 7 ------ mux for input to val B modified for lab 6
always_comb begin
val_A = (sel_A) ? 16'b0 : reg_A_out;
val_B = (sel_B) ? sximm5: shift_out;
end

// marker 8
shifter shifter1(.shift_in(shift_in), .shift_op(shift_op), .shift_out(shift_out));

//marker 9  -- updated writeback mux
always_comb begin
case (wb_sel)
2'b00: w_data = datapath_out;
2'b01: w_data = {8'b0, pc};
2'b10: w_data = sximm8;
2'b11: w_data = mdata;
endcase
end

//marker 10 -- status now inputs and output three wires
three_bit_reg status(.clk(clk), .in(znv), .en(en_status), .out({Z_out, N_out, V_out}));

endmodule: datapath







