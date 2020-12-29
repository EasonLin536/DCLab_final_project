`define DSIZE 4
`define ANGSIZE 2

module NonMax (
    input                 i_clk,
    input                 i_rst_n,
    input  [`ANGSIZE-1:0] i_angle,
    input  [`DSIZE*9-1:0] i_grad,
    output   [`DSIZE-1:0] o_pixel
);

logic   [`DSIZE-1:0] grad_arr [0:8];
logic   [`DSIZE-1:0] o_pixel_w, o_pixel_r;

assign o_pixel = o_pixel_r;

// pixel array
/*
  0 1 2
  3 4 5
  6 7 8
*/
integer i;
always_comb begin
    for (i=0;i<9;i=i+1) begin
        grad_arr[i] = i_grad[`DSIZE*9-1-i*`DSIZE -: `DSIZE];
    end
end

// 4 is not the maximun
always_comb begin
    case (i_angle)
        2'b00: begin //  |
            o_pixel_w = ((grad_arr[1] > grad_arr[4]) || 
                        (grad_arr[7] > grad_arr[4])) ?
                        0 : grad_arr[4];
        end
        2'b01: begin //  /
            o_pixel_w = ((grad_arr[2] > grad_arr[4]) || 
                        (grad_arr[6] > grad_arr[4])) ?
                        0 : grad_arr[4];
        end
        2'b10: begin //  -
            o_pixel_w = ((grad_arr[3] > grad_arr[4]) || 
                        (grad_arr[5] > grad_arr[4])) ?
                        0 : grad_arr[4];
        end
        2'b11: begin //  \
            o_pixel_w = ((grad_arr[0] > grad_arr[4]) || 
                        (grad_arr[8] > grad_arr[4])) ?
                        0 : grad_arr[4];
        end
    endcase
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