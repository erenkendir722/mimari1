// ALU — Aritmetik ve Mantıksal Birim
// op kodları:
//   000 = PASSA   001 = ADD   010 = AND   011 = COM
//   100 = SHR     101 = SHL   110 = INC   111 = OR
module alu (
    input  wire [15:0] a,
    input  wire [15:0] b,
    input  wire [2:0]  op,
    input  wire        carry_in,
    output reg  [15:0] result,
    output reg         carry_out
);
    always @(*) begin
        carry_out = 1'b0;
        case (op)
            3'b000: result = a;                              // PASSA
            3'b001: {carry_out, result} = {1'b0,a} + {1'b0,b}; // ADD
            3'b010: result = a & b;                          // AND
            3'b011: result = ~a;                             // COM
            3'b100: begin result = {carry_in, a[15:1]}; carry_out = a[0];  end // SHR
            3'b101: begin result = {a[14:0], carry_in}; carry_out = a[15]; end // SHL
            3'b110: {carry_out, result} = {1'b0,a} + 1;     // INC
            3'b111: result = a | b;                          // OR
            default: result = 16'h0000;
        endcase
    end
endmodule
