module bcd_to_gray_gate (bcd_in, gray_out);
    input [3:0] bcd_in;
    output [3:0] gray_out;

    xor x3(gray_out[3], 0, bcd_in[3]);
    xor x2(gray_out[2], bcd_in[3], bcd_in[2]);
    xor x1(gray_out[1], bcd_in[2], bcd_in[1]);
    xor x0(gray_out[0], bcd_in[1], bcd_in[0]);
endmodule

module bcd_to_gray_df (bcd_in, gray_out);
    input [3:0] bcd_in;
    output [3:0] gray_out;

    assign gray_out[3] = bcd_in[3];
    assign gray_out[2] = bcd_in[3] ? ~bcd_in[2] : bcd_in[2];
    assign gray_out[1] = bcd_in[2] ? ~bcd_in[1] : bcd_in[1];
    assign gray_out[0] = bcd_in[1] ? ~bcd_in[0] : bcd_in[0];
endmodule

module testbench;
    reg [3:0] bcd_in;
    wire [3:0] gray_out;
    bcd_to_gray_df bcd_to_gray (bcd_in, gray_out);
    initial
        begin
            $monitor($time, " bcd_in=%b, gray_out=%b", bcd_in, gray_out);
            #0 bcd_in=4'b0000;
            #1 bcd_in=4'b0001;
            #1 bcd_in=4'b0010;
            #1 bcd_in=4'b0011;
            #1 bcd_in=4'b0100;
            #1 bcd_in=4'b0101;
            #1 bcd_in=4'b0110;
            #1 bcd_in=4'b0111;
            #1 bcd_in=4'b1000;
            #1 bcd_in=4'b1001;
            #1 $finish;
        end
endmodule
