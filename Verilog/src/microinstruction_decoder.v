// Microinstruction Decoder - 20-bit mikrokomutu kontrol sinyallerine çevirir
module microinstruction_decoder (
    input  wire [19:0] microinstruction,

    // F1 çıkışları (ALU / AC)
    output wire f1_add,
    output wire f1_clrac,
    output wire f1_incac,
    output wire f1_drtac,
    output wire f1_andac,
    output wire f1_comac,
    output wire f1_clre,

    // F2 çıkışları (Yazmaç / Shift)
    output wire f2_sub,
    output wire f2_or,
    output wire f2_shl,
    output wire f2_shr,
    output wire f2_incpc,
    output wire f2_artpc,
    output wire f2_come,

    // F3 çıkışları (Bellek / I-O)
    output wire f3_read,
    output wire f3_write,
    output wire f3_pctar,
    output wire f3_irtar,
    output wire f3_actdr,
    output wire f3_incdr,
    output wire f3_drtir,

    // Dallanma alanları
    output wire [1:0] cd_field,
    output wire [1:0] br_field,
    output wire [6:0] ad_field
);
    wire [2:0] f1 = microinstruction[19:17];
    wire [2:0] f2 = microinstruction[16:14];
    wire [2:0] f3 = microinstruction[13:11];

    assign cd_field = microinstruction[10:9];
    assign br_field = microinstruction[8:7];
    assign ad_field = microinstruction[6:0];

    // F1
    assign f1_add   = (f1 == 3'b001);
    assign f1_clrac = (f1 == 3'b010);
    assign f1_incac = (f1 == 3'b011);
    assign f1_drtac = (f1 == 3'b100);
    assign f1_andac = (f1 == 3'b101);
    assign f1_comac = (f1 == 3'b110);
    assign f1_clre  = (f1 == 3'b111);

    // F2
    assign f2_sub   = (f2 == 3'b001);
    assign f2_or    = (f2 == 3'b010);
    assign f2_shl   = (f2 == 3'b011);
    assign f2_shr   = (f2 == 3'b100);
    assign f2_incpc = (f2 == 3'b101);
    assign f2_artpc = (f2 == 3'b110);
    assign f2_come  = (f2 == 3'b111);

    // F3
    assign f3_read  = (f3 == 3'b001);
    assign f3_write = (f3 == 3'b010);
    assign f3_pctar = (f3 == 3'b011);
    assign f3_irtar = (f3 == 3'b100);
    assign f3_actdr = (f3 == 3'b101);
    assign f3_incdr = (f3 == 3'b110);
    assign f3_drtir = (f3 == 3'b111);

endmodule
