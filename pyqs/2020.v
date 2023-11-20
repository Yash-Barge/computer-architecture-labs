`timescale 1ms/100us

module RSFF(input clk, r, s, reset, output reg q);
    always @(*)
        if (reset)
            q <= 1'b0;

    always @(posedge clk)
        if (r && !s)
            q <= 1'b0;
        else if (!r && s)
            q <= 1'b1;
endmodule

module DFF(input clk, reset, d, output q);
    RSFF RStoD(clk, ~d, d, reset, q);
endmodule

module Ripple_Counter(input clk, reset, output [3:0] q);
    DFF bit0(clk, reset, ~q[0], q[0]);
    DFF bit1(~q[0], reset, ~q[1], q[1]);
    DFF bit2(~q[1], reset, ~q[2], q[2]);
    DFF bit3(~q[2], reset, ~q[3], q[3]);
endmodule

module MEM1(input [2:0] addr, output reg [7:0] data, output parity);
    reg [0:7][7:0] data_mem;
    initial data_mem = { 8'h1F, 8'h31, 8'h53, 8'h75, 8'h97, 8'hB9, 8'hDB, 8'hFD };
    assign parity = 1'b1;

    always @(addr)
        data <= data_mem[addr];
endmodule

module MEM2(input [2:0] addr, output reg [7:0] data, output parity);
    reg [0:7][7:0] data_mem;
    initial data_mem = { 8'h00, 8'h22, 8'h44, 8'h66, 8'h88, 8'hAA, 8'hCC, 8'hEE };
    assign parity = 1'b0;

    always @(addr)
        data <= data_mem[addr];
endmodule

module MUX2To1(input a, b, s, output q);
    assign q = s ? b : a;
endmodule

module MUX16To8(input [7:0] a, b, input s, output [7:0] q);
    genvar i;
    for (i = 0; i < 8; i = i + 1)
        MUX2To1 sub_mux(a[i], b[i], s, q[i]);
endmodule

module Fetch_Data(input [3:0] addr, output [7:0] data, output parity);
    wire [7:0] bank1data, bank2data;
    wire bank1parity, bank2parity;

    MEM1 firstmem(addr[2:0], bank1data, bank1parity);
    MEM2 secondmem(addr[2:0], bank2data, bank2parity);

    MUX16To8 big_mux(bank1data, bank2data, addr[3], data);
    MUX2To1 small_mux(bank1parity, bank2parity, addr[3], parity);
endmodule

module Parity_Checker(input [7:0] data, input parity, output match);
    assign match = (data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[7]) == parity;
endmodule

module Design(input clk, reset, output parity_match);
    wire [3:0] counter_out;
    Ripple_Counter counter(clk, reset, counter_out);

    wire [7:0] data_mem;
    wire parity_mem;
    Fetch_Data datafetcher(counter_out, data_mem, parity_mem);

    Parity_Checker par_chk(data_mem, parity_mem, parity_match);
endmodule

module testbench();
    reg clk;
    initial clk = 1'b0;
    always #0.5 clk = ~clk;

    reg reset;
    initial begin reset = 1'b1; #1 reset = 1'b0; end

    wire match;
    Design final(clk, reset, match);

    initial begin
        $monitor($time, " %b", match);
        #32 $finish;
    end

    // initial begin
    //     $dumpfile("test.vcd");
    //     $dumpvars;
    // end
endmodule
