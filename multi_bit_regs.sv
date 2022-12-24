module eight_bit_reg(input clk, input [7:0] in, input en, output reg [7:0] out);
always_ff @(posedge clk) if(en) out <= in;
endmodule

module sixteen_bit_reg(input clk, input [15:0]in, input en, output reg [15:0]out);
always_ff @(posedge clk) if (en) out <= in;
endmodule

module three_bit_reg(input clk, input [2:0]in, input en, output reg [2:0] out);
always_ff @(posedge clk) if (en) out <= in;
endmodule 




