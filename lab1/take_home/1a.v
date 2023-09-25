module adder_gate (A, B, Cin, sum, Cout);
    input A, B, Cin;
    output sum, Cout;

    xor axorb(axorb, A, B);
    xor(sum, axorb, Cin);

    and aandb(aandb, A, B);
    and axorbandcin(axorbandcin, axorb, Cin);
    or(Cout, aandb, axorbandcin);
endmodule

module adder_df (A, B, Cin, sum, Cout);
    input A, B, Cin;
    output sum, Cout;

    assign sum = A ^ B ^ Cin;
    assign Cout = (A&B) | ((A^B)&Cin);
endmodule

module testbench;
    reg A, B, Cin;
    wire sum, Cout;

    adder_df adder (A, B, Cin, sum, Cout);
    initial
        begin
            $monitor($time, " A=%b, B=%b, Cin=%b | sum=%b, Cout=%b", A, B, Cin, sum, Cout);
            #0 A=1'b0; B=1'b0; Cin=1'b0;
            #1 A=1'b0; B=1'b1; Cin=1'b0;
            #1 A=1'b1; B=1'b0; Cin=1'b0;
            #1 A=1'b1; B=1'b1; Cin=1'b0;
            #1 A=1'b0; B=1'b0; Cin=1'b1;
            #1 A=1'b0; B=1'b1; Cin=1'b1;
            #1 A=1'b1; B=1'b0; Cin=1'b1;
            #1 A=1'b1; B=1'b1; Cin=1'b1;
            #1 $finish;
        end
endmodule
