module nexys3
(
    input        clk,
    input  [7:0] sw,

    input        btns,
    input        btnu,
    input        btnd,
    input        btnl,
    input        btnr,

    output [7:0] Led,
    output [7:0] seg,
    output [3:0] an,

    inout  [5:0] JB 
);

    wire clk_out; 
  
    // TODO
    // clk_wiz_0 clk_wiz_0 (.clk_in1 (clk), .clk_out1 (clk_out));

    assign clk_out = clk;

    wire tck_in, tck;

    IBUF IBUF1 (.O ( tck_in ), .I ( JB [3] ));
    BUFG BUFG1 (.O ( tck    ), .I ( tck_in ));

    wire [17:0] IO_Switch = { 10'b0, sw };
    wire [ 4:0] IO_PB     = { btnu, btnd, btnl, 1'b0, btnr };
    wire [17:0] IO_LEDR;
    wire [ 8:0] IO_LEDG;

    assign Led = IO_LEDG [7:0];
    assign seg = sw;
    assign an  = { btnu, btnl, btnd, btnr };

    wire [31:0] HADDR, HRDATA, HWDATA;
    wire        HWRITE;

    mipsfpga_sys mipsfpga_sys
    (
        .SI_ClkIn         ( clk             ),
        .SI_Reset_N       ( ~ btns          ),
                          
        .HADDR            ( HADDR           ),
        .HRDATA           ( HRDATA          ),
        .HWDATA           ( HWDATA          ),
        .HWRITE           ( HWRITE          ),
                          
        .IO_PB            ( IO_PB           ),
        .IO_Switch        ( IO_Switch       ),
                          
        .IO_LEDR          ( IO_LEDR         ),
        .IO_LEDG          ( IO_LEDG         ),
                          
        .EJ_TRST_N_probe  ( JB [4]          ),
        .EJ_TDI           ( JB [1]          ),
        .EJ_TDO           ( JB [2]          ),
        .EJ_TMS           ( JB [0]          ),
        .EJ_TCK           ( tck             ),
        .SI_ColdReset_N   ( JB [5]          ),
        .EJ_DINT          ( 1'b0            )
    );

endmodule
