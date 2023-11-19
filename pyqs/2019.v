`timescale 1ms/100us

module MUX_2x1(input a, b, s, output q);
    assign q = s ? b : a;
endmodule

module MUX_8x1(input [7:0] a, input [2:0] s, output q);
    assign q = a[s];
endmodule

module MUX_ARRAY(input [7:0] a, input [7:0] s, output [7:0] q);
    genvar i;
    for (i = 0; i < 8; i = i + 1) begin
        MUX_2x1 small_mux(1'b0, a[i], s[i], q[i]);
    end
endmodule

module COUNTER_3BIT(input clk, clear, output reg [2:0] q);
    always @(*)
        if (clear)
            q <= 3'b000;
    
    always @(posedge clk)
        if (!clear)
            q <= q + 1;
endmodule

module DECODER(input en, input [2:0] a, output reg [7:0] q);
    always @(*)
        if (!en)
            q <= 8'h00;
    
    always @(a)
        if (en)
            q <= (1 << a);
endmodule

module MEMORY(input [2:0] s, output reg [7:0] data);
    reg [0:7][7:0] mem;
    initial mem = { 8'h01, 8'h03, 8'h07, 8'h0F, 8'h1F, 8'h3F, 8'h7F, 8'hFF };

    always @(s)
        data <= mem[s];
endmodule

module TOP_MODULE(input clk, clear, input [2:0] mem_select, output o);
    wire [2:0] counter_out;
    COUNTER_3BIT counter(clk, clear, counter_out);

    wire [7:0] dec_out;
    DECODER dec(1'b1, counter_out, dec_out);

    // Shouldn't this reverse apply? Output is fixed to 0 if it is reversed though
    wire [7:0] dec_out_rev;
    genvar i;
    for (i = 0; i < 8; i = i + 1)
        assign dec_out_rev[i] = dec_out[7 - i];

    wire [7:0] mem_out;
    MEMORY mem(mem_select, mem_out);

    wire [7:0] mux_arr_out;
    MUX_ARRAY mux_arr(dec_out/*_rev*/, mem_out, mux_arr_out);

    MUX_8x1 big_mux(mux_arr_out, counter_out, o);
endmodule

module testbench();
    reg clk;
    initial clk = 1'b1;
    always #0.5 clk = ~clk;

    reg clear;
    initial begin clear = 1'b1; #1 clear = 1'b0; end

    reg [2:0] mem_select;
    initial mem_select = 3'b000;
    always #8 mem_select = mem_select + 1;

    wire out;
    TOP_MODULE final(clk, clear, mem_select, out);

    initial begin
        $monitor($time, " o = %b", out);
        #100 $finish;
    end
endmodule
