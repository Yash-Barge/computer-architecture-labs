module testbench;
	reg [0:15][15:0] mem;
	initial mem = { 16'h0001, 16'h0002, 16'h0003, 16'h0004, 16'h0005, 16'h0006, 16'h0007, 16'h0008,
					16'h0009, 16'h000A, 16'h000B, 16'h000C, 16'h000D, 16'h000E, 16'h000F, 16'hFFFF };
    reg clk;
	
	always
		#1 clk = ~clk;
    
    reg [15:0] val;
    always @(clk)
        val <= mem[clk];

	initial
		$monitor($time, " clk=%b, mem[clk]=%x", clk, val);
	
	initial begin
		clk = 1'b0;
		
		#44 $finish;
	end
endmodule