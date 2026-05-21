// Control Memory - 128 x 20-bit ROM (Mikroprogram)
//
// Mikrokomut Formatı [19:0]:
//   F1[19:17] F2[16:14] F3[13:11] CD[10:9] BR[8:7] AD[6:0]
//
// F1: 000=NOP 001=ADD 010=CLRAC 011=iNCAC 100=DRTAC 101=ANDAC 110=COMAC 111=CLRE
// F2: 000=NOP 001=SUB 010=OR   011=SHL   100=SHR   101=iNCPC 110=ARTPC 111=COME
// F3: 000=NOP 001=READ 010=WRiTE 011=PCTAR 100=iRTAR 101=ACTDR 110=iNCDR 111=DRTiR
// CD: 00=U 01=i(iR[15]) 10=S(AC[15]) 11=Z(AC=0)
// BR: 00=JMP 01=CALL 10=RET 11=MAP
//
// Bellek Haritası:
//   0x00-0x07: AND   0x08-0x0F: ADD   0x10-0x17: LDA   0x18-0x1F: STA
//   0x20-0x27: BUN   0x28-0x2F: BSA   0x30-0x37: iSZ   0x38-0x3F: Reg-ref/iO
//   0x40-0x47: FETCH 0x48-0x4F: iNDiRECT

module control_memory (
    input  wire [6:0]  address,
    output wire [19:0] data
);
    reg [19:0] rom [0:127];

    // Alan sabitleri (bit dizgileri)
    // F1
    localparam NOP1  = 3'b000;
    localparam ADD1  = 3'b001;
    localparam CLRAC = 3'b010;
    localparam iNCAC = 3'b011;
    localparam DRTAC = 3'b100;
    localparam ANDAC = 3'b101;
    localparam COMAC = 3'b110;
    localparam CLRE  = 3'b111;
    // F2
    localparam NOP2  = 3'b000;
    localparam SUB2  = 3'b001;
    localparam ORAC  = 3'b010;
    localparam SHL2  = 3'b011;
    localparam SHR2  = 3'b100;
    localparam iNCPC = 3'b101;
    localparam ARTPC = 3'b110;
    localparam COME  = 3'b111;
    // F3
    localparam NOP3  = 3'b000;
    localparam READM = 3'b001;
    localparam WRTEM = 3'b010;
    localparam PCTAR = 3'b011;
    localparam iRTAR = 3'b100;
    localparam ACTDR = 3'b101;
    localparam iNCDR = 3'b110;
    localparam DRTiR = 3'b111;
    // CD
    localparam U = 2'b00;
    localparam i = 2'b01;
    localparam S = 2'b10;
    localparam Z = 2'b11;
    // BR
    localparam JMP  = 2'b00;
    localparam CALL = 2'b01;
    localparam RET  = 2'b10;
    localparam MAP  = 2'b11;

    localparam FETCH = 7'b1000000; // 0x40
    localparam iNDiR = 7'b1001000; // 0x48

    integer k;

    initial begin
        // Tümünü NOP ile başlat
        for (k = 0; k < 128; k = k + 1)
            rom[k] = 20'h00000;

        // -- AND (0x00-0x02) --
        rom[0]  = {NOP1, NOP2, NOP3, i,    CALL, iNDiR};
        rom[1]  = {NOP1, NOP2, READM, U,   JMP,  7'b0000010};
        rom[2]  = {ANDAC, NOP2, NOP3, U,   JMP,  FETCH};

        // -- ADD (0x08-0x0A) --
        rom[8]  = {NOP1, NOP2, NOP3, i,    CALL, iNDiR};
        rom[9]  = {NOP1, NOP2, READM, U,   JMP,  7'b0001010};
        rom[10] = {ADD1, NOP2, NOP3, U,    JMP,  FETCH};

        // -- LDA (0x10-0x12) --
        rom[16] = {NOP1, NOP2, NOP3, i,    CALL, iNDiR};
        rom[17] = {NOP1, NOP2, READM, U,   JMP,  7'b0010010};
        rom[18] = {DRTAC, NOP2, NOP3, U,   JMP,  FETCH};

        // -- STA (0x18-0x1A) --
        rom[24] = {NOP1, NOP2, NOP3, i,    CALL, iNDiR};
        rom[25] = {NOP1, NOP2, ACTDR, U,   JMP,  7'b0011010};
        rom[26] = {NOP1, NOP2, WRTEM, U,   JMP,  FETCH};

        // -- BUN (0x20-0x21) --
        rom[32] = {NOP1, NOP2, NOP3, i,    CALL, iNDiR};
        rom[33] = {NOP1, ARTPC, NOP3, U,   JMP,  FETCH};

        // -- BSA (0x28-0x2C) --
        // BSA: M[AR]<-PC, PC<-AR+1
        // ACTDR sinyali üst modülde bus_sel=PC -> DR yüklemesine dönüşür
        rom[40] = {NOP1, NOP2, NOP3, i,    CALL, iNDiR};
        rom[41] = {NOP1, NOP2, ACTDR, U,   JMP,  7'b0101010}; // DR<-PC (bus_sel=PC)
        rom[42] = {NOP1, NOP2, WRTEM, U,   JMP,  7'b0101011}; // M[AR]<-DR
        rom[43] = {NOP1, ARTPC, NOP3, U,   JMP,  7'b0101100}; // PC<-AR
        rom[44] = {NOP1, iNCPC, NOP3, U,   JMP,  FETCH};      // PC<-PC+1

        // -- ISZ (0x30-0x36) --
        // ISZ: DR<-M[AR], DR<-DR+1, M[AR]<-DR, if DR=0 -> PC++
        // Z koşulu AC=0 kontrol eder; önce AC<-DR yapılır
        rom[48] = {NOP1, NOP2, NOP3, i,    CALL, iNDiR};
        rom[49] = {NOP1, NOP2, READM, U,   JMP,  7'b0110010}; // DR<-M[AR]
        rom[50] = {NOP1, NOP2, iNCDR, U,   JMP,  7'b0110011}; // DR<-DR+1
        rom[51] = {NOP1, NOP2, WRTEM, U,   JMP,  7'b0110100}; // M[AR]<-DR
        rom[52] = {DRTAC, NOP2, NOP3, U,   JMP,  7'b0110101}; // AC<-DR
        rom[53] = {NOP1, iNCPC, NOP3, Z,   JMP,  FETCH};      // if AC=0: PC++
        rom[54] = {NOP1, NOP2, NOP3, U,    JMP,  FETCH};      // DR!=0: fetch

        // -- Reg-ref / I-O (0x38-0x3F) --
        // 0x38: if IR[15]=1 -> I/O (0x3C), else -> reg-ref (0x39)
        rom[56] = {NOP1, NOP2, NOP3, i,    JMP,  7'b0111100}; // i=1 -> 0x3C
        // Register-reference örnekleri (IR bitine göre gerçek tasarımda decode edilir)
        rom[57] = {CLRAC, NOP2, NOP3, U,   JMP,  FETCH};      // CLA
        rom[58] = {NOP1, NOP2, NOP3, U,    JMP,  FETCH};      // CLE (E<-0: f1_clre gerek)
        rom[59] = {COMAC, NOP2, NOP3, U,   JMP,  FETCH};      // CMA
        // I/O (0x3C-0x3F) -- yer tutucu
        rom[60] = 20'h00000;
        rom[61] = 20'h00000;
        rom[62] = 20'h00000;
        rom[63] = 20'h00000;

        // -- FETCH (0x40-0x43) --
        rom[64] = {NOP1, NOP2, PCTAR, U,   JMP,  7'b1000001}; // AR<-PC
        rom[65] = {NOP1, iNCPC, READM, U,  JMP,  7'b1000010}; // DR<-M[AR], PC++
        rom[66] = {NOP1, NOP2, DRTiR, U,   JMP,  7'b1000011}; // IR<-DR
        rom[67] = {NOP1, NOP2, iRTAR, U,   MAP,  7'b0000000}; // AR<-IR[11:0], MAP

        // -- INDIRECT alt programı (0x48-0x4A) --
        rom[72] = {NOP1, NOP2, READM, U,   JMP,  7'b1001001}; // DR<-M[AR]
        rom[73] = {NOP1, NOP2, DRTiR, U,   JMP,  7'b1001010}; // IR<-DR (ge??ici)
        rom[74] = {NOP1, NOP2, iRTAR, U,   RET,  7'b0000000}; // AR<-IR[11:0], RET
    end

    assign data = rom[address];

endmodule
