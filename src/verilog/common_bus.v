// Common Bus ??? 16-bit Ortak Veri Yolu
// sel | Kaynak
// 000 | (s??f??r)
// 001 | AR (12-bit, ??st 4 bit = 0)
// 010 | PC (12-bit, ??st 4 bit = 0)
// 011 | DR
// 100 | AC
// 101 | iR
// 110 | TR
// 111 | iNPR (8-bit, ??st 8 bit = 0)
module common_bus (
    input  wire [2:0]  sel,
    input  wire [11:0] ar_in,
    input  wire [11:0] pc_in,
    input  wire [15:0] dr_in,
    input  wire [15:0] ac_in,
    input  wire [15:0] ir_in,
    input  wire [15:0] tr_in,
    input  wire [7:0]  inpr_in,
    output reg  [15:0] bus_out
);
    always @(*) begin
        case (sel)
            3'b000: bus_out = 16'h0000;
            3'b001: bus_out = {4'b0000, ar_in};
            3'b010: bus_out = {4'b0000, pc_in};
            3'b011: bus_out = dr_in;
            3'b100: bus_out = ac_in;
            3'b101: bus_out = ir_in;
            3'b110: bus_out = tr_in;
            3'b111: bus_out = {8'h00, inpr_in};
            default: bus_out = 16'h0000;
        endcase
    end
endmodule
