module tb_task3(output err);
  
reg clk, rst_n;
reg [7:0] start_pc;
wire [15:0] out ;

reg w1, w2;

task3 DUT(.clk(clk), .rst_n(rst_n), .start_pc(start_pc), .out(out));


assign err = w1 | w2;



initial begin
clk <= 1'b1; 
forever #5 clk <= ~clk;
end
initial begin
w1 = 1'b0;
w2 = 1'b0;

rst_n = 1'b0;
start_pc = 8'd28;
#10;
rst_n = 1'b1;

#490;
assert ({out} === 16'd100) 
$display("[PASS] value of stored from r0 is now in r3 = 100");
else $error("[FAIL] value of stored from r0 is now in r3 = 100");
assert ({out} === 16'd100) w1 = 1'b0;
else w1= 1'b1;

#150;
assert ({out} === 16'd111) 
$display("[PASS] value of stored from r1 is now in r4 = 111");
else $error("[FAIL] value of stored from r1 is now in r4 = 111");
assert ({out} === 16'd111) w2 = 1'b0;
else w2= 1'b1;

$stop;    
end



endmodule: tb_task3
