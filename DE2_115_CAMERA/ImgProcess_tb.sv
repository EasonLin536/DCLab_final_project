`timescale 1ns/10ps
`define CYCLE 1.0

module tb();

    logic         i_clk;
    logic         i_rst_n;
    logic         i_is_new_read;
    logic [14:0]  i_data;
    logic [14:0]  o_data;

    logic [4:0] red;
    logic [4:0] green;
    logic [4:0] blue;

    logic [10:0] H_cnt, V_cnt;

    parameter H_LIMIT = 800;
    parameter V_LIMIT = 525;

    assign i_data = { red, green, blue };

    integer i;
    initial begin
        i_clk = 1;
        i_rst_n = 1;
        #(`CYCLE*0.2) i_rst_n = 1'b0;
        #(`CYCLE*1.5) i_rst_n = 1'b1;
        i_is_new_read = 1;
        red = 0;
        green = 0;
        blue = 0; 
    end

    always #(`CYCLE * 0.5) i_clk = ~i_clk;

    ImgProcess imgprocess(
        .i_clk(i_clk),
        .i_rst_n (i_rst_n),
        .i_is_new_read(i_is_new_read),
        .i_data(i_data),
        .o_data(o_data)
    );

    always @(negedge i_clk) begin
        red = red + 1;
        green = green + 1;
        blue = blue + 1;

        if (H_cnt == H_LIMIT - 1) begin
            H_cnt = 0;
            if (V_cnt == V_LIMIT - 1) begin
                V_cnt = 0;
            end
            else begin
                V_cnt = V_cnt + 1;
            end    
        end
        else begin
            H_cnt = H_cnt + 1;
        end
    end

    initial begin
        $fsdbDumpfile("ImgProcess.fsdb");
        $fsdbDumpvars(0, "+mda");
    end

    `define TIME_OUT 100000
    initial #(`TIME_OUT) $finish;

endmodule