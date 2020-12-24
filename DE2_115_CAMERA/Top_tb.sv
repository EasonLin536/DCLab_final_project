`timescale 1ns/10ps
`define CYCLE 1.0
`define END_CYCLE 100

module tb();
    logic clk, rst_n;
    logic [15:0] Read_DATA1, Read_DATA2;
    logic [12:0] H_Cont, V_Cont;
    wire  [15:0] s_dq;
    logic        s_wen;
    logic [19:0] s_addr;
    logic [9:0]  process_Red;
    logic [9:0]  process_Green;
    logic [9:0]  process_Blue;
    logic        top_ccd_pause;
    always #(`CYCLE * 0.5) clk = ~clk;

    initial begin
        clk=1;
        rst_n=1;
        H_Cont = 0;
        V_Cont = 0;
        #(`CYCLE*0.2) rst_n = 1'b0;
        #(`CYCLE*1.5) rst_n = 1'b1;

    end
    TOP 				Top (	// SDRAM Side
    							// .i_clk(sdram_ctrl_clk),
    							.i_clk(clk),
    							.i_rst_n(rst_n),
    							.i_sdram_data_1(Read_DATA1),
    							.i_sdram_data_2(Read_DATA2),
    							.i_H_Cont(H_Cont),
    							.i_V_Cont(V_Cont),
    							.io_s_dq(),
    							.o_s_wen(s_wen),
    							.o_s_addr(s_addr),
    							.o_display_Red(process_Red),
    							.o_display_Green(process_Green),
    							.o_display_Blue(process_Blue),
    							.o_CCD_pause(top_ccd_pause)
    						);
    initial begin
        $fsdbDumpfile("makeStroke.fsdb");
        $fsdbDumpvars;
    end
    `define TIME_OUT 100
    initial #(`TIME_OUT) $finish;

endmodule