// 12-bit Yazmaç
// Kullanım: AR (Address Register), PC (Program Counter)
module reg12 (
    input  wire        clk,
    input  wire        reset,
    input  wire        load,
    input  wire        clr,
    input  wire        inc,
    input  wire [11:0] data_in,
    output reg  [11:0] data_out
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            data_out <= 12'h000;
        else if (clr)
            data_out <= 12'h000;
        else if (load)
            data_out <= data_in;
        else if (inc)
            data_out <= data_out + 1;
    end
endmodule
