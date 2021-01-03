// register indexing
// 24: newest pixel, 0: oldest pixel
// ---------
// | 0 3 6 |
// | 1 4 7 |
// | 2 5 8 |
// ---------
`define DSIZE 8

module Gau_Fil (
    input                 i_clk,
    input                 i_rst_n,
    input  [`DSIZE*9-1:0] i_pixel, // input pixel
    output [`DSIZE-1:0]   o_pixel  // output pixel
);

logic [`DSIZE-1:0] pixel_arr [0:8];

// submodules
logic [`DSIZE+6:0] sum [0:2];
logic [`DSIZE-1:0] o_pixel_r, o_pixel_w;

assign o_pixel = o_pixel_r;

// convolution
filter_col_0 fil_r0 ( pixel_arr[0],  pixel_arr[1],  pixel_arr[2],  sum[0] );
filter_col_1 fil_r1 ( pixel_arr[3],  pixel_arr[4],  pixel_arr[5],  sum[1] );
filter_col_0 fil_r4 ( pixel_arr[6],  pixel_arr[7],  pixel_arr[8],  sum[2] );
sum_n_divide snd_r  ( sum[0], sum[1], sum[2], o_pixel_w );

// pixel array
integer i;
always_comb begin
	for (i=0;i<9;i=i+1) begin
		pixel_arr[i] = i_pixel[`DSIZE*9-1-i*`DSIZE -: `DSIZE];
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
    input  [`DSIZE-1:0] pixel_0,
	input  [`DSIZE-1:0] pixel_1,
	input  [`DSIZE-1:0] pixel_2,
	output [`DSIZE+6:0] sum
);
	
logic [`DSIZE+3:0] extend_1;
logic [`DSIZE+3:0] extend_2;
logic [`DSIZE+3:0] extend_3;
logic [`DSIZE+5:0] w0;

assign extend_1 = { 4'b0, pixel_0 };
assign extend_2 = { 4'b0, pixel_1 };
assign extend_3 = { 4'b0, pixel_2 };

assign w0  = (extend_1 + extend_3) >> 1;
assign sum = (extend_2 + w0) >> 1;

endmodule

module filter_col_1 (
    input  [`DSIZE-1:0] pixel_0,
	input  [`DSIZE-1:0] pixel_1,
	input  [`DSIZE-1:0] pixel_2,
	output [`DSIZE+6:0] sum
);

logic [`DSIZE+3:0] extend_1;
logic [`DSIZE+3:0] extend_2;
logic [`DSIZE+3:0] extend_3;
// logic [`DSIZE+5:0] w0, w1, w2, w3, w4, w5;
logic [`DSIZE+5:0] w0, w1, w2;

assign extend_1 = { 4'b0, pixel_0 };
assign extend_2 = { 4'b0, pixel_1 };
assign extend_3 = { 4'b0, pixel_2 };

assign w0  = (extend_1 + extend_3) >> 1;
assign sum = (extend_2 + w0);


endmodule

module sum_n_divide (
    input  [`DSIZE+6:0] in1,
    input  [`DSIZE+6:0] in2,
    input  [`DSIZE+6:0] in3,
	output [`DSIZE-1:0] out
);

logic [`DSIZE+9:0] w0, w1, w2, w3, w4, w5, w6;

assign w0 = in1 + in2;
assign w1 = (w0  + in3) >> 2;
assign out = { w1[7:0] };

endmodule
// // register indexing
// // 24: newest pixel, 0: oldest pixel
// // ----------------
// // | 0 5 10 15 20 |
// // | 1 6 11 16 21 |
// // | 2 7 12 17 22 |
// // | 3 8 13 18 23 |
// // | 4 9 14 19 24 |
// // ----------------
// `define DSIZE 8

// module GAU_FIL (
//     input                  i_clk,
//     input                  i_rst_n,
//     input  [`DSIZE*25-1:0] i_pixel, // input pixel
//     output    [`DSIZE-1:0] o_pixel  // output pixel
// );

// logic [`DSIZE-1:0] pixel_arr [0:24];

// // submodules
// logic [`DSIZE+6:0] sum [0:4];
// logic [`DSIZE-1:0] gau;
// logic [`DSIZE-1:0] o_pixel_r, o_pixel_w;

// assign o_pixel = o_pixel_r;

// // convolution
// filter_col_0 fil_r0 ( pixel_arr[0],  pixel_arr[1],  pixel_arr[2],  pixel_arr[3],  pixel_arr[4],  sum[0] );
// filter_col_1 fil_r1 ( pixel_arr[5],  pixel_arr[6],  pixel_arr[7],  pixel_arr[8],  pixel_arr[9],  sum[1] );
// filter_col_2 fil_r2 ( pixel_arr[10], pixel_arr[11], pixel_arr[12], pixel_arr[13], pixel_arr[14], sum[2] );
// filter_col_1 fil_r3 ( pixel_arr[15], pixel_arr[16], pixel_arr[17], pixel_arr[18], pixel_arr[19], sum[3] );
// filter_col_0 fil_r4 ( pixel_arr[20], pixel_arr[21], pixel_arr[22], pixel_arr[23], pixel_arr[24], sum[4] );
// sum_n_divide snd_r  ( sum[0], sum[1], sum[2], sum[3], sum[4], o_pixel_w );

// // pixel array
// integer i;
// always_comb begin
// 	for (i=0;i<25;i=i+1) begin
// 		pixel_arr[i] = i_pixel[`DSIZE*25-1-i*`DSIZE -: `DSIZE];
// 	end
// end

// always_ff @(posedge i_clk or negedge i_rst_n) begin
// 	if (!i_rst_n) begin
//         o_pixel_r <= 0;
//     end
//     else begin
//         o_pixel_r <= o_pixel_w;
//     end
// end

// endmodule

// module filter_col_0 (
//     input  [`DSIZE-1:0] pixel_0,
// 	input  [`DSIZE-1:0] pixel_1,
// 	input  [`DSIZE-1:0] pixel_2,
// 	input  [`DSIZE-1:0] pixel_3,
// 	input  [`DSIZE-1:0] pixel_4,
// 	output [`DSIZE+6:0] sum
// );
	
// logic [`DSIZE+3:0] extend_1;
// logic [`DSIZE+3:0] extend_2;
// logic [`DSIZE+3:0] extend_3;
// logic [`DSIZE+3:0] extend_4;
// logic [`DSIZE+3:0] extend_5;
// // logic [`DSIZE+5:0] w0, w1, w2, w3;
// logic [`DSIZE+5:0] w0, w1;

// assign extend_1 = { 4'b0, pixel_0 };
// assign extend_2 = { 4'b0, pixel_1 };
// assign extend_3 = { 4'b0, pixel_2 };
// assign extend_4 = { 4'b0, pixel_3 };
// assign extend_5 = { 4'b0, pixel_4 };

// // assign w0  = (extend_1 << 1) + (extend_2 << 2);
// // assign w1  = (extend_4 << 2) + (extend_5 << 1);
// // assign w2  = (extend_3 << 2) + extend_3;
// // assign w3  = w0 + w1;
// // assign sum = w2 + w3;

// assign w0  = (extend_1 + extend_5) << 1;
// assign w1  = (extend_2 + extend_3 + extend_4) << 2;
// assign sum = w0 + w1 + extend_3;

// endmodule

// module filter_col_1 (
//     input  [`DSIZE-1:0] pixel_0,
// 	input  [`DSIZE-1:0] pixel_1,
// 	input  [`DSIZE-1:0] pixel_2,
// 	input  [`DSIZE-1:0] pixel_3,
// 	input  [`DSIZE-1:0] pixel_4,
// 	output [`DSIZE+6:0] sum
// );

// logic [`DSIZE+3:0] extend_1;
// logic [`DSIZE+3:0] extend_2;
// logic [`DSIZE+3:0] extend_3;
// logic [`DSIZE+3:0] extend_4;
// logic [`DSIZE+3:0] extend_5;
// // logic [`DSIZE+5:0] w0, w1, w2, w3, w4, w5;
// logic [`DSIZE+5:0] w0, w1, w2;

// assign extend_1 = { 4'b0, pixel_0 };
// assign extend_2 = { 4'b0, pixel_1 };
// assign extend_3 = { 4'b0, pixel_2 };
// assign extend_4 = { 4'b0, pixel_3 };
// assign extend_5 = { 4'b0, pixel_4 };

// // assign w0  = (extend_1 << 2) + (extend_5 << 2);
// // assign w1  = (extend_2 << 3) + extend_2;
// // assign w2  = (extend_3 << 2) + (extend_3 << 3);
// // assign w3  = (extend_4 << 3) + extend_4;
// // assign w4  = w0 + w1;
// // assign w5  = w2 + w3;
// // assign sum = w4 + w5;

// assign w0  = (extend_1 + extend_3 + extend_5) << 2;
// assign w1  = (extend_2 + extend_3 + extend_4) << 3;
// assign w2  = extend_2 + extend_4;
// assign sum = w0 + w1 + w2;


// endmodule

// module filter_col_2 (
//     input  [`DSIZE-1:0] pixel_0,
// 	input  [`DSIZE-1:0] pixel_1,
// 	input  [`DSIZE-1:0] pixel_2,
// 	input  [`DSIZE-1:0] pixel_3,
// 	input  [`DSIZE-1:0] pixel_4,
// 	output [`DSIZE+6:0] sum
// );

// logic [`DSIZE+3:0] extend_1;
// logic [`DSIZE+3:0] extend_2;
// logic [`DSIZE+3:0] extend_3;
// logic [`DSIZE+3:0] extend_4;
// logic [`DSIZE+3:0] extend_5;
// // logic [`DSIZE+5:0] w0, w1, w2, w3, w4, w5, w6, w7;
// logic [`DSIZE+5:0] w0, w1, w2;

// assign extend_1 = { 4'b0, pixel_0 };
// assign extend_2 = { 4'b0, pixel_1 };
// assign extend_3 = { 4'b0, pixel_2 };
// assign extend_4 = { 4'b0, pixel_3 };
// assign extend_5 = { 4'b0, pixel_4 };

// // assign w0 = (extend_1 << 2) + extend_1;
// // assign w1 = (extend_2 << 2) + (extend_2 << 3);
// // assign w2 = (extend_3 << 4) - extend_3;
// // assign w3 = (extend_4 << 2) + (extend_4 << 3);
// // assign w4 = (extend_5 << 2) + extend_5;

// // assign w5 = w0 + w1;
// // assign w6 = w2 + w3;
// // assign w7 = w4 + w5;
// // assign sum = w6 + w7;

// assign w0 = (extend_1 + extend_2 + extend_4 + extend_5) << 2;
// assign w1 = (extend_2 + extend_4) << 3;
// assign w2 = (extend_3 << 4);
// assign sum = w0 + w1 + w2 + extend_1 - extend_3 + extend_5;

// endmodule

// module sum_n_divide (
//     input  [`DSIZE+6:0] in1,
//     input  [`DSIZE+6:0] in2,
//     input  [`DSIZE+6:0] in3,
//     input  [`DSIZE+6:0] in4,
//     input  [`DSIZE+6:0] in5,
// 	output [`DSIZE-1:0] out
// );

// logic [`DSIZE+9:0] w0, w1, w2, w3, w4, w5, w6;

// assign w0 = in1 + in2;
// assign w1 = in3 + in4;
// assign w2 = w0  + in5;
// assign w3 = w1  + w2;

// assign w4 = (w3 >> 7)  - (w3 >> 9);
// assign w5 = (w3 >> 11) - (w3 >> 14);
// assign w6 = w4 + w5;

// assign out = { w6[7:0] };

// endmodule