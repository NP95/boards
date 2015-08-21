module clock_divider_50_MHz_to_1_49_Hz
(
    input  clock_50_MHz,
    input  reset_n,
    output clock_1_49_Hz
);

    // 50 MHz / 2 ** 25 = 1.49 Hz

    reg [24:0] counter;

    always @ (posedge clock_50_MHz or negedge reset_n)
    begin
        if (! reset_n)
            counter <= 0;
        else
            counter <= counter + 1;
    end

    assign clock_1_49_Hz = counter [24];

endmodule

//--------------------------------------------------------------------

module single_digit_display
(
    input      [3:0] digit,
    output reg [6:0] seven_segments
);

    always @*
        case (digit)
        'h0: seven_segments = 'b1000000;  // a b c d e f g
        'h1: seven_segments = 'b1111001;
        'h2: seven_segments = 'b0100100;  //   --a--
        'h3: seven_segments = 'b0110000;  //  |     |
        'h4: seven_segments = 'b0011001;  //  f     b
        'h5: seven_segments = 'b0010010;  //  |     |
        'h6: seven_segments = 'b0000010;  //   --g--
        'h7: seven_segments = 'b1111000;  //  |     |
        'h8: seven_segments = 'b0000000;  //  e     c
        'h9: seven_segments = 'b0011000;  //  |     |
        'ha: seven_segments = 'b0001000;  //   --d-- 
        'hb: seven_segments = 'b0000011;
        'hc: seven_segments = 'b1000110;
        'hd: seven_segments = 'b0100001;
        'he: seven_segments = 'b0000110;
        'hf: seven_segments = 'b0001110;
        endcase

endmodule

module de0_cv_user
(
    input         CLOCK_50,
    input         RESET_N,
    input  [ 3:0] KEY,
    input  [ 9:0] SW,
    output [ 9:0] LEDR,
    output [ 6:0] HEX0,
    output [ 6:0] HEX1,
    output [ 6:0] HEX2,
    output [ 6:0] HEX3,
    output [ 6:0] HEX4,
    output [ 6:0] HEX5,
    inout  [35:0] GPIO_0,
    inout  [35:0] GPIO_1
);

    wire [17:0] IO_LEDR;
    wire [ 8:0] IO_LEDG;

    assign LEDR = { 1'b0, IO_LEDG };

    wire [31:0] HADDR, HRDATA, HWDATA;
    wire        HWRITE;
	 
    mipsfpga_sys mipsfpga_sys
    (
        .SI_Reset_N      ( RESET_N         ),
        .SI_ClkIn        ( CLOCK_50        ),
        .HADDR           ( HADDR           ),
        .HRDATA          ( HRDATA          ),
        .HWDATA          ( HWDATA          ),
        .HWRITE          ( HWRITE          ),
        .EJ_TRST_N_probe ( 0 ), // GPIO_0 [6]      ),
        .EJ_TDI          ( 0 ), // GPIO_0 [5]      ),
        .EJ_TDO          (   ), // GPIO_0 [4]      ),
        .EJ_TMS          ( 0 ), // GPIO_0 [3]      ),
        .EJ_TCK          ( 0 ), // GPIO_0 [2]      ),
        .SI_ColdReset_N  ( 1 ), // GPIO_0 [1]      ),
        .EJ_DINT         ( 0 ), // GPIO_0 [0]      ),
        .IO_Switch       ( { 8'b0,   SW  } ),
        .IO_PB           ( { 1'b0, ~ KEY } ),
        .IO_LEDR         ( IO_LEDR         ),
        .IO_LEDG         ( IO_LEDG         )
    );

    single_digit_display digit_5 (         HADDR   [31:28]   , HEX5);
    single_digit_display digit_4 ( { 2'b0, IO_LEDR [17:16] } , HEX4);
    single_digit_display digit_3 (         IO_LEDR [15:12]   , HEX3);
    single_digit_display digit_2 (         IO_LEDR [11: 8]   , HEX2);
    single_digit_display digit_1 (         IO_LEDR [ 7: 4]   , HEX1);
    single_digit_display digit_0 (         IO_LEDR [ 3: 0]   , HEX0);
    
endmodule
