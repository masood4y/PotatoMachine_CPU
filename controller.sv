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
LDR2 = 6'd25   // Store into RD ( kinda like the immidiet instuction)

} state









always_ff @(posedge clk) begin
if (~rst_n) begin
state <= FETCH1;
end else begin

casex ({state, opcode, ALU_op })
/// going into HALT
{HALT, 3'bx, 2'bx } : state <= HALT;
{FETCH3, 3'b111, 2'bx } : state <= HALT;

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
{FETCH3, 3'b011, 2'bxx} : state <= CMPTAD1;
{FETCH3, 3'b100, 2'bxx} : state <= CMPTAD1;

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
{LDR2, 3'bxxx, 2'bxx} : state <= FETCH2;
default : state <= HALT;
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
LDR2 : outDD =  11'b01_11_1_0_0_0_0_1_0;

endcase
end







// outMM defined
always_comb begin
case (state)
FETCH1 : outMM = 6'b0_1_0_1_1_0; 
FETCH2 : outMM = 6'b0_0_0_0_1_0; 
FETCH3 : outMM = 6'b1_1_0_0_1_0; 
FETCH4 : outMM = 6'b1_1_0_0_1_0; 

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

endcase
end
  
endmodule: controller
