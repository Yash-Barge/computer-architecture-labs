module mux_4_1 (input_lines, select_lines, output_line);
    input [3:0] input_lines;
    input [1:0] select_lines;
    output output_line;

    not ns1(ns1, select_lines[1]);
    not ns0(ns0, select_lines[0]);

    and a0(a0, input_lines[0], ns1, ns0);
    and a1(a1, input_lines[1], ns1, select_lines[0]);
    and a2(a2, input_lines[2], select_lines[1], ns0);
    and a3(a3, input_lines[3], select_lines[1], select_lines[0]);

    or ans(output_line, a0, a1, a2, a3);
endmodule

module mux_16_1 (input_lines, select_lines, output_line);
    input [15:0] input_lines;
    input [3:0] select_lines;
    output output_line;

    wire [3:0] temp;

    mux_4_1 mux0 (input_lines[3:0], select_lines[1:0], temp[0]);
    mux_4_1 mux1 (input_lines[7:4], select_lines[1:0], temp[1]);
    mux_4_1 mux2 (input_lines[11:8], select_lines[1:0], temp[2]);
    mux_4_1 mux3 (input_lines[15:12], select_lines[1:0], temp[3]);

    mux_4_1 mux_final(temp, select_lines[3:2], output_line);
endmodule

module testbench;
    reg [15:0] input_lines;
    reg [3:0] select_lines;
    wire output_line;

    mux_16_1 mux16to1 (input_lines, select_lines, output_line);

    initial
        begin
            $monitor($time, " input_lines=%b, select_lines=%b | output=%b", input_lines, select_lines, output_line);
            #0 input_lines=16'b1010101010101010; select_lines=4'b1111;
            #1 select_lines=4'b1110;
            #1 select_lines=4'b1101;
            #1 select_lines=4'b1100;
            #1 select_lines=4'b1011;
            #1 select_lines=4'b1010;
            #1 select_lines=4'b1001;
            #1 select_lines=4'b1000;
            #1 select_lines=4'b0111;
            #1 select_lines=4'b0110;
            #1 select_lines=4'b0101;
            #1 select_lines=4'b0100;
            #1 select_lines=4'b0011;
            #1 select_lines=4'b0010;
            #1 select_lines=4'b0001;
            #1 select_lines=4'b0000;

            #5 input_lines=16'b0101010101010101; select_lines=4'b1111;
            #1 select_lines=4'b1110;
            #1 select_lines=4'b1101;
            #1 select_lines=4'b1100;
            #1 select_lines=4'b1011;
            #1 select_lines=4'b1010;
            #1 select_lines=4'b1001;
            #1 select_lines=4'b1000;
            #1 select_lines=4'b0111;
            #1 select_lines=4'b0110;
            #1 select_lines=4'b0101;
            #1 select_lines=4'b0100;
            #1 select_lines=4'b0011;
            #1 select_lines=4'b0010;
            #1 select_lines=4'b0001;
            #1 select_lines=4'b0000;
        end
endmodule
