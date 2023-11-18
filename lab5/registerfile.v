module D_FF(input d, clk, reset, output reg q);
    always @(reset)
        if (~reset)
            q <= 1'b0;

    always @(negedge clk) 
        q <= d;
endmodule

module reg_32bit(input [31:0] d, input clk, reset, output [31:0] q);
    genvar i;
    for (i = 0; i < 32; i = i + 1) 
        D_FF D(d[i], clk, reset, q[i]);
endmodule

module mux_32_1_32bit(input [0:31][31:0] registers, input [4:0] select_lines, output reg [31:0] data_out);
    always @(select_lines or registers)
        data_out <= registers[0][-32 * select_lines +: 32];
endmodule

module register_file(input clk, regwrite, reset, input [4:0] rd1, rd2, wn, input [31:0] wd, output [31:0] a, b); // does actually set all widths correctly
    reg [0:31][31:0] registers;
    wire [0:31][31:0] reg_out_lines;

    always @(reset)
        if (~reset)
            registers = 0;

    always @(*)
        if (regwrite)
            registers[wn] <= wd;

    genvar i;
    for (i = 0; i < 32; i = i + 1)
        reg_32bit register(registers[i], clk, reset, reg_out_lines[i]);

    mux_32_1_32bit mux_a(reg_out_lines, rd1, a);
    mux_32_1_32bit mux_b(reg_out_lines, rd2, b);
endmodule

module testbench;
    reg clk;
    initial clk = 1'b0;
    always #1 clk = ~clk;

    reg reset;
    initial reset = 1'b0;
    
    wire [31:0] a, b;
    reg [31:0] wd;
    register_file rf(clk, 1'b1, reset, 5'b00000, 5'b00000, 5'b00000, wd, a, b);

    initial begin
        $monitor($time, " wd = %x, a = %x", wd, a);
        #0 wd = 32'h00001111;
        #1 reset = 1'b1;
        #4 wd = 32'hF0F0F0F0;
        #2 wd = 32'h10101010;
        #2 $finish;
    end
endmodule
