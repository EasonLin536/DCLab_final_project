module OilPainting(
    input           i_clk,
    input           i_vga_clk,
    input           i_rst_n,
    input   [8:0]   i_SW,
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
logic   [15:0]  reduce_color_w, reduce_color_r;
// logic   [23:0]  gray_color;
logic   [9:0]  gray_color;
logic   [3:0]  processed_edge;
// logic           processed_edge;
logic   [15:0]  processed_color;
logic   [7:0]   OriginRed, OriginGreen, OriginBlue;
logic   [4:0]   sw;
logic   [3:0]   seg_width;
// logic   [23:0]  OriginPicture;
assign sw = i_SW[4:0];
assign seg_width = i_SW[8:5];
assign OriginRed     = i_sdram_data_2[9:2];
assign OriginGreen   = { i_sdram_data_1[14:10], i_sdram_data_2[14:12] };
assign OriginBlue    = i_sdram_data_1[9:2];


// assign OriginPicture = { OriginRed, OriginGreen, OriginBlue };
// assign reduce_color_w = {1'b0, i_sdram_data_2[9:4], 1'b0, i_sdram_data_1[14:11], 1'b0, i_sdram_data_1[9:4], 1'b0 };
assign reduce_color_w = {1'b0, i_sdram_data_2[9:5], i_sdram_data_1[14:10], i_sdram_data_1[9:5] };
assign gray_color = (OriginRed + OriginGreen + OriginGreen + OriginBlue) >> 2;
// assign gray_color = (OriginRed + OriginGreen + OriginBlue) >> 2;
// assign o_display_Red   = { processed_edge[14:10], 5'd0 };
// assign o_display_Green = { processed_edge[9:5],   5'd0 };
// assign o_display_Blue  = { processed_edge[4:0],   5'd0 };
// assign o_display_Red   = { OriginRed[7:3],   5'd0 };
// assign o_display_Green = { OriginGreen[7:3], 5'd0 };
// assign o_display_Blue  = { OriginBlue[7:3],  5'd0 };
assign o_display_Red   = (processed_edge[0] && !sw)? { processed_color[14:12], 7'b0000100 }:{ processed_edge, 6'b000100 };
assign o_display_Green = (processed_edge[0] && !sw)? { processed_color[9:7], 7'b0000100 }:{ processed_edge, 6'b000100 };
assign o_display_Blue  = (processed_edge[0] && !sw)? { processed_color[4:2], 7'b0000100 }:{ processed_edge, 6'b000100 };
// assign o_display_Red   = { processed_color[14:10], 5'b00100 };
// assign o_display_Green = { processed_color[9:5],   5'b00100 };
// assign o_display_Blue  = { processed_color[4:0],   5'b00100 };
// assign o_display_Red   = { processed_edge, 6'b000100 };
// assign o_display_Green = { processed_edge, 6'b000100 };
// assign o_display_Blue  = { processed_edge, 6'b000100 };

ColorDelay color_delay(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_data(reduce_color_r),
    .i_s_data(i_s_data),
    .o_data(processed_color),
    .o_s_data(o_s_data),
    .o_s_wen(o_s_wen),
    .o_s_addr(o_s_addr)
);

ImgProcess img_process(
    .i_clk(~i_vga_clk),
    .i_rst_n(i_rst_n),
    .i_seg_width(seg_width),
    .i_SW(sw),
    .i_is_new_read(i_is_new_read),
    .i_data(gray_color[7:4]),
    .o_data(processed_edge)
);

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        reduce_color_r <= 0;
    end
    else begin
        reduce_color_r <= reduce_color_w;
    end
end
endmodule