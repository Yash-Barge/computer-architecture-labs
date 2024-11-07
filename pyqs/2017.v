module MUX_SMALL(input a, b, s, output q);
    assign q = (~s & a) | (s & b);
endmodule

module MUX_BIG(input [7:0] I, input [2:0] S, output Q);
    genvar i;
    wire [3:0] temp_out;
    for (i = 0; i < 4; i = i + 1)
        MUX_SMALL minimux(I[2*i], I[2*i + 1], S[0], temp_out[i]);

    wire [1:0] temp_out_2;
    MUX_SMALL temp0(temp_out[0], temp_out[1], S[1], temp_out_2[0]);
    MUX_SMALL temp1(temp_out[2], temp_out[3], S[1], temp_out_2[1]);

    MUX_SMALL final(temp_out_2[0], temp_out_2[1], S[2], Q);
endmodule

module TFF(input T, clk, clear, output reg Q);
    always @(*)
        if (clear)
            Q <= 1'b0;
    
    always @(posedge clk)
        if (T)
            Q <= ~Q;
endmodule

module COUNTER_4BIT(input clk, clear, output [3:0] count);
    TFF bit0(1'b1, clk, clear, count[0]);
    TFF bit1(count[0], clk, clear, count[1]);
    
    and g1(g1, count[0], count[1]);
    TFF bit2(g1, clk, clear, count[2]);

    and g2(g2, g1, count[2]);
    TFF bit3(g2, clk, clear, count[3]);
endmodule

module COUNTER_3BIT(input clk, clear, output [2:0] count);
    TFF bit0(1'b1, clk, clear, count[0]);
    TFF bit1(count[0], clk, clear, count[1]);
    
    and g1(g1, count[0], count[1]);
    TFF bit2(g1, clk, clear, count[2]);
endmodule

module MEMORY(input [3:0] addr, output reg [7:0] data);
    reg [0:15][7:0] cells;

    initial cells = { 8'hcc, 8'haa, 8'hcc, 8'haa, 8'hcc, 8'haa, 8'hcc, 8'haa, 8'hcc, 8'haa, 8'hcc, 8'haa, 8'hcc, 8'haa, 8'hcc, 8'haa };

    always @(addr)
        data <= cells[addr];
endmodule

module INTG(input clk, clear, output final_out);
    wire [2:0] out_3bit;
    COUNTER_3BIT counter(clk, clear, out_3bit);

    and clk2(clk2, out_3bit[0], out_3bit[1], out_3bit[2]);
    wire [3:0] out_4bit;
    COUNTER_4BIT counter2(clk2, clear, out_4bit);

    wire [7:0] mem_out;
    MEMORY mem(out_4bit, mem_out);

    MUX_BIG mux(mem_out, out_3bit, final_out);
endmodule

module testbench();
    reg clk;
    initial clk = 1'b0;
    always #0.5 clk = ~clk;

    reg clear;
    initial clear = 1'b1;

    wire waveform;

    INTG final(clk, clear, waveform);

    initial begin
        $monitor($time, " waveform = %b", waveform);
        #2 clear = 1'b0;
        #100 $finish;
    end

    initial begin
        $dumpfile("2017.vcd");
        $dumpvars;
    end
endmodule
