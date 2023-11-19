module comparator_4bit (A, B, out);
    input signed [3:0] A;
    input signed [3:0] B;
    output [2:0] out;
    reg [2:0] out;

    always@(A or B) begin
        if (A == B) out = 3'b010;
        else if (A > B) out = 3'b100;
        else out = 3'b001;
    end
endmodule

module testbench;
    reg signed [3:0] A;
    reg signed [3:0] B;
    wire [2:0] out;

    comparator_4bit comp (A, B, out);

    initial
        begin
            $monitor($time, " A=%d, B=%d | A>B = %b, A==B = %b, A<B = %b", A, B, out[2], out[1], out[0]);
            #0 A=4'd0; B=4'd0;
            #1 A=-4'd8; B=-4'd5;
            #1 A=4'd2; B=4'd7;
            #1 A=4'd5; B=-4'd1;
        end
endmodule
