module REG_8BIT(output reg [7:0] reg_out, input [7:0] num_in, input clock, reset);
    always @(*)
        if (reset)
            reg_out <= 8'h00;
    
    always @(posedge clock)
        reg_out <= num_in;
endmodule

module EXPANSION_BOX(input [3:0] in, output [7:0] out);
    assign out[0] = in[0];
    assign out[1] = in[2];
    assign out[2] = in[3];
    assign out[3] = in[1];
    assign out[4] = in[2];
    assign out[5] = in[1];
    assign out[6] = in[0];
    assign out[7] = in[3];
endmodule

module XOR_8BIT(output [7:0] xout_8, input [7:0] xin1_8, xin2_8);
    assign xout_8 = xin1_8 ^ xin2_8;
endmodule

module XOR_4BIT(output [3:0] xout_4, input [3:0] xin1_4, xin2_4);
    assign xout_4 = xin1_4 ^ xin2_4;
endmodule

module adder_1bit(input A, B, Cin, output sum, Cout);
    assign sum = A ^ B ^ Cin;
    assign Cout = (A & B) | (B & Cin) | (Cin & A);
endmodule

module adder_4bit(input [3:0] A, B, input Cin, output [3:0] sum, output Cout);
    wire [2:0] carries;
    
    adder_1bit add0(A[0], B[0], Cin, sum[0], carries[0]);
    adder_1bit add1(A[1], B[1], carries[0], sum[1], carries[1]);
    adder_1bit add2(A[2], B[2], carries[1], sum[2], carries[2]);
    adder_1bit add3(A[3], B[3], carries[2], sum[3], Cout);
endmodule


module mux_1bit_2to1(input A, B, S, output out);
    assign out = S ? B : A;
endmodule

module mux_4bit_2to1(input [3:0] A, B, input S, output [3:0] out);
    assign out = S ? B : A;
endmodule

module CSA_4BIT(input cin, input [3:0] inA, inB, output cout, output [3:0] out);
    wire [3:0] sum0;
    wire [3:0] sum1;
    wire carry0, carry1;

    adder_4bit zero(inA, inB, 1'b0, sum0, carry0);
    adder_4bit one(inA, inB, 1'b1, sum1, carry1);

    mux_1bit_2to1 small_mux(carry0, carry1, cin, cout);
    mux_4bit_2to1 big_mux(sum0, sum1, cin, out);
endmodule

module CSA_4BIT_ALT(input cin, input [3:0] inA, inB, output cout, output [3:0] out);
    assign { cout, out } = inA + inB + cin;
endmodule

module CONCAT(output [7:0] concat_out, input [3:0] concat_in1, concat_in2);
    assign concat_out[7:4] = concat_in1;
    assign concat_out[3:0] = concat_in2;
endmodule

module ENCRYPT(input [7:0] number, key, input clock, reset, output [7:0] enc_number);
    wire [7:0] num_out;
    wire [7:0] key_out;
    REG_8BIT num_reg(num_out, number, clock, reset);
    REG_8BIT key_reg(key_out, key, clock, reset);

    wire [7:0] new_num;
    EXPANSION_BOX box(num_out[3:0], new_num);

    wire [7:0] xor_out_8bit;
    XOR_8BIT big_xor(xor_out_8bit, new_num, key_out);

    wire [3:0] csa_out;
    wire Cout;
    CSA_4BIT csa(key_out[0], xor_out_8bit[7:4], xor_out_8bit[3:0], Cout, csa_out);

    wire [3:0] xor_out_4bit;
    XOR_4BIT small_xor(xor_out_4bit, num_out[7:4], csa_out);

    CONCAT final(enc_number, xor_out_4bit, num_out[3:0]);
endmodule

module testbench();
    reg clock, reset;
    reg [7:0] number;
    reg [7:0] key;
    wire [7:0] enc_number;

    initial reset = 1'b0;
    initial clock = 1'b0;
    always #1 clock = ~clock;

    ENCRYPT box(number, key, clock, reset, enc_number);

    initial begin
        $monitor("number=%x, key=%x | enc_number=%x", number, key, enc_number);

        #1
        number = 8'b01000110;
        key = 8'b10010011;

        #2
        number = 8'b11001001;
        key = 8'b10101100;

        #2
        number = 8'b10100101;
        key = 8'b01011010;

        #2
        number = 8'b11110000;
        key = 8'b10110001;

        #2 $finish;
    end
endmodule
