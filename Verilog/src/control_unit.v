// Control Unit - Mikroprogramlanmış Kontrol Birimi (Üst Modül)
// CAR, SBR, Control Memory ve Microinstruction Decoder'ı birleştirir.
module control_unit (
    input  wire        clk,
    input  wire        reset,
    input  wire [15:0] ir_reg,
    input  wire        ac_sign,
    input  wire        ac_zero,
    input  wire        e_flag,

    // F1 çıkışları
    output wire f1_add, f1_clrac, f1_incac, f1_drtac,
    output wire f1_andac, f1_comac, f1_clre,
    // F2 çıkışları
    output wire f2_sub, f2_or, f2_shl, f2_shr,
    output wire f2_incpc, f2_artpc, f2_come,
    // F3 çıkışları
    output wire f3_read, f3_write, f3_pctar, f3_irtar,
    output wire f3_actdr, f3_incdr, f3_drtir,

    output wire [6:0]  debug_car,
    output wire [19:0] debug_mi
);
    // -- Dahili sinyaller --
    wire [6:0]  car_out;
    reg         car_load;
    reg         car_inc;
    reg  [6:0]  car_load_data;

    wire [6:0]  sbr_out;
    reg         sbr_load;
    reg  [6:0]  sbr_data_in;

    wire [19:0] mi;
    wire [1:0]  cd, br;
    wire [6:0]  ad;
    reg         condition;
    wire [6:0]  map_addr;

    // -- Alt modül örneklemeleri --
    car u_car (
        .clk(clk), .reset(reset),
        .load(car_load), .inc(car_inc),
        .load_data(car_load_data),
        .car_out(car_out)
    );

    sbr u_sbr (
        .clk(clk), .reset(reset),
        .load(sbr_load),
        .data_in(sbr_data_in),
        .data_out(sbr_out)
    );

    control_memory u_cmem (
        .address(car_out),
        .data(mi)
    );

    microinstruction_decoder u_dec (
        .microinstruction(mi),
        .f1_add(f1_add), .f1_clrac(f1_clrac), .f1_incac(f1_incac),
        .f1_drtac(f1_drtac), .f1_andac(f1_andac), .f1_comac(f1_comac),
        .f1_clre(f1_clre),
        .f2_sub(f2_sub), .f2_or(f2_or), .f2_shl(f2_shl), .f2_shr(f2_shr),
        .f2_incpc(f2_incpc), .f2_artpc(f2_artpc), .f2_come(f2_come),
        .f3_read(f3_read), .f3_write(f3_write), .f3_pctar(f3_pctar),
        .f3_irtar(f3_irtar), .f3_actdr(f3_actdr), .f3_incdr(f3_incdr),
        .f3_drtir(f3_drtir),
        .cd_field(cd), .br_field(br), .ad_field(ad)
    );

    // -- MAP adresi: {1'b0, IR[14:12], 3'b000} --
    assign map_addr = {1'b0, ir_reg[14:12], 3'b000};

    // -- Koşul değerlendirmesi --
    always @(*) begin
        case (cd)
            2'b00: condition = 1'b1;       // Koşulsuz
            2'b01: condition = ir_reg[15]; // i: dolaylı bit
            2'b10: condition = ac_sign;    // S: AC işaret biti
            2'b11: condition = ac_zero;    // Z: AC = 0
            default: condition = 1'b0;
        endcase
    end

    // -- CAR / SBR dallanma mantığı --
    always @(*) begin
        car_load      = 1'b0;
        car_inc       = 1'b1;
        car_load_data = 7'b0;
        sbr_load      = 1'b0;
        sbr_data_in   = 7'b0;

        case (br)
            2'b00: begin // JMP
                if (condition) begin
                    car_load      = 1'b1;
                    car_inc       = 1'b0;
                    car_load_data = ad;
                end
            end
            2'b01: begin // CALL
                if (condition) begin
                    sbr_load    = 1'b1;
                    sbr_data_in = car_out + 1;
                    car_load      = 1'b1;
                    car_inc       = 1'b0;
                    car_load_data = ad;
                end
            end
            2'b10: begin // RET
                car_load      = 1'b1;
                car_inc       = 1'b0;
                car_load_data = sbr_out;
            end
            2'b11: begin // MAP
                car_load      = 1'b1;
                car_inc       = 1'b0;
                car_load_data = map_addr;
            end
        endcase
    end

    assign debug_car = car_out;
    assign debug_mi  = mi;

endmodule
