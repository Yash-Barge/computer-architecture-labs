module adder_1bit (A, B, Cin, sum, Cout);
    input A, B, Cin;
    output sum, Cout;

    assign sum = A ^ B ^ Cin;
    assign Cout = (A&B) | ((A^B)&Cin);
endmodule

module adder_4bit (A, B, Cin, sum, Cout);
    input [3:0] A;
    input [3:0] B;
    input Cin;

    output [3:0] sum;
    output Cout;

    wire [3:0] carry = 3'b000;

    adder_1bit adder0(A[0], B[0], 0, sum[0], carry[0]);
    adder_1bit adder1(A[1], B[1], carry[0], sum[1], carry[1]);
    adder_1bit adder2(A[2], B[2], carry[1], sum[2], carry[2]);
    adder_1bit adder3(A[3], B[3], carry[2], sum[3], Cout);
endmodule

module testbench;
    reg [3:0] A;
    reg [3:0] B;
    wire [3:0] sum;
    wire Cout;

    adder_4bit add(A, B, 0, sum, Cout);
    initial
        begin
            $monitor($time, " A=%b, B=%b | sum=%b, Cout=%b", A, B, sum, Cout);
            #0 A=4'b1010; B=4'b0101;
            #1 $finish;
        end
endmodule
