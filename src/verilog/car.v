// Control Address Register (CAR) ??? 7-bit
// reset ??? 0x40 (FETCH ba??lang??c??)
// load  ??? CAR ??? load_data
// inc   ??? CAR ??? CAR + 1
module car (
    input  wire       clk,
    input  wire       reset,
    input  wire       load,
    input  wire       inc,
    input  wire [6:0] load_data,
    output reg  [6:0] car_out
);
    localparam FETCH_ADDR = 7'b1000000; // 0x40

    always @(posedge clk or posedge reset) begin
        if (reset)
            car_out <= FETCH_ADDR;
        else if (load)
            car_out <= load_data;
        else if (inc)
            car_out <= car_out + 1;
    end
endmodule
