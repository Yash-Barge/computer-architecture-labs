module decoder_8_3 (in, out);
    input [2:0] in;
    output [7:0] out;

    wire [2:0] nin;

    not(nin[0], in[0]);
    not(nin[1], in[1]);
    not(nin[2], in[2]);

    and(out[0], nin[0], nin[1], nin[2]);
    and(out[1], in[0], nin[1], nin[2]);
    and(out[2], nin[0], in[1], nin[2]);
    and(out[3], in[0], in[1], nin[2]);
    and(out[4], nin[0], nin[1], in[2]);
    and(out[5], in[0], nin[1], in[2]);
    and(out[6], nin[0], in[1], in[2]);
    and(out[7], in[0], in[1], in[2]);
endmodule

module full_adder (x, y, z, sum, carry);
    input x, y, z;
    output sum, carry;

    wire [2:0] in = {x, y, z};
    wire [7:0] temp;

    decoder_8_3 decode (in, temp);

    assign sum = temp[1] || temp[2] || temp[4] || temp[7];
    assign carry = temp[3] || temp[5] || temp[6] || temp[7];
endmodule

module testbench;
    reg [2:0] in;
    wire sum, carry;

    full_adder fa (in[2], in[1], in[0], sum, carry);

    initial
        begin
            $monitor($time, " in=%b | sum=%b, carry=%b", in, sum, carry);
            #0 in=3'b000;
            #1 in=3'b001;
            #1 in=3'b010;
            #1 in=3'b011;
            #1 in=3'b100;
            #1 in=3'b101;
            #1 in=3'b110;
            #1 in=3'b111;
        end
endmodule
