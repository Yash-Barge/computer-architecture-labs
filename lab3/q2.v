module state_machine(clk, reset, in, out);
    input clk, reset, in;
    output out;
    reg out;

    reg [2:0] state;

    initial begin
        state = 3'b000;
        out = 0;
    end

    always @(posedge reset or posedge clk) begin
        if (reset) begin
            state <= 3'b000;
            out <= 0;
        end else begin
            case (state)
                3'b000: begin
                    if (in) begin
                        state <= 3'b001;
                        out <= 0;
                    end else
                        out <= 0;
                end
                3'b001: begin
                    if (in)
                        out <= 0;
                    else begin
                        state <= 3'b010;
                        out <= 0;
                    end
                end
                3'b010: begin
                    if (in) begin
                        state <= 3'b011;
                        out <= 0;
                    end else begin
                        state <= 3'b000;
                        out <= 0;
                    end
                end
                3'b011: begin
                    if (in) begin
                        state <= 3'b100;
                        out <= 0;
                    end else begin
                        state <= 3'b010;
                        out <= 0;
                    end
                end
                3'b100: begin
                    if (in) begin
                        state <= 3'b001;
                        out <= 0;
                    end else begin
                        state <= 3'b010;
                        out <= 1;
                    end
                end
            endcase
        end
    end
endmodule

// Doesn't work, why?
module testbench;
    reg clk, reset, in;
    wire out;
    always #1 clk = ~clk;

    state_machine sm0(clk, reset, in, out);

    initial begin
        $monitor($time, " Detected! ", out);
        #2 in = 1;
        #2 in = 0;
        #2 in = 1;
        #2 in = 1;
        #2 in = 0;
        #2 $finish;
    end
endmodule
