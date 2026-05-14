// Control Unit Testbench
// FETCH döngüsünü ve AND/ADD/LDA komutlarını simüle eder
`timescale 1ns/1ps

module control_unit_tb;

    reg         clk     = 0;
    reg         reset   = 1;
    reg  [15:0] ir_reg  = 16'h0000;
    reg         ac_sign = 0;
    reg         ac_zero = 0;
    reg         e_flag  = 0;

    // F1 çıkışları
    wire f1_add, f1_clrac, f1_incac, f1_drtac;
    wire f1_andac, f1_comac, f1_clre;

    // F2 çıkışları
    wire f2_sub, f2_or, f2_shl, f2_shr;
    wire f2_incpc, f2_artpc, f2_come;

    // F3 çıkışları
    wire f3_read, f3_write, f3_pctar, f3_irtar;
    wire f3_actdr, f3_incdr, f3_drtir;

    // Debug
    wire [6:0]  debug_car;
    wire [19:0] debug_mi;

    localparam CLK_PERIOD = 20; // ns

    // Saat üreteci
    always #(CLK_PERIOD/2) clk = ~clk;

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

    // Test süreci
    initial begin
        $display("=== TEST BASLIYOR ===");

        // ── RESET ──
        reset = 1;
        repeat(2) @(posedge clk);
        #1; // Delay to avoid checking exactly at edge
        reset = 0;

        // ── FETCH DÖNGÜSÜ TESTİ ──
        $display("--- FETCH Döngüsü ---");

        // CAR=0x40
        #5; 
        $display("CAR = %0d | f3_pctar = %b", debug_car, f3_pctar);
        if (debug_car !== 7'b1000000) $error("HATA: CAR 0x40 olmali!");
        if (f3_pctar !== 1'b1) $error("HATA: FETCH-0 adiminda f3_pctar aktif olmali!");
        
        @(posedge clk); #5; // CAR=0x41
        $display("CAR = %0d | f3_read = %b | f2_incpc = %b", debug_car, f3_read, f2_incpc);
        if (f3_read !== 1'b1) $error("HATA: FETCH-1 adiminda f3_read aktif olmali!");
        if (f2_incpc !== 1'b1) $error("HATA: FETCH-1 adiminda f2_incpc aktif olmali!");
        
        @(posedge clk); #5; // CAR=0x42
        $display("CAR = %0d | f3_drtir = %b", debug_car, f3_drtir);
        if (f3_drtir !== 1'b1) $error("HATA: FETCH-2 adiminda f3_drtir aktif olmali!");
        
        @(posedge clk); #5; // CAR=0x43
        $display("CAR = %0d (MAP adimi)", debug_car);

        // ── AND KOMUTU TESTİ (opcode=000) ──
        $display("--- AND Komutu (opcode=000, I=0) ---");
        ir_reg = 16'b0000000000100000; // AND, direct, addr=0x020
        
        @(posedge clk); #5; // CAR=0x00
        $display("AND-0: CAR = %0d", debug_car);
        
        @(posedge clk); #5; // CAR=0x01
        $display("AND-1: CAR = %0d | f3_read = %b", debug_car, f3_read);
        if (f3_read !== 1'b1) $error("HATA: AND-1 adiminda f3_read aktif olmali!");
        
        @(posedge clk); #5; // CAR=0x02
        $display("AND-2: CAR = %0d | f1_andac = %b", debug_car, f1_andac);
        if (f1_andac !== 1'b1) $error("HATA: AND execute adiminda f1_andac aktif olmali!");

        @(posedge clk); #5; // CAR=0x40 (Fetch'e dönmeli)
        $display("Fetch'e donus: CAR = %0d", debug_car);
        if (debug_car !== 7'b1000000) $error("HATA: AND sonrasi FETCH'e (0x40) donmeli!");

        // ── ADD KOMUTU TESTİ (opcode=001) ──
        $display("--- ADD Komutu (opcode=001, I=0) ---");
        // FETCH 0, 1, 2
        @(posedge clk); #5; // 0x41
        @(posedge clk); #5; // 0x42
        @(posedge clk); #5; // 0x43
        ir_reg = 16'b0001000000010000; // ADD, direct, addr=0x010
        
        @(posedge clk); #5; // MAP → CAR=0x08
        $display("ADD-0: CAR = %0d", debug_car);

        @(posedge clk); #5; // CAR=0x09
        $display("ADD-1: CAR = %0d | f3_read = %b", debug_car, f3_read);
        if (f3_read !== 1'b1) $error("HATA: ADD-1 adiminda f3_read aktif olmali!");

        @(posedge clk); #5; // CAR=0x0A
        $display("ADD-2: CAR = %0d | f1_add = %b", debug_car, f1_add);
        if (f1_add !== 1'b1) $error("HATA: ADD execute adiminda f1_add aktif olmali!");

        @(posedge clk); #5; // CAR=0x40
        if (debug_car !== 7'b1000000) $error("HATA: ADD sonrasi FETCH'e donmeli!");

        // ── LDA KOMUTU TESTİ (opcode=010) ──
        $display("--- LDA Komutu (opcode=010, I=0) ---");
        @(posedge clk); #5; // 0x41
        @(posedge clk); #5; // 0x42
        @(posedge clk); #5; // 0x43
        ir_reg = 16'b0010000000110000; // LDA, direct
        
        @(posedge clk); #5; // MAP → CAR=0x10
        $display("LDA-0: CAR = %0d", debug_car);
        
        @(posedge clk); #5; // CAR=0x11
        $display("LDA-1: CAR = %0d | f3_read = %b", debug_car, f3_read);
        if (f3_read !== 1'b1) $error("HATA: LDA-1 adiminda f3_read aktif olmali!");
        
        @(posedge clk); #5; // CAR=0x12
        $display("LDA-2: CAR = %0d | f1_drtac = %b", debug_car, f1_drtac);
        if (f1_drtac !== 1'b1) $error("HATA: LDA execute adiminda f1_drtac aktif olmali!");

        @(posedge clk); #5; // CAR=0x40
        if (debug_car !== 7'b1000000) $error("HATA: LDA sonrasi FETCH'e donmeli!");

        // ── TEST TAMAMLANDI ──
        $display("=== TUM TESTLER TAMAMLANDI ===");
        repeat(5) @(posedge clk);
        $finish;
    end

endmodule
