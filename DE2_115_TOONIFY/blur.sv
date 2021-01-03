// register indexing
// 24: newest pixel, 0: oldest pixel
// ----------------
// | 0 5 10 15 20 |
// | 1 6 11 16 21 |
// | 2 7 12 17 22 |
// | 3 8 13 18 23 |
// | 4 9 14 19 24 |
// ----------------
`define DSIZE 5

module BLUR (
    input                    i_clk,
    input                    i_rst_n,
    input  [`DSIZE*3*25-1:0] i_pixel, // input pixel
    output    [`DSIZE*3-1:0] o_pixel  // output pixel R, G, or B
);

logic [`DSIZE*3-1:0] pixel_arr [0:24];

// submodules
logic   [`DSIZE-1:0] red   [0:24];
logic   [`DSIZE-1:0] green [0:24];
logic   [`DSIZE-1:0] blue  [0:24];
logic   [`DSIZE+6:0] sum_r [0:4];
logic   [`DSIZE+6:0] sum_g [0:4];
logic   [`DSIZE+6:0] sum_b [0:4];
logic   [`DSIZE-1:0] gau_r, gau_g, gau_b;
logic [`DSIZE*3-1:0] o_pixel_r, o_pixel_w;

assign o_pixel = o_pixel_r;
assign o_pixel_w = { gau_r, gau_g, gau_b };

// red channel
filter_col_0 fil_r0 ( red[0],  red[1],  red[2],  red[3],  red[4],  sum_r[0] );
filter_col_1 fil_r1 ( red[5],  red[6],  red[7],  red[8],  red[9],  sum_r[1] );
filter_col_2 fil_r2 ( red[10], red[11], red[12], red[13], red[14], sum_r[2] );
filter_col_1 fil_r3 ( red[15], red[16], red[17], red[18], red[19], sum_r[3] );
filter_col_0 fil_r4 ( red[20], red[21], red[22], red[23], red[24], sum_r[4] );
sum_n_divide snd_r  ( sum_r[0], sum_r[1], sum_r[2], sum_r[3], sum_r[4], gau_r );
// green channel
filter_col_0 fil_g0 ( green[0],  green[1],  green[2],  green[3],  green[4],  sum_g[0] );
filter_col_1 fil_g1 ( green[5],  green[6],  green[7],  green[8],  green[9],  sum_g[1] );
filter_col_2 fil_g2 ( green[10], green[11], green[12], green[13], green[14], sum_g[2] );
filter_col_1 fil_g3 ( green[15], green[16], green[17], green[18], green[19], sum_g[3] );
filter_col_0 fil_g4 ( green[20], green[21], green[22], green[23], green[24], sum_g[4] );
sum_n_divide snd_g  ( sum_g[0], sum_g[1], sum_g[2], sum_g[3], sum_g[4], gau_g );
// red channel
filter_col_0 fil_b0 ( blue[0],  blue[1],  blue[2],  blue[3],  blue[4],  sum_b[0] );
filter_col_1 fil_b1 ( blue[5],  blue[6],  blue[7],  blue[8],  blue[9],  sum_b[1] );
filter_col_2 fil_b2 ( blue[10], blue[11], blue[12], blue[13], blue[14], sum_b[2] );
filter_col_1 fil_b3 ( blue[15], blue[16], blue[17], blue[18], blue[19], sum_b[3] );
filter_col_0 fil_b4 ( blue[20], blue[21], blue[22], blue[23], blue[24], sum_b[4] );
sum_n_divide snd_b  ( sum_b[0], sum_b[1], sum_b[2], sum_b[3], sum_b[4], gau_b );

// pixel array
integer i;
always_comb begin
	for (i=0;i<25;i=i+1) begin
		pixel_arr[i] = i_pixel[`DSIZE*3*25-1-i*`DSIZE*3 -: `DSIZE*3];
	end
end

// 3 channels
integer k;
always_comb begin
	for (k=0;k<25;k=k+1) begin
		red[k] = pixel_arr[k][`DSIZE*3-1 -: `DSIZE];
		green[k] = pixel_arr[k][`DSIZE*2-1 -: `DSIZE];
		blue[k] = pixel_arr[k][`DSIZE-1 -: `DSIZE];
	end
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
        o_pixel_r <= 0;
    end
    else begin
        o_pixel_r <= o_pixel_w;
    end
end

endmodule

module filter_col_0 (
    input   [`DSIZE-1:0] pixel_0,
	input   [`DSIZE-1:0] pixel_1,
	input   [`DSIZE-1:0] pixel_2,
	input   [`DSIZE-1:0] pixel_3,
	input   [`DSIZE-1:0] pixel_4,
	output [`DSIZE+6:0] sum
);
	
	logic [`DSIZE+3:0] extend_1;
	logic [`DSIZE+3:0] extend_2;
	logic [`DSIZE+3:0] extend_3;
	logic [`DSIZE+3:0] extend_4;
	logic [`DSIZE+3:0] extend_5;
	logic [`DSIZE+3:0] w0, w1, w2, w3;

	assign extend_1 = { 4'b0, pixel_0 };
	assign extend_2 = { 4'b0, pixel_1 };
	assign extend_3 = { 4'b0, pixel_2 };
	assign extend_4 = { 4'b0, pixel_3 };
	assign extend_5 = { 4'b0, pixel_4 };

	assign w0  = (extend_1 << 1) + (extend_2 << 2);
	assign w1  = (extend_4 << 2) + (extend_5 << 1);
	assign w2  = (extend_3 << 2) + extend_3;
	assign w3  = w0 + w1;
	assign sum = w2 + w3;

endmodule

module filter_col_1 (
    input   [`DSIZE-1:0] pixel_0,
	input   [`DSIZE-1:0] pixel_1,
	input   [`DSIZE-1:0] pixel_2,
	input   [`DSIZE-1:0] pixel_3,
	input   [`DSIZE-1:0] pixel_4,
	output [`DSIZE+6:0] sum
);

	logic [`DSIZE+3:0] extend_1;
	logic [`DSIZE+3:0] extend_2;
	logic [`DSIZE+3:0] extend_3;
	logic [`DSIZE+3:0] extend_4;
	logic [`DSIZE+3:0] extend_5;
	logic [`DSIZE+3:0] w0, w1, w2, w3, w4, w5;

	assign extend_1 = { 4'b0, pixel_0 };
	assign extend_2 = { 4'b0, pixel_1 };
	assign extend_3 = { 4'b0, pixel_2 };
	assign extend_4 = { 4'b0, pixel_3 };
	assign extend_5 = { 4'b0, pixel_4 };

	assign w0  = (extend_1 << 2) + (extend_5 << 2);
	assign w1  = (extend_2 << 3) + extend_2;
	assign w2  = (extend_3 << 2) + (extend_3 << 3);
	assign w3  = (extend_4 << 3) + extend_4;
	assign w4  = w0 + w1;
	assign w5  = w2 + w3;
	assign sum = w4 + w5;

endmodule

module filter_col_2 (
    input   [`DSIZE-1:0] pixel_0,
	input   [`DSIZE-1:0] pixel_1,
	input   [`DSIZE-1:0] pixel_2,
	input   [`DSIZE-1:0] pixel_3,
	input   [`DSIZE-1:0] pixel_4,
	output [`DSIZE+6:0] sum
);

	logic [`DSIZE+3:0] extend_1;
	logic [`DSIZE+3:0] extend_2;
	logic [`DSIZE+3:0] extend_3;
	logic [`DSIZE+3:0] extend_4;
	logic [`DSIZE+3:0] extend_5;
	logic [`DSIZE+3:0] w0, w1, w2, w3, w4, w5, w6, w7;

	assign extend_1 = { 4'b0, pixel_0 };
	assign extend_2 = { 4'b0, pixel_1 };
	assign extend_3 = { 4'b0, pixel_2 };
	assign extend_4 = { 4'b0, pixel_3 };
	assign extend_5 = { 4'b0, pixel_4 };

	assign w0 = (extend_1 << 2) + extend_1;
	assign w1 = (extend_2 << 2) + (extend_2 << 3);
	assign w2 = (extend_3 << 4) - extend_3;
	assign w3 = (extend_4 << 2) + (extend_4 << 3);
	assign w4 = (extend_5 << 2) + extend_5;

	assign w5 = w0 + w1;
	assign w6 = w2 + w3;
	assign w7 = w4 + w5;
	assign sum = w6 + w7;

endmodule

module sum_n_divide (
    input [`DSIZE+6:0] in1,
    input [`DSIZE+6:0] in2,
    input [`DSIZE+6:0] in3,
    input [`DSIZE+6:0] in4,
    input [`DSIZE+6:0] in5,
	output [`DSIZE-1:0] out
);

	logic [`DSIZE+9:0] w0, w1, w2, w3, w4, w5, w6;

	assign w0 = in1 + in2;
	assign w1 = in3 + in4;
	assign w2 = w0  + in5;
	assign w3 = w1  + w2;

	assign w4 = (w3 >> 7)  - (w3 >> 9);
	assign w5 = (w3 >> 11) - (w3 >> 14);
	assign w6 = w4 + w5;

	assign out = { w6[7:0] };

endmodule