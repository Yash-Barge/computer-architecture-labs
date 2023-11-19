module JKFF (J, K, clk, Q);
    input J, K, clk;
    output Q;
    reg Q;

    initial begin
        Q = 1'b0;
    end

    always @(posedge clk) begin
        Q <= (J & ~Q) | (~K & Q);
    end
endmodule

module counter_4bit (clk, Q);
    input clk;
    output [3:0] Q;

    JKFF JKFF0(1'b1, 1'b1, clk, Q[0]);
    JKFF JKFF1(Q[0], Q[0], clk, Q[1]);

    and zo(zo, Q[0], Q[1]);
    JKFF JKFF2(zo, zo, clk, Q[2]);

    and zot(zot, zo, Q[2]);
    JKFF JKFF3(zot, zot, clk, Q[3]);
endmodule

module testbench;
    reg clk;
    wire [3:0] Q;
    always #1 clk = ~clk;

    counter_4bit counter(clk, Q);

    initial begin
        $monitor($time, " Q = %d", Q);
        #0 clk = 1'b0;
        #39 $finish;
    end
endmodule
