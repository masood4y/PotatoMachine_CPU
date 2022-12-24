module task2(input clk, input rst_n, input [7:0] start_pc, output[15:0] out);
    
wire [15:0] ram_r_data, ir_out, sximm5, sximm8, datapath_out;
wire [7:0] pc_out, pc_in, DARout, ram_addr;
wire [2:0] opcode, r_addr, w_addr ;
wire [1:0] reg_sel, ALU_op, shift_op, wb_sel  ;
wire load_ir, w_en, en_A, en_B, en_C, sel_A, 
sel_B, en_status, Z, N, V, load_pc, load_addr, sel_addr, ram_w_en, clear_pc ;


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
.reg_sel(reg_sel), .wb_sel(wb_sel), .w_en(w_en), .en_A(en_A), 
.en_B(en_B), .en_C(en_C), .en_status(en_status), .sel_A(sel_A), .sel_B(sel_B),

// outputs to memory and other regs and muxes
.load_ir(load_ir), .load_pc(load_pc), .load_addr(load_addr), .clear_pc(clear_pc),
.sel_addr(sel_addr), .ram_w_en(ram_w_en)
          );


//-------------Program Counter----------------------//

assign  pc_in = (clear_pc)? start_pc  : pc_out + 1'd1; 

eight_bit_reg ProgramCounter(.clk(clk), .in(pc_in), .en(load_pc),
 .out(pc_out));



//-------------Data Address Register----------------------//
eight_bit_reg DataAddressRegister(.clk(clk), .in(datapath_out[7:0]), 
.en(load_addr), .out(DARout));



//--------------------RAM----------------------//
//always_comb begin 
assign  ram_addr = (sel_addr)? pc_out : DARout; 
//end
ram Ram(.clk(clk), .ram_w_en(ram_w_en), .ram_r_addr(ram_addr),
.ram_w_addr(ram_addr), .ram_w_data(datapath_out), .ram_r_data(ram_r_data) );


//-------------outputs----------------------//
assign out = datapath_out;

endmodule: task2



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

module controller(input clk, input rst_n, 
input [2:0] opcode, input [1:0] ALU_op, input [1:0] shift_op,
input Z, input N, input V,

// to datapath and decoder                  
output [1:0] reg_sel, output [1:0] wb_sel, output w_en,
output en_A, output en_B, output en_C, output en_status,
output sel_A, output sel_B,
// to memory and other regs and muxes
output load_ir, output load_pc, output load_addr, output clear_pc,
output sel_addr, output ram_w_en);
  
reg [10:0] outDD; // outputs to the decoder and datapath
reg [5:0] outMM; // outputs to memory, muxes and otherwise
 
assign {reg_sel, wb_sel, w_en, en_A, 
en_B, en_C, en_status, sel_A, sel_B} = outDD;

assign {load_ir, load_pc, load_addr, 
clear_pc, sel_addr, ram_w_en} = outMM;
 





 
enum reg[5:0]{
HALT = 6'd0,

FETCH1 = 6'd1, // to reset into
FETCH2 = 6'd2, // request instruction from Ram
FETCH3 = 6'd3, // read value from Ram and store into IR, also increment PC val
FETCH4 = 6'd26,

MOVIM = 6'd4, 

MOV1 = 6'd5, 
MOV2 = 6'd6, 
MOV3 = 6'd7, 

ANDD1 = 6'd8,
ANDD2 = 6'd9, 
ANDD3 = 6'd10,
ANDD4 = 6'd11, 

CMP1 = 6'd12, 
CMP2 = 6'd13,
CMP3 = 6'd14,

MVN1 = 6'd15,
MVN2 = 6'd16,
MVN3 = 6'd17,

CMPTAD1 = 6'd18, // Store RN into reg A selec imm5 and add
CMPTAD2 = 6'd19,  // and store into reg C
CMPTAD3 = 6'd20, // store into DAR

STR1 = 6'd21,  // store RD into reg B
STR2 = 6'd22,  // store into reg C
STR3 = 6'd23, // Store into memory at selected address

LDR1 = 6'd24,  // request value from memory at DAR
LDR2 = 6'd25,  // Store into RD ( kinda like the immidiet instuction)
LDR3 = 6'd27
} state;


always_ff @(posedge clk) begin
if (~rst_n) begin
state <= FETCH1;
end else begin

casex ({state, opcode, ALU_op })
/// going into HALT
{HALT, 3'bx, 2'bx } : state <= HALT;
{FETCH4, 3'b111, 2'bx } : state <= HALT;

// when it resets
{FETCH1, 3'bx, 2'bx } : state <= FETCH2;

// generally next instruction
{FETCH2, 3'bx, 2'bx } : state <= FETCH3;
{FETCH3, 3'bx, 2'bx } : state <= FETCH4;
// To go after Fetching // same as lab
{FETCH4, 3'b110, 2'b10} : state <= MOVIM;
{FETCH4, 3'b110, 2'b00} : state <= MOV1;
{FETCH4, 3'b101, 2'bx0} : state <=ANDD1;
{FETCH4, 3'b101, 2'b01} : state <= CMP1;
{FETCH4, 3'b101, 2'b11} : state <= MVN1;

// To go after Fetching, (both compute next Addr) // for str and load instuctions
{FETCH4, 3'b011, 2'bxx} : state <= CMPTAD1;
{FETCH4, 3'b100, 2'bxx} : state <= CMPTAD1;

{CMPTAD1, 3'bxxx, 2'bxx} : state <= CMPTAD2;
{CMPTAD2, 3'bxxx, 2'bxx} : state <= CMPTAD3;

// going from computing address to either LDR or STR states
{CMPTAD3, 3'b011, 2'bxx} : state <= LDR1;
{CMPTAD3, 3'b100, 2'bxx} : state <= STR1;

// from MOVIM to fetch 2
{MOVIM, 3'bxxx, 2'bxx} : state <= FETCH2;

// In MOV back to fetch 2
{MOV1, 3'bxxx, 2'bxx} : state <= MOV2;
{MOV2, 3'bxxx, 2'bxx} : state <= MOV3;
{MOV3, 3'bxxx, 2'bxx} : state <= FETCH2;

// In ANDD back to fetch 2
{ANDD1, 3'bxxx, 2'bxx} : state <= ANDD2;
{ANDD2, 3'bxxx, 2'bxx} : state <= ANDD3;
{ANDD3, 3'bxxx, 2'bxx} : state <= ANDD4;
{ANDD4, 3'bxxx, 2'bxx} : state <= FETCH2;

// In CMP back to fetch 2
{CMP1, 3'bxxx, 2'bxx} : state <= CMP2;
{CMP2, 3'bxxx, 2'bxx} : state <= CMP3;
{CMP3, 3'bxxx, 2'bxx} : state <= FETCH2;

// In MVN back to fetch 2
{MVN1, 3'bxxx, 2'bxx} : state <= MVN2;
{MVN2, 3'bxxx, 2'bxx} : state <= MVN3;
{MVN3, 3'bxxx, 2'bxx} : state <= FETCH2;

// In STR back to fetch 2
{STR1, 3'bxxx, 2'bxx} : state <= STR2;
{STR2, 3'bxxx, 2'bxx} : state <= STR3;
{STR3, 3'bxxx, 2'bxx} : state <= FETCH2;

// In LDR back to fetch 2
{LDR1, 3'bxxx, 2'bxx} : state <= LDR2;
{LDR2, 3'bxxx, 2'bxx} : state <= LDR3;
{LDR3, 3'bxxx, 2'bxx} : state <= FETCH2;
endcase
end
end






// outDD defined

always_comb begin
case (state)

//reg_sel, wb_sel, w_en, en_A,                rd = 01, rm = 00, rn = 10;
//en_B, en_C, en_status, sel_A, sel_B

FETCH1 : outDD = 11'b00_00_0_0_0_0_0_0_0; 
FETCH2 : outDD = 11'b00_00_0_0_0_0_0_0_0; 
FETCH3 : outDD = 11'b00_00_0_0_0_0_0_0_0; 
FETCH4 : outDD = 11'b00_00_0_0_0_0_0_0_0; 

HALT : outDD = 11'b00_00_0_0_0_0_0_0_0; 

MOVIM : outDD =  11'b10_10_1_0_0_0_0_1_1;

MOV1 : outDD =  11'b00_00_0_0_1_0_0_1_0;
MOV2 : outDD =  11'b00_00_0_0_0_1_0_1_0;
MOV3 : outDD =  11'b01_00_1_0_0_0_0_1_0;

ANDD1 : outDD =  11'b10_00_0_1_0_0_0_0_0;
ANDD2 : outDD =  11'b00_00_0_0_1_0_0_0_0;
ANDD3 : outDD =  11'b01_00_0_0_0_1_0_0_0;
ANDD4 : outDD =  11'b01_00_1_0_0_0_0_0_0;

CMP1 : outDD =  11'b10_00_0_1_0_0_0_0_0;
CMP2 : outDD =  11'b00_00_0_0_1_0_0_0_0;
CMP3 : outDD =  11'b01_00_0_0_0_0_1_0_0;

MVN1 : outDD =  11'b00_00_0_0_1_0_0_1_0;
MVN2 : outDD =  11'b00_00_0_0_0_1_0_1_0;
MVN3 : outDD =  11'b01_00_1_0_0_0_0_1_0;

CMPTAD1 : outDD =  11'b10_00_0_1_0_0_0_0_1;
CMPTAD2 : outDD =  11'b10_00_0_0_0_1_0_0_1;
CMPTAD3 : outDD =  11'b10_00_0_0_0_0_0_0_1;

STR1 : outDD =  11'b01_00_0_0_1_0_0_1_0;
STR2 : outDD =  11'b10_00_0_0_0_1_0_1_0;
STR3 : outDD =  11'b10_00_0_0_0_0_0_1_0;

LDR1 : outDD =  11'b01_11_0_0_0_0_0_1_0;
LDR2 : outDD =  11'b01_11_0_0_0_0_0_1_0;
LDR3 : outDD =  11'b01_11_1_0_0_0_0_1_0;
//reg_sel, wb_sel, w_en, en_A,                rd = 01, rm = 00, rn = 10;
//en_B, en_C, en_status, sel_A, sel_B

endcase
end



//load_ir, load_pc, load_addr, 
//clear_pc, sel_addr, ram_w_en



// outMM defined
always_comb begin
case (state)
FETCH1 : outMM = 6'b0_1_0_1_1_0; 
FETCH2 : outMM = 6'b0_0_0_0_1_0; 
FETCH3 : outMM = 6'b1_0_0_0_1_0; 
FETCH4 : outMM = 6'b0_1_0_0_1_0; 

HALT : outMM = 6'b0_0_0_0_1_0; 

MOVIM : outMM =  6'b0_0_0_0_1_0;

MOV1 : outMM =  6'b0_0_0_0_1_0;
MOV2 : outMM =  6'b0_0_0_0_1_0;
MOV3 : outMM =  6'b0_0_0_0_1_0;

ANDD1 : outMM =  6'b0_0_0_0_1_0;
ANDD2 : outMM =  6'b0_0_0_0_1_0;
ANDD3 : outMM =  6'b0_0_0_0_1_0;
ANDD4 : outMM =  6'b0_0_0_0_1_0;

CMP1 : outMM =  6'b0_0_0_0_1_0;
CMP2 : outMM =  6'b0_0_0_0_1_0;
CMP3 : outMM =  6'b0_0_0_0_1_0;

MVN1 : outMM =  6'b0_0_0_0_1_0;
MVN2 : outMM =  6'b0_0_0_0_1_0;
MVN3 : outMM =  6'b0_0_0_0_1_0;

CMPTAD1 : outMM =  6'b0_0_0_0_0_0;
CMPTAD2 : outMM =  6'b0_0_0_0_0_0;
CMPTAD3 : outMM =  6'b0_0_1_0_0_0;

STR1 : outMM =  6'b0_0_0_0_0_0;
STR2 : outMM =  6'b0_0_0_0_0_0;
STR3 : outMM =  6'b0_0_0_0_0_1;

LDR1 : outMM =  6'b0_0_0_0_0_0;
LDR2 : outMM =  6'b0_0_0_0_0_0;
LDR3 : outMM =  6'b0_0_0_0_0_0;

endcase
end
  
endmodule: controller

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



module idecoder(input [15:0] ir, input [1:0] reg_sel,
                output [2:0] opcode, output [1:0] ALU_op, output [1:0] shift_op,
		output [15:0] sximm5, output [15:0] sximm8,
                output [2:0] r_addr, output [2:0] w_addr);



        reg [2:0] r_add, w_add;
        
        assign opcode = ir[15:13];

        assign ALU_op = ir[12:11];

        assign sximm5 = {ir[4],ir[4],ir[4],ir[4],ir[4],ir[4],ir[4]
        ,ir[4],ir[4],ir[4], ir[4] ,ir[4:0]} ;

        assign sximm8 = {ir[7],ir[7],ir[7],ir[7],ir[7],
        ir[7],ir[7], ir[7], ir[7:0]};

        assign shift_op = ir[4:3];

        always_comb begin 
        case(reg_sel) 
        2'b00: w_add = ir[2:0];
        2'b01: w_add = ir[7:5];
        2'b10: w_add = ir[10:8];
        default: w_add =  3'b000;
        endcase
        end 
        
        // r_add seperate but should be the same as w_add all the time
        always_comb begin 
        case(reg_sel) 
        2'b00: r_add = ir[2:0];
        2'b01: r_add = ir[7:5];
        2'b10: r_add = ir[10:8];
        default: r_add =  3'b000;
        endcase
        end 

        assign r_addr = r_add;
        assign w_addr = w_add;

endmodule: idecoder


module eight_bit_reg(input clk, input [7:0] in, input en, output reg [7:0] out);
always_ff @(posedge clk) if(en) out <= in;
endmodule

module sixteen_bit_reg(input clk, input [15:0]in, input en, output reg [15:0]out);
always_ff @(posedge clk) if (en) out <= in;
endmodule

module three_bit_reg(input clk, input [2:0]in, input en, output reg [2:0] out);
always_ff @(posedge clk) if (en) out <= in;
endmodule 




// adapted from: Intel Quartus Prime Standard Edition User Guide, 18.1, sec. 2.4.1

// DO NOT MODIFY THIS FILE

module ram(input clk, input ram_w_en, input [7:0] ram_r_addr, input [7:0] ram_w_addr,
           input [15:0] ram_w_data, output reg [15:0] ram_r_data);
    reg [15:0] m[255:0];
    always_ff @(posedge clk) begin
        if (ram_w_en) m[ram_w_addr] <= ram_w_data;
        ram_r_data <= m[ram_r_addr];
    end
    initial $readmemb("ram_init.txt", m);
endmodule: ram


module regfile(input logic clk, input logic [15:0] w_data,
 input logic [2:0] w_addr, input logic w_en,
  input logic [2:0] r_addr, output logic [15:0] r_data);
    logic [15:0] m[0:7];
    assign r_data = m[r_addr];
    always_ff @(posedge clk) if (w_en) m[w_addr] <= w_data;
endmodule: regfile

module shifter(input [15:0] shift_in, 
input [1:0] shift_op, output reg [15:0] shift_out);
 
always_comb begin 
    case(shift_op)
    2'b00 : shift_out = shift_in;
    2'b01 : shift_out = {shift_in[14:0], 1'b0};
    2'b10 : shift_out = {1'b0, shift_in[15:1]};
    2'b11 : shift_out ={shift_in[15], shift_in[15:1]};

    default: shift_out = shift_in;
    endcase
    
end
endmodule
