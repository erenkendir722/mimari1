// RAM - 4096 x 16-bit Senkron Bellek
module ram4096 (
    input  wire        clk,
    input  wire [11:0] address,
    input  wire [15:0] data_in,
    input  wire        read,
    input  wire        write,
    output reg  [15:0] data_out
);
    reg [15:0] mem [0:4095];

    integer i;
    initial begin
        for (i = 0; i < 4096; i = i + 1)
            mem[i] = 16'h0000;
    end

    always @(posedge clk) begin
        if (write)
            mem[address] <= data_in;
        else if (read)
            data_out <= mem[address];
    end
endmodule
