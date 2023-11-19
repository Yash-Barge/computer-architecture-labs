module bit1_mux_2to1(input in0, in1, select, output out);
    assign out = (in0 & ~select) | (in1 & select);
endmodule

module bit32_mux_2to1(input [31:0] in0, in1, input select, output [31:0] out);
    genvar i;
    for (i = 0; i < 32; i = i + 1)
        bit1_mux_2to1 bit32_mux(in0[i], in1[i], select, out[i]);
endmodule

module bit32_mux_4to1(input [31:0] in0, in1, in2, in3, input [1:0] select, output [31:0] out);
    wire [31:0] temp0, temp1;
    bit32_mux_2to1 mux0(in0, in1, select[0], temp0);
    bit32_mux_2to1 mux1(in2, in3, select[0], temp1);

    bit32_mux_2to1 mux_final(temp0, temp1, select[1], out);
endmodule

module bit32_and(input [31:0] in0, in1, output [31:0] out);
    assign out = in0 & in1;
endmodule

module bit32_or(input [31:0] in0, in1, output [31:0] out);
    assign out = in0 | in1;
endmodule
module bit32_not(input [31:0] in, output [31:0] out);
    assign out = ~in;
endmodule


module bit32_fa(input [31:0] in0, in1, input Cin, output [31:0] sum, output Cout);
    assign {Cout, sum} = in0 + in1 + Cin;
endmodule

// Should it have Cout as output, or just overflow bit directly?
/* operation:
 * 00 = AND
 * 01 = OR
 * 10 = ADD
 * 11 = SUB
*/
module ALU(input [31:0] a, b, input [1:0] operation, output [31:0] result, output Cout);
    assign Binvert = operation[1] & operation[0];
    assign Cin = Binvert;
    wire [31:0] not_b, b_fa_input, out_and, out_or, out_fa;

    bit32_not notb(b, not_b);
    bit32_mux_2to1 bmux(b, not_b, Binvert, b_fa_input);

    bit32_and and32(a, b, out_and);
    bit32_or or32(a, b, out_or);
    bit32_fa fa32(a, b_fa_input, Cin, out_fa, Cout);

    bit32_mux_4to1 final(out_and, out_or, out_fa, out_fa, operation, result);
endmodule

module testbench;
    reg [31:0] a, b;
    reg [1:0] op;
    wire [31:0] out;
    wire Cout;

    ALU test(a, b, op, out, Cout);

    initial begin
        $monitor($time, " a=%x, b=%x, op=%b | result=%x, Cout=%b", a, b, op, out, Cout);
        #0 a=32'ha5a5a5a5; b=32'h5a5a5a5a; op=2'b00; // AND
        #1 op=2'b01; // OR
        #1 op=2'b10; // ADD
        #1 op=2'b11; // SUB
        #1 $finish;
    end
endmodule
