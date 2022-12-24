module cpu(input clk, input rst_n, input start_pc, 
           output [15:0] out);
 

wire [15:0] ram_r_data, ir_out, sximm5, sximm8, datapath_out;
wire [7:0] pc_out, pc_in, DARout, ram_addr;
wire [2:0] opcode, r_addr, w_addr ;
wire [1:0] reg_sel, ALU_op, shift_op, wb_sel  ;
wire load_ir, w_en, en_A, en_B, en_C, sel_A, 
sel_B, en_status, Z, N, V, load_pc, load_addr, sel_addr, ram_w_en ;




//-------------Instruction Register----------------------//
sixteen_bit_reg InstructionReg(.clk(clk), .in(ram_r_data),
.en(load_ir), .out(ir_out));


//-------------------idecoder----------------------//
idecoder Idecoder(.ir(ir_out), .reg_sel(reg_sel), .opcode(opcode),
 .ALU_op(ALU_op), .shift_op(shift_op), .sximm5(sximm5), .sximm8(sximm8),
  .r_addr(r_addr), .w_addr(w_addr));


//-------------DATAPATH----------------------//
datapath Datapath(.clk(clk), .mdata(ram_r_data), .pc(pc_out), .wb_sel(wb_sel),
.w_addr(w_addr), .w_en(w_en), .r_addr(r_addr), .en_A(en_A),
.en_B(en_B), .shift_op(shift_op), .sel_A(sel_A), .sel_B(sel_B),
.ALU_op(ALU_op), .en_C(en_C), .en_status(en_status), .sximm8(sximm8),
.sximm5(sximm5),.datapath_out(datapath_out), .Z_out(Z), 
.N_out(N), .V_out(V));




//-------------Controller----------------------//
controller Controller(         
// inputs 
.clk(clk), .rst_n(rst_n), .opcode(opcode),
.ALU_op(ALU_op), .shift_op(shift_op), .Z(Z),   .N(N),   .V(V), 

// outputs to datapath and decoder  
.regsel(reg_sel), .wb_sel(wb_sel), .w_en(w_en), .en_A(en_A), 
.en_B(en_B), .en_C(en_C), .en_status(en_status), .sel_A(sel_A), .sel_B(sel_B),

// outputs to memory and other regs and muxes
.load_ir(load_ir), .load_pc(load_pc), .load_addr(load_addr), .clear_pc(clear_pc),
.sel_addr(sel_addr), .ram_w_en(ram_w_en)
          );


//-------------Program Counter----------------------//
always_comb begin 
    (clear_pc)? pc_in = start_pc  : pc_in = pc_out + 1'd1; 
end
eight_bit_reg ProgramCounter(.clk(clk), .in(pc_in), .en(load_pc),
 .out(pc_out));



//-------------Data Address Register----------------------//
eight_bit_reg DataAddressRegister(.clk(clk), .in(datapath_out[7:0]), 
.en(load_addr), .out(DARout));



//--------------------RAM----------------------//
always_comb begin 
    (sel_addr)? ram_addr = pc_out : ram_addr = DARout; 
end
ram Ram(.clk(clk), .ram_w_en(ram_w_en), .ram_r_addr(ram_addr),
.ram_w_addr(ram_addr), .ram_w_data(datapath_out), .ram_r_data(ram_r_data) )







//-------------outputs----------------------//
assign out = datapath_out;




endmodule: cpu



