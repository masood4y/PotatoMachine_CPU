module tb_task1(output err);
  
reg clk, rst_n;
reg [7:0] start_pc;
wire [15:0] out ;

reg w1, w2, w3, w4, w5, w6;

task1 DUT(.clk(clk), .rst_n(rst_n), .start_pc(start_pc), .out(out));

assign err = w1 | w2 | w3 | w4 | w5 | w6;


initial begin
clk <= 1'b1; 
forever #5 clk <= ~clk;
end

initial begin
w1 = 1'b0;
w2 = 1'b0;
w3 = 1'b0;
w4 = 1'b0;
w5 = 1'b0;
w6 = 1'b0;



rst_n = 1'b0;
start_pc = 8'd0;
#10;
rst_n = 1'b1;


#300;
assert ({out} === -16'd11) 
$display("[PASS] value in r1 is -11 ");
else $error("[FAIL] value in r1 is 11");
assert ({out} === -16'd11) w1 = 1'b0;
else w1 = 1'b1;


#180;
assert ({out} === 16'd84) 
$display("[PASS] value in r4 is 84 ");
else $error("[FAIL] value in r4 is 84");
assert ({out} === 16'd84) w2 = 1'b0;
else w2 = 1'b1;

#70;
assert ({out} === -16'd57) 
$display("[PASS] value in r7 is -57");
else $error("[FAIL] value in r7 is -57");
assert ({out} === -16'd57) w3 = 1'b0;
else w3 = 1'b1;

#130;
assert ({out} === 16'd59) 
$display("[PASS] value in r7-r6 is 59");
else $error("[FAIL] value in  r7-r6 is 59");
assert ({out} === 16'd59) w4 = 1'b0;
else w4 = 1'b1;

#130;

assert ({out} === 16'd200) 
$display("[PASS] value in r4 + r6 is 200");
else $error("[FAIL] value in  r4 + r6 is 200");
assert ({out} === 16'd200) w5 = 1'b0;
else w5 = 1'b1;

#130;
assert ({out} === 16'd80) 
$display("[PASS] value is r4 ^ r5 is 80 in decimal");
else $error("[FAIL] value is r4 ^ r5 is 80 in decimal");
assert ({out} === 16'd80) w6 = 1'b0;
else w6 = 1'b1;
#40;

$stop;    
end






endmodule: tb_task1
