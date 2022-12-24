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
