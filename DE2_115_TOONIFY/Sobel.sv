`define DSIZE 8
`define ANGSIZE 2

module Sobel (
    input                 i_clk,
    input                 i_rst_n,
    input  [`DSIZE*9-1:0] i_pixel,
    output [`DSIZE-1:0]   o_grad, // gradient
    output [`ANGSIZE-1:0] o_angle // angle
);

logic   [`DSIZE-1:0] pixel_arr [0:8];

// output register
logic [`DSIZE-1:0]   o_grad_r;
logic [`DSIZE-1:0]   o_grad_w;
logic [`ANGSIZE-1:0] o_angle_r; 
logic [`ANGSIZE-1:0] o_angle_w;

logic [`DSIZE+1:0]   Gx, Gy;
logic [`DSIZE+1:0]   absGx;
logic [`DSIZE+1:0]   absGy;
logic [`DSIZE:0]     gradient;
logic [`DSIZE-1:0]   GxTan, GyTan;
logic                compX, compY, compSign;

assign o_grad = o_grad_r;
assign o_angle = o_angle_r;
// gradient
assign Gx = $signed((pixel_arr[0] + pixel_arr[1]*2 + pixel_arr[2]) - (pixel_arr[6] + pixel_arr[7]*2 + pixel_arr[8]));
assign Gy = $signed((pixel_arr[0] + pixel_arr[3]*2 + pixel_arr[6]) - (pixel_arr[2] + pixel_arr[5]*2 + pixel_arr[8]));
assign absGx = $signed(Gx) > 0 ? Gx : -$signed(Gx);
assign absGy = $signed(Gy) > 0 ? Gy : -$signed(Gy);
assign gradient = (absGx + absGy) >> 2;
assign o_grad_w = gradient[`DSIZE-1:0];
// angle
assign GxTan = (absGx >> 2) + (absGx >> 3) + (absGx >> 5) + (absGx >> 7);
assign GyTan = (absGy >> 2) + (absGy >> 3) + (absGy >> 5) + (absGy >> 7);
assign compX = GxTan > absGy ? 1 : 0;
assign compY = GyTan > absGx ? 1 : 0;
assign compSign = Gx[`DSIZE+1] ^ Gy[`DSIZE+1];

// pixel array
integer i;
always_comb begin
    for (i=0;i<9;i=i+1) begin
        pixel_arr[i] = i_pixel[`DSIZE*9-1-i*`DSIZE -: `DSIZE];
    end
end

always_comb begin
    if (!compX && !compY) begin
        o_angle_w = compSign? 3 : 1;
    end
    else begin
        o_angle_w = compX? 0 : 2;
    end
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin        
        o_grad_r  <= 0;
        o_angle_r <= 0;
    end
    else begin
        o_grad_r  <= o_grad_w;
        o_angle_r <= o_angle_w;
    end
end

endmodule