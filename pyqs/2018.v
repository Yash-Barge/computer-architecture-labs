`timescale 1ms/100us

module dff(input D, clk, reset, output reg Q);
    always @(*)
        if (reset)
            Q <= 1'b1;

    always @(posedge clk)
        Q <= D;
endmodule

module ControlLogic(input S, Z, X, clk, reset, output T0, T1, T2);
    not notS(notS, S);
    not notX(notX, X);
    not notZ(notZ, Z);

    and t0a1(t0a1, T0, notS);
    and t0a2(t0a2, T2, Z);
    or t0o1(t0o1, t0a1, t0a2);
    dff t0(t0o1, clk, reset, T0);

    and t1a1(t1a1, T0, S);
    and t1a2(t1a2, T2, notX, notZ);
    and t1a3(t1a3, T1, notX);
    or t1o1(t1o1, t1a1, t1a2, t1a3);
    dff t1(t1o1, clk, 1'b0, T1);

    and t2a1(t2a1, T1, X);
    and t2a2(t2a2, T2, notZ, X);
    or t2o1(t2o1, t2a1, t2a2);
    dff t2(t2o1, clk, 1'b0, T2);
endmodule

module TFF(input T, clk, clear, en, output reg Q);
    always @(posedge clk)
        if (clear)
            Q <= 1'b0;
        else if (T && en)
            Q <= ~Q;
endmodule

module COUNTER_4BIT(input clear, clk, en, output [3:0] Q);
    TFF bit0(1'b1, clk, clear, en, Q[0]);
    TFF bit1(Q[0], clk, clear, en, Q[1]);

    and a1(a1, Q[0], Q[1]);
    TFF bit2(a1, clk, clear, en, Q[2]);

    and a2(a2, a1, Q[2]);
    TFF bit3(a2, clk, clear, en, Q[3]);
endmodule

module INTG(input S, X, clk, reset, output [3:0] count, output G);
    wire T0, T1, T2;

    and clear(clear, T0, S);
    and Z(Z, count[3], count[2], count[1], count[0]);

    wire en;
    assign en = (T1 & X) | (T2 & ~Z & X);

    COUNTER_4BIT counter(clear, clk, en, count);

    ControlLogic controller(S, Z, X, clk, reset, T0, T1, T2);

    and da(da, T2, Z);
    dff dag(da, clk, 1'b0, G);
endmodule

module testbench();
    reg clk;
    initial clk = 1'b0;
    always #0.5 clk = ~clk;

    reg S, X;
    initial begin S = 1'b1; X = 1'b1; end

    reg reset;
    initial reset = 1'b1;

    wire [3:0] count;
    wire G;

    INTG final(S, X, clk, reset, count, G);

    initial begin
        $monitor($time, " count=%d, G=%b", count, G);
        #1 reset = 1'b0;
        #100 $finish;
    end
endmodule
