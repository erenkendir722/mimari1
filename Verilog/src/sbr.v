// Subroutine Register (SBR) - 7-bit
// CALL: SBR <- CAR+1
// RET : CAR <- SBR
module sbr (
    input  wire       clk,
    input  wire       reset,
    input  wire       load,
    input  wire [6:0] data_in,
    output reg  [6:0] data_out
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            data_out <= 7'b0;
        else if (load)
            data_out <= data_in;
    end
endmodule
