module OilPainting(
    input           i_clk,
    input           i_vga_clk,
    input           i_rst_n,
    input   [15:0]  i_sdram_data_1,
    input   [15:0]  i_sdram_data_2,
    input           i_sdram_valid, // current sdram data is valid
    input   [12:0]  i_H_Cont,
    input   [12:0]  i_V_Cont,
    input           i_is_new_read,
    input   [15:0]  i_s_data,
    output  [15:0]  o_s_data,
    output          o_s_wen,
    output  [19:0]  o_s_addr,
    output  [9:0]   o_display_Red,
    output  [9:0]   o_display_Green,
    output  [9:0]   o_display_Blue,
    output          o_CCD_pause
);
logic   [14:0]  reduce_color;
logic   [14:0]  processed_color;
// logic   [23:0]  processed_color;
// logic   [9:0]   OriginRed, OriginGreen, OriginBlue;
// logic   [23:0]  OriginPicture;
// assign OriginRed     = i_sdram_data_2[9:0];
// assign OriginGreen   = { i_sdram_data_1[14:10], i_sdram_data_2[14:10] };
// assign OriginBlue    = i_sdram_data_1[9:0];
// assign OriginPicture = { OriginRed[7:0], OriginGreen[7:0], OriginBlue[7:0] };
assign reduce_color = { i_sdram_data_2[9:5], i_sdram_data_1[14:10], i_sdram_data_1[9:5] };
assign o_display_Red   = { processed_color[14:10], 5'd0 };
assign o_display_Green = { processed_color[9:5],   5'd0 };
assign o_display_Blue  = { processed_color[4:0],   5'd0 };
// assign o_display_Red   = { processed_color[23:16], 2'd0 };
// assign o_display_Green = { processed_color[15:8],  2'd0 };
// assign o_display_Blue  = { processed_color[7:0],   2'd0 };

ImgProcess img_process(
    .i_clk(~i_vga_clk),
    .i_rst_n(i_rst_n),
    .i_is_new_read(i_is_new_read),
    .i_data(reduce_color),
    .o_data(processed_color)
);

endmodule