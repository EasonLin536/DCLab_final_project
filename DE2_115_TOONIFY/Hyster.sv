`define DSIZE 4

module Hyster (
	input                 i_clk,
	input                 i_rst_n,
	input  [3:0]          i_seg_width,
	input  [`DSIZE*9-1:0] i_pixel,
	output				  o_pixel
);

logic [`DSIZE-1:0] pixel_arr [0:8];
logic [`DSIZE-1:0] center_pixel;
logic 			   o_pixel_w, o_pixel_r;
logic [`DSIZE-1:0] w1, w2, w3, w4, w5, w6, w7;
logic [3:0]	       strong_;

assign center_pixel = pixel_arr[4];
assign o_pixel = o_pixel_r;

assign strong_ = i_seg_width;
// w7 = max(pixel[0] ~ pixel[8])
assign w1 = (pixel_arr[0] > pixel_arr[1]) ? pixel_arr[0] : pixel_arr[1];
assign w2 = (pixel_arr[2] > pixel_arr[3]) ? pixel_arr[2] : pixel_arr[3];
assign w3 = (pixel_arr[5] > pixel_arr[6]) ? pixel_arr[5] : pixel_arr[6];
assign w4 = (pixel_arr[7] > pixel_arr[8]) ? pixel_arr[7] : pixel_arr[8];
assign w5 = (w1 > w2) ? w1 : w2;
assign w6 = (w3 > w4) ? w3 : w4;
assign w7 = (w5 > w6) ? w5 : w6;

// pixel array
integer i;
always_comb begin
    for (i=0;i<9;i=i+1) begin
        pixel_arr[i] = i_pixel[`DSIZE*9-1-i*`DSIZE -: `DSIZE];
    end
end
// 1:not edge, 0:edge
always_comb begin
	if (center_pixel < 2) begin
		o_pixel_w = (w7 < 3) ? 1 : 0;
	end
	else begin
		o_pixel_w = 0;
	end
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
	if(!i_rst_n) begin
		o_pixel_r <= 0;
	end
	else begin
		o_pixel_r <= o_pixel_w;
	end
end

endmodule