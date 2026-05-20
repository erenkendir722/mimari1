// 16-bit Genel Ama??l?? Yazma??
// Kullan??m: AC, DR, TR, iR
module reg16 (
    input  wire        clk,
    input  wire        reset,
    input  wire        load,
    input  wire        clr,
    input  wire        inc,
    input  wire [15:0] data_in,
    output reg  [15:0] data_out
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            data_out <= 16'h0000;
        else if (clr)
            data_out <= 16'h0000;
        else if (load)
            data_out <= data_in;
        else if (inc)
            data_out <= data_out + 1;
    end
endmodule
