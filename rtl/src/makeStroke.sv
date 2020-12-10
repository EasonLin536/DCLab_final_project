module makeStroke (
    input   i_clk,
    input   i_rst_n,
    input   [3:0] R_i,
    input   [9:0] x0_i,
    input   [9:0] y0_i,
    input   [9:0] x_i,
    input   [9:0] y_i,
    input   [9:0] center_x_i,
    input   [9:0] center_y_i,
    input   [8*8*24-1:0] refImage_i,  //8*8*24 array
    input   [23:0] canvas_i,    // parameter(?)
    input   [8*8*8-1:0] gradX_i,    // 8*8*8
    input   [8*8*8-1:0] gradY_i,    // 8*8*8
    input   [8*8*8-1:0] gradM_i,    // 8*8
    input   [23:0] strokeColor_i,

    output  [9:0] x_o,
    output  [9:0] y_o,
    output        finish
);

reg [9:0] strokeLen_w, strokeLen_r;
reg [7:0] dxF_w, dyF_w, dxF_r, dyF_r;
reg finish_w, finish_r;

assign finish = finish_r;

function [7:0] abs;
    input [7:0] num_i;
    begin
        abs = (num_i[7]) ? (~num_i+1'b1) : num_i;
    end
    
endfunction

always_comb begin
    
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        dxF_r <= 0;
        dyF_r <= 0;
        strokeLen_r <= 0;
        finish_r <= 0;
    end
    else begin
        dxF_r <= dxF_w;
        dyF_r <= dyF_w;
        strokeLen_r <= strokeLen_w;
        finish_r <= finish_w;
    end
end
    
endmodule