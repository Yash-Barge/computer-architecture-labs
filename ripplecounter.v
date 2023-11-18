module RS_FF(input r, s, clk, reset, output reg q);
    always @(reset)
        if (~reset)
            q <= 1'b0;
    
    always @(posedge clk)
        if (r)
            q <= 1'b0;
        else if (s)
            q <= 1'b1;
endmodule

module D_FF(input d, clk, reset, output q);
    // always @(reset)
    //     if (~reset)
    //         q <= 1'b0;

    // always @(posedge clk) 
    //     q <= d;

    RS_FF test(~d, d, clk, reset, q);
endmodule

module counter_4bit(input clk, reset);
    wire [3:0] q;
    reg [3:0] qbar;

    always @(q)
        qbar <= ~q;
    
    D_FF ff0(qbar[0], clk, reset, q[0]);
    D_FF ff1(qbar[1], qbar[0], reset, q[1]);
    D_FF ff2(qbar[2], qbar[1], reset, q[2]);
    D_FF ff3(qbar[3], qbar[2], reset, q[3]);

    initial begin
        $monitor($time, " q = %d", q);
        #50 $finish;
    end
endmodule

module testbench;
    reg q;
    initial q = 1'b0;

    reg clk;
    initial clk = 1'b1;
    always #1 clk = ~clk;

    reg reset;
    initial begin
        reset = 1'b0;
        #1 reset = 1'b1;
    end

    counter_4bit test(clk, reset);
endmodule