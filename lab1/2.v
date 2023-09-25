module compare_bh (A, B, out);
    input [3:0] A;
    input [3:0] B;
    output [2:0] out;
    reg [2:0] out;

    always@(A or B) begin
        out[2] = A < B;
        out[1] = A > B;
        out[0] = A == B;
    end
endmodule

module compare_df (A, B, out);
    input [3:0] A;
    input [3:0] B;
    output [2:0] out;

    assign out[2] = A < B;
    assign out[1] = A > B;
    assign out[0] = A == B;
endmodule

module compare_gate (A, B, out);
    input [3:0] A;
    input [3:0] B;
    output [2:0] out;

    not na3(na3, A[3]);
    not na2(na2, A[2]);
    not na1(na1, A[1]);
    not na0(na0, A[0]);
    not nb3(nb3, B[3]);
    not nb2(nb2, B[2]);
    not nb1(nb1, B[1]);
    not nb0(nb0, B[0]);

    and a3nb3(a3nb3, A[3], nb3);
    and na3b3(na3b3, na3, B[3]);
    and a2nb2(a2nb2, A[2], nb2);
    and na2b2(na2b2, na2, B[2]);
    and a1nb1(a1nb1, A[1], nb1);
    and na1b1(na1b1, na1, B[1]);
    and a0nb0(a0nb0, A[0], nb0);
    and na0b0(na0b0, na0, B[0]);

    xnor x3(x3, a3nb3, na3b3);
    xnor x2(x2, a2nb2, na2b2);
    xnor x1(x1, a1nb1, na1b1);
    xnor x0(x0, a0nb0, na0b0);

    and i2and0(i2and0, x3, na2b2);
    and i2and1(i2and1, x3, a2nb2);

    and x3x2(x3x2, x3, x2);
    and i3and0(i3and0, x3x2, na1b1);
    and i3and1(i3and1, x3x2, a1nb1);

    and x3x2x1(x3x2x1, x3x2, x1);
    and i4and0(i4and0, x3x2x1, na0b0);
    and i4and1(i4and1, x3x2x1, a0nb0);

    and(out[0], x3x2x1, x0);

    or out1_0(out1_0, a3nb3, i2and1);
    or out1_1(out1_1, i3and1, i4and1);

    or(out[1], out1_0, out1_1);

    or out2_0(out2_0, na3b3, i2and0);
    or out2_1(out2_1, i3and0, i4and0);

    or(out[2], out2_0, out2_1);
endmodule

module testbench;
    reg [3:0] A;
    reg [3:0] B;
    wire [2:0] out;
    compare_gate compare (A, B, out);
    initial
        begin
            $monitor($time, " A=%b, B=%b, out=%b", A, B, out);
            #0 A=4'b0011; B=4'b0000; // A: 010
            #1 A=4'b1010; B=4'b0001; // A: 010
            #1 A=4'b0001; B=4'b0010; // B: 100
            #1 A=4'b1100; B=4'b0011; // A: 010
            #1 A=4'b1011; B=4'b0100; // A: 010
            #1 A=4'b1010; B=4'b1101; // B: 100
            #1 A=4'b1001; B=4'b1110; // B: 100
            #1 A=4'b1000; B=4'b0111; // A: 010
            #1 A=4'b0111; B=4'b1000; // B: 100
            #1 A=4'b1001; B=4'b1001; // =: 001
            #1 $finish;
        end
endmodule
