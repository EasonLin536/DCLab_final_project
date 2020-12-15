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
    input   [23:0] refColor_i,  //8*8*24 array
    input   [23:0] canvas_i,    // parameter(?)
    input   [7:0] gradX_xy_i,
    input   [7:0] gradY_xy_i,
    input   [7:0] gradM_xy_i,
    input   [23:0] strokeColor_i,

    output  [9:0] x_o,
    output  [9:0] y_o,
    output        finish
);

parameter minLen    =   4;
parameter maxLen    =   16;


logic [9:0] strokeLen_w, strokeLen_r;
logic [7:0] dxF_w, dyF_w, dxF_r, dyF_r;
logic finish_w, finish_r;

logic diffColor;

assign finish = finish_r;

function diff;
    input [7:0] a;
    input [7:0] b;
    input [7:0] c;
    reg signed [8:0] tmp1, tmp2;
    begin
        // diff = ((a>b) ? a-b : b-a) < ((a>c) ? a-c : c-a);
        tmp1=a-b;
        tmp2=a-c;
        diff = (tmp1[8] ? (~tmp1+1) : tmp1) < (tmp2[8] ? (~tmp2+1) : tmp2);
    end
    
endfunction

always_comb begin
    diffColor = diff(refColor_i[23-:8],canvas_i[23-:8],strokeColor_i[23-:8]) 
                && diff(refColor_i[15-:8],canvas_i[15-:8],strokeColor_i[15-:8]) 
                && diff(refColor_i[7-:8],canvas_i[7-:8],strokeColor_i[7-:8]);
    if((strokeLen_r > minLen && diffColor) || (strokeLen_r==maxLen)) begin // || gradM[x, y] == 0
        finish_w = 1;
    end
    else begin

    end
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