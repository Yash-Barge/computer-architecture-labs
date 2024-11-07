// *******TOP MODULE***********
`timescale 1ns / 1ps
module intg(clk, out, data, temp);
input clk;
output out;
output[3:0] temp;
output [15:0] data;
wire q3, q2, q1, q0;
wire [15:0] data;
bcd_Count bcdc(clk, q0, q1, q2, q3);
memory mmry(q0, q1, q2, q3, data);
mux_16 dm(data, q3, q2, q1, q0, out);
assign temp = {q0, q1, q2, q3};
endmodule
// **************JK FLIPFLOP***************
module jk_ff ( input j, input k, input clk, output reg q);
reg temp;
initial q = 0;
always @ (negedge clk)
case ({j,k})
2'b00 : q <= q;
2'b01 : q <= 0;
2'b10 : q <= 1;
2'b11 : q <= ~q;
endcase
endmodule
// ****************BCD_COUNTER************
module bcd_Count(clk, q0, q1, q2, q3);
input clk;
output q0, q1, q2, q3;
jk_ff jk0(1'b1, 1'b1, clk, q0);
jk_ff jk1(~q3, 1'b1, q0, q1);
jk_ff jk2(1'b1, 1'b1, q1, q2);
and ad(k, q1, q2);
jk_ff jk3(k, 1'b1, q0, q3);
endmodule
// **********************MEMORY MODULE**************************
module memory(q3, q2, q1, q0, data);
input q3, q2, q1, q0;
output reg [15:0] data;
reg [15:0]mem[0:15];

initial
begin
mem[0] = 16'h0001;
mem[1] = 16'h0002;
mem[2] = 16'h0004;
mem[3] = 16'h0008;
mem[4] = 16'h0010;
mem[5] = 16'h0020;
mem[6] = 16'h0000;
mem[7] = 16'h0000;
mem[8] = 16'h0000;
mem[9] = 16'h0000;
mem[10] = 16'h0400;
mem[11] = 16'h0800;
mem[12] = 16'h1000;
mem[13] = 16'h0000;
mem[14] = 16'h0000;
mem[15] = 16'h0000;
end
always @(*)
data = mem[{q0, q1, q2, q3}];
endmodule
//*******************************MUX**************************
module mux_16(data, q3, q2, q1, q0, out);
input [15:0] data;
input q3, q2, q1, q0;
output reg out;
always @(*)
begin
out = data[{q3, q2, q1, q0}];
end
endmodule
//********************************************TESTBENCH***************
module tb_jk;
reg clk;
wire out;
wire [3:0] temp;
wire [15:0] data;
initial clk = 1;
always #5 clk = ~clk;
intg tp(clk, out, data, temp);
initial begin
$monitor($time,"clk=%b out= %b data=%b\n",clk,out,data);
#200 $finish;
end
initial begin
    $dumpfile("answer_key.vcd");
    $dumpvars;
end
endmodule
