module tb_task2(output err);
  
  reg clk, rst_n;
reg [7:0] start_pc;
wire [15:0] out ;

reg w1, w2, w3, w4, w5, w6, w7, w8;

task2 DUT(.clk(clk), .rst_n(rst_n), .start_pc(start_pc), .out(out));

assign err = w1 | w2 | w3 | w4 | w5 | w6 | w7 | w8;

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
w7 = 1'b0;
w8 = 1'b0;

rst_n = 1'b0;
start_pc = 8'd18;
#10;
rst_n = 1'b1;


#140;
assert ({out} === 16'd100) 
$display("[PASS] address of value in memory is 100");
else $error("[FAIL] address of value in memory is 100");
assert ({out} === 16'd100) w1 = 1'b0;
else w1 = 1'b1;


#90;
assert ({out} === 16'd250) 
$display("[PASS] value of address 100 is 250, is stored in r0");
else $error("[FAIL] value of address 100 is 250, is stored in r0");
assert ({out} === 16'd250) w2 = 1'b0;
else w2 = 1'b1;


#80;
assert ({out} === 16'd101) 
$display("[PASS] address of value in memory is 101");
else $error("[FAIL] address of value in memory is 101");
assert ({out} === 16'd101) w3 = 1'b0;
else w3 = 1'b1;

#70;

assert ({out} === -16'd354) 
$display("[PASS] value of address 101 is -354, is stored in r1");
else $error("[FAIL] value of address 101 is -354 is stored in r1");
assert ({out} === -16'd354) w4 = 1'b0;
else w4 = 1'b1;

#80;

assert ({out} === 16'd102) 
$display("[PASS] address of value in memory is 102");
else $error("[FAIL] address of value in memory is 102");
assert ({out} === 16'd102) w5 = 1'b0;
else w5 = 1'b1;


#70;

assert ({out} === 16'd345) 
$display("[PASS] value of address 102 is 345, is stored in r2");
else $error("[FAIL] value of address 102 is 345, is stored in r2");
assert ({out} === 16'd345) w6 = 1'b0;
else w6 = 1'b1;

#80;

assert ({out} === 16'd103) 
$display("[PASS] address of value in memory is 103");
else $error("[FAIL] address of value in memory is 103");
assert ({out} === 16'd103) w7 = 1'b0;
else w7 = 1'b1;


#70;

assert ({out} === 16'd534) 
$display("[PASS] value of address 103 is 534, is stored in r3");
else $error("[FAIL] value of address 103 is 534, is stored in r3");
assert ({out} === 16'd534) w8 = 1'b0;
else w8= 1'b1;

#20;



$stop;    
end


endmodule: tb_task2
