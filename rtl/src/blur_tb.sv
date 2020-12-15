`timescale 1ns/10ps
`define CYCLE 1.0

module tb();

    logic       i_clk, i_rst_n, i_row_end, i_valid, o_valid;
    logic [7:0] i_pixel, o_pixel;
    logic [7:0] i, j;


    initial begin
        i_clk = 1;
        i_rst_n = 1;
        #(`CYCLE*0.2) i_rst_n = 1'b0;
        #(`CYCLE*1.5) i_rst_n = 1'b1;
        i = 0;
        j = 0;
        #(`CYCLE) i_valid = 1;
        
    end

    always #(`CYCLE * 0.5) i_clk = ~i_clk;

    blur blur0(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_row_end(i_row_end),
        .i_valid(i_valid),
        .i_pixel(i_pixel),
        .o_valid(o_valid),
        .o_pixel(o_pixel)
    );

    always @(negedge i_clk) begin
        // if (j <= 2) begin
            i_pixel = i;
            i = i + 1;
            // j = j + 1;
            // if (j == 2) begin
                // j = 0;
                // i = i + 1;
            // end
        // end
    end

    initial begin
        $fsdbDumpfile("blur.fsdb");
        $fsdbDumpvars(0, "+mda");
    end

    `define TIME_OUT 200
    initial #(`TIME_OUT) $finish;

endmodule