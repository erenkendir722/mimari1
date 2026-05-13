// Control Unit Testbench
// FETCH d??ng??s??n?? ve AND/ADD/LDA komutlar??n?? sim??le eder
`timescale 1ns/1ps

module control_unit_tb;

    reg         clk     = 0;
    reg         reset   = 1;
    reg  [15:0] ir_reg  = 16'h0000;
    reg         ac_sign = 0;
    reg         ac_zero = 0;
    reg         e_flag  = 0;

    // F1 ????k????lar??
    wire f1_add, f1_clrac, f1_incac, f1_drtac;
    wire f1_andac, f1_comac, f1_clre;

    // F2 ????k????lar??
    wire f2_sub, f2_or, f2_shl, f2_shr;
    wire f2_incpc, f2_artpc, f2_come;

    // F3 ????k????lar??
    wire f3_read, f3_write, f3_pctar, f3_irtar;
    wire f3_actdr, f3_incdr, f3_drtir;

    // Debug
    wire [6:0]  debug_car;
    wire [19:0] debug_mi;

    localparam CLK_PERiOD = 20; // ns

    // Saat ??reteci
    always #(CLK_PERiOD/2) clk = ~clk;

    // DUT
    control_unit uut (
        .clk(clk), .reset(reset),
        .ir_reg(ir_reg), .ac_sign(ac_sign),
        .ac_zero(ac_zero), .e_flag(e_flag),
        .f1_add(f1_add), .f1_clrac(f1_clrac),
        .f1_incac(f1_incac), .f1_drtac(f1_drtac),
        .f1_andac(f1_andac), .f1_comac(f1_comac),
        .f1_clre(f1_clre),
        .f2_sub(f2_sub), .f2_or(f2_or),
        .f2_shl(f2_shl), .f2_shr(f2_shr),
        .f2_incpc(f2_incpc), .f2_artpc(f2_artpc),
        .f2_come(f2_come),
        .f3_read(f3_read), .f3_write(f3_write),
        .f3_pctar(f3_pctar), .f3_irtar(f3_irtar),
        .f3_actdr(f3_actdr), .f3_incdr(f3_incdr),
        .f3_drtir(f3_drtir),
        .debug_car(debug_car), .debug_mi(debug_mi)
    );

    // Test s??reci
    initial begin
        $display("=== TEST BASLiYOR ===");

        // ?????? RESET ??????
        reset = 1;
        repeat(2) @(posedge clk);
        reset = 0;
        @(posedge clk);

        // ?????? FETCH D??NG??S?? TEST?? ??????
        $display("--- FETCH D??ng??s?? ---");

        // FETCH Ad??m 0 (0x40): AR ??? PC ??? f3_pctar aktif olmal??
        $display("CAR = %0d | f3_pctar = %b", debug_car, f3_pctar);
        if (debug_car !== 7'b1000000)
            $error("HATA: CAR reset sonrasi 0x40 olmali!");
        if (f3_pctar !== 1'b1)
            $error("HATA: FETCH-0 adiminda f3_pctar aktif olmali!");
        @(posedge clk);

        // FETCH Ad??m 1 (0x41): DR ??? M[AR], PC ??? PC+1
        $display("CAR = %0d | f3_read = %b | f2_incpc = %b", debug_car, f3_read, f2_incpc);
        if (f3_read !== 1'b1)
            $error("HATA: FETCH-1 adiminda f3_read aktif olmali!");
        if (f2_incpc !== 1'b1)
            $error("HATA: FETCH-1 adiminda f2_incpc aktif olmali!");
        @(posedge clk);

        // FETCH Ad??m 2 (0x42): iR ??? DR
        $display("CAR = %0d | f3_drtir = %b", debug_car, f3_drtir);
        if (f3_drtir !== 1'b1)
            $error("HATA: FETCH-2 adiminda f3_drtir aktif olmali!");
        @(posedge clk);

        // ?????? AND KOMUTU TEST?? (opcode=000) ??????
        $display("--- AND Komutu (opcode=000, i=0) ---");
        ir_reg = 16'b0000000000100000; // AND, direct, addr=0x020
        @(posedge clk); // FETCH Ad??m 3 (0x43): MAP ??? CAR ??? 0x00
        $display("CAR = %0d", debug_car);

        // AND 0x00: i=0 ??? ko??ul sa??lanmaz, CAR+1
        @(posedge clk);
        $display("AND-0: CAR = %0d", debug_car);

        // AND 0x01: DR ??? M[AR]
        @(posedge clk);
        $display("AND-1: CAR = %0d | f3_read = %b", debug_car, f3_read);

        // AND 0x02: AC ??? AC AND DR ??? f1_andac aktif
        @(posedge clk);
        $display("AND-2: CAR = %0d | f1_andac = %b", debug_car, f1_andac);
        if (f1_andac !== 1'b1)
            $error("HATA: AND execute adiminda f1_andac aktif olmali!");

        // Fetch'e d??nmeli (0x40)
        @(posedge clk);
        $display("Fetch'e donus: CAR = %0d", debug_car);
        if (debug_car !== 7'b1000000)
            $error("HATA: AND sonrasi FETCH'e (0x40) donmeli!");

        // ?????? ADD KOMUTU TEST?? (opcode=001) ??????
        $display("--- ADD Komutu (opcode=001, i=0) ---");
        repeat(3) @(posedge clk); // F0, F1, F2
        ir_reg = 16'b0010000000010000; // ADD, direct, addr=0x010
        @(posedge clk); // F3: MAP ??? CAR ??? 0x08

        // ADD 0x08: i=0 kontrol
        @(posedge clk);
        $display("ADD-0: CAR = %0d", debug_car);

        // ADD 0x09: DR ??? M[AR]
        @(posedge clk);
        $display("ADD-1: CAR = %0d | f3_read = %b", debug_car, f3_read);

        // ADD 0x0A: AC ??? AC + DR
        @(posedge clk);
        $display("ADD-2: CAR = %0d | f1_add = %b", debug_car, f1_add);
        if (f1_add !== 1'b1)
            $error("HATA: ADD execute adiminda f1_add aktif olmali!");

        @(posedge clk);
        if (debug_car !== 7'b1000000)
            $error("HATA: ADD sonrasi FETCH'e donmeli!");

        // ?????? LDA KOMUTU TEST?? (opcode=010) ??????
        $display("--- LDA Komutu (opcode=010, i=0) ---");
        repeat(3) @(posedge clk);
        ir_reg = 16'b0100000000110000; // LDA, direct
        @(posedge clk); // MAP ??? CAR ??? 0x10
        @(posedge clk); // LDA-0: i kontrol
        @(posedge clk); // LDA-1: DR ??? M[AR]
        @(posedge clk); // LDA-2: AC ??? DR
        $display("LDA-2: f1_drtac = %b", f1_drtac);
        if (f1_drtac !== 1'b1)
            $error("HATA: LDA execute adiminda f1_drtac aktif olmali!");

        @(posedge clk);
        if (debug_car !== 7'b1000000)
            $error("HATA: LDA sonrasi FETCH'e donmeli!");

        // ?????? TEST TAMAMLANDi ??????
        $display("=== TUM TESTLER TAMAMLANDi ===");
        repeat(5) @(posedge clk);
        $finish;
    end

endmodule
