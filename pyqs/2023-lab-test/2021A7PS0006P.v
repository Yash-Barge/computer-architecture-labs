// Name: Yash Sangram Barge
// ID: 2021A7PS0006P

`timescale 1ms/1ns

module JKFF(input J, K, CLK, output reg Q);
	initial Q = 1'b1;

	always @(negedge CLK) begin
		Q <= (J & ~Q) | (~K & Q);
	end
endmodule

module BCD_Counter(output [3:0] Q_out, input CLK);
	JKFF bit0(1'b1, 1'b1, CLK, Q_out[0]);
	
	not q3bar(q3bar, Q_out[3]);
	JKFF bit1(q3bar, 1'b1, Q_out[0], Q_out[1]);
	JKFF bit2(1'b1, 1'b1, Q_out[1], Q_out[2]);
	
	and j3(j3, Q_out[1], Q_out[2]);
	JKFF bit3(j3, 1'b1, Q_out[0], Q_out[3]);
endmodule

module MEM_16(output reg [15:0] D_16, input [3:0] A_4);
	reg [0:15][15:0] mem;
	initial mem = { 16'h0001, 16'h0002, 16'h0004, 16'h0008, 16'h0010, 16'h0020, 16'h0000, 16'h0000,
					16'h0000, 16'h0000, 16'h0400, 16'h0800, 16'h1000, 16'h0000, 16'h0000, 16'h0000 };
	
	always @(A_4)
		D_16 <= mem[A_4];
endmodule

module MUX_16(output O, input [15:0] I_16, input [3:0] S_4);
	assign O = I_16[S_4];
endmodule

module INTG(output OUT, input CLK);
	wire [3:0] Q;
	BCD_Counter counter(Q, CLK);
	
	wire [15:0] D;
	MEM_16 memory(D, Q);
	
	MUX_16 big_mux(OUT, D, Q);
endmodule

module TESTBENCH();
	reg CLK;
	initial CLK = 1'b0;
	always #0.5 CLK = ~CLK;
	
	wire OUT;
	INTG wrapper(OUT, CLK);
	
	initial begin
		$monitor($time, " CLK=%b | OUT=%b", CLK, OUT);
		#23 $finish;
	end
	
	initial begin
		$dumpfile("2021A7PS0006P.vcd");
		$dumpvars;
	end
endmodule
