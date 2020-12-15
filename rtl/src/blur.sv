// each cycle: read in 1 color of 1 pixel
// order: read in R, G, B
// register indexing
// 24: newest pixel, 0: oldest pixel
// ----------------
// | 0 5 10 15 20 |
// | 1 6 11 16 21 |
// | 2 7 12 17 22 |
// | 3 8 13 18 23 |
// | 4 9 14 19 24 |
// ----------------

module blur (
    input        i_clk,
    input        i_rst_n,
	input        i_row_end, // indicates row end: 1 with the last pixel input
    input        i_valid, // input pixel is valid
    input  [7:0] i_pixel, // input pixel R, G, or B
    output       o_valid, // output pixel is valid
    output [7:0] o_pixel  // output pixel R, G, or B
);

parameter KWIDTH = 5; // kernel width
parameter KHEIGHT = 5; // kernel height

parameter RED = 0;
parameter GREEN = 1;
parameter BLUE = 2;

// pixel registers
logic  [7:0] R_pixel_r [0:24];
logic  [7:0] R_pixel_w [0:24];
logic  [7:0] G_pixel_r [0:24];
logic  [7:0] G_pixel_w [0:24];
logic  [7:0] B_pixel_r [0:24];
logic  [7:0] B_pixel_w [0:24];
// load pixel color
logic  [1:0] load_color_r, load_color_w;
// operate pixel color
logic  [1:0] op_color_r, op_color_w;
// submodules
logic  [7:0] x [0:24];
logic [14:0] sum [0:4];
logic  [7:0] gau;
// output register
logic        o_valid_r, o_valid_w;
logic  [7:0] o_pixel_r, o_pixel_w;
// for loop
integer i, j, k;

assign o_valid = o_valid_r;
assign o_pixel = o_pixel_r;
assign o_pixel_w = gau;

filter_col_0 fil0 ( x[0],  x[1],  x[2],  x[3],  x[4],  sum[0] );
filter_col_1 fil1 ( x[5],  x[6],  x[7],  x[8],  x[9],  sum[1] );
filter_col_2 fil2 ( x[10], x[11], x[12], x[13], x[14], sum[2] );
filter_col_1 fil3 ( x[15], x[16], x[17], x[18], x[19], sum[3] );
filter_col_0 fil4 ( x[20], x[21], x[22], x[23], x[24], sum[4] );
sum_n_divide snd  ( sum[0], sum[1], sum[2], sum[3], sum[4], gau );

// load pixel into registers color by color
always_comb begin
    // initialize
    load_color_w = load_color_r;
    R_pixel_w = R_pixel_r;
    G_pixel_w = G_pixel_r;
    B_pixel_w = B_pixel_r;
    
    if (i_valid) begin
        case (load_color_r)
            RED: begin
                load_color_w = GREEN;
                for (i=1;i<25;i=i+1) begin
                    R_pixel_w[i-1] = R_pixel_r[i];
                end
                R_pixel_w[24] = i_pixel;
            end

            GREEN: begin
                load_color_w = BLUE;
                for (i=1;i<25;i=i+1) begin
                    G_pixel_w[i-1] = G_pixel_r[i];
                end
                G_pixel_w[24] = i_pixel;
            end

            BLUE: begin
                load_color_w = RED;
                for (i=1;i<25;i=i+1) begin
                    B_pixel_w[i-1] = B_pixel_r[i];
                end
                B_pixel_w[24] = i_pixel;
            end            
        endcase
    end
end

// choose color image to calculate output
always_comb begin
	// initialize
	for (k=0;k<25;k=k+1) begin
		x[k] = 0;
	end
	op_color_w = op_color_r;

	case (op_color_r)
		RED: begin
			op_color_w = GREEN;
			for (k=0;k<25;k=k+1) begin
				x[k] = R_pixel_r[k];
			end
		end
		GREEN: begin
			op_color_w = BLUE;
			for (k=0;k<25;k=k+1) begin
				x[k] = G_pixel_r[k];
			end
		end
		BLUE: begin
			op_color_w = RED;
			for (k=0;k<25;k=k+1) begin
				x[k] = B_pixel_r[k];
			end
		end
	endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		for (j=0;j<25;j=j+1) begin
			R_pixel_r[j] <= 0;
			G_pixel_r[j] <= 0;
			B_pixel_r[j] <= 0;
		end
        load_color_r <= 0;
        o_valid_r <= 0;
        o_pixel_r <= 0;
    end
    else begin
    	for (j=0;j<25;j=j+1) begin
			R_pixel_r[j] <= R_pixel_w[j];
			G_pixel_r[j] <= G_pixel_w[j];
			B_pixel_r[j] <= B_pixel_w[j];
		end
        load_color_r <= load_color_w;
        o_valid_r <= o_valid_w;
        o_pixel_r <= o_pixel_w;
    end
end

endmodule

module filter_col_0 (
    input   [7:0] pixel_0,
	input   [7:0] pixel_1,
	input   [7:0] pixel_2,
	input   [7:0] pixel_3,
	input   [7:0] pixel_4,
	output [14:0] sum
);
	
	logic [11:0] extend_1;
	logic [11:0] extend_2;
	logic [11:0] extend_3;
	logic [11:0] extend_4;
	logic [11:0] extend_5;
	logic [11:0] w0, w1, w2, w3;

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
    input   [7:0] pixel_0,
	input   [7:0] pixel_1,
	input   [7:0] pixel_2,
	input   [7:0] pixel_3,
	input   [7:0] pixel_4,
	output [14:0] sum
);

	logic [11:0] extend_1;
	logic [11:0] extend_2;
	logic [11:0] extend_3;
	logic [11:0] extend_4;
	logic [11:0] extend_5;
	logic [11:0] w0, w1, w2, w3, w4, w5;

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
    input   [7:0] pixel_0,
	input   [7:0] pixel_1,
	input   [7:0] pixel_2,
	input   [7:0] pixel_3,
	input   [7:0] pixel_4,
	output [14:0] sum
);

	logic [11:0] extend_1;
	logic [11:0] extend_2;
	logic [11:0] extend_3;
	logic [11:0] extend_4;
	logic [11:0] extend_5;
	logic [11:0] w0, w1, w2, w3, w4, w5, w6, w7;

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
    input [14:0] in1,
    input [14:0] in2,
    input [14:0] in3,
    input [14:0] in4,
    input [14:0] in5,
	output [7:0] out
);

	logic [17:0] w0, w1, w2, w3, w4, w5, w6;

	assign w0 = in1 + in2;
	assign w1 = in3 + in4;
	assign w2 = w0  + in5;
	assign w3 = w1  + w2;

	assign w4 = (w3 >> 7)  - (w3 >> 9);
	assign w5 = (w3 >> 11) - (w3 >> 14);
	assign w6 = w4 + w5;

	assign out = { w6[7:0] };

endmodule