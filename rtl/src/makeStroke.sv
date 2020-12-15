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
    input   signed [7:0] gradX_xy_i,
    input   signed [7:0] gradY_xy_i,
    input   [7:0] gradM_xy_i,
    input   [23:0] strokeColor_i,

    output  [9:0] x_o,
    output  [9:0] y_o,
    output        finish
);

parameter minLen    =   4;
parameter maxLen    =   16;
parameter fc        =   1'b1;


logic [9:0] strokeLen_w, strokeLen_r;
logic [7:0] dxF_w, dyF_w, dxF_r, dyF_r;
logic finish_w, finish_r;

logic diffColor;
logic [7:0] dx, dy, dx2, dy2, dx3, dy3, dx4, dy4;
logic [4:0] s;
logic [16:0] d;

logic [9:0] x_w, y_w, x_r, y_r;

assign finish = finish_r;
assign x_o = x_r;
assign y_o = y_r;

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

// larger than 2**8 : shifter
// else : divider
function [4:0] square1;
    input [16:0] a; 
    begin
        if(a[16]==1) square1 = 5'd8;
        else if(a[14]==1) square1 = 5'd7;
        else if(a[12]==1) square1 = 5'd6;
        else if(a[10]==1) square1 = 5'd5;
        else square1 = 5'd4;
    end
endfunction

function [4:0] square2;
    input [7:0] a; 
    begin
        if(a>=100) square2 = 5'd10;
        else if(a>=81) square2 = 5'd9;
        else if(a>=64) square2 = 5'd8;
        else if(a>=49) square2 = 5'd7;
        else if(a>=36) square2 = 5'd6;
        else if(a>=25) square2 = 5'd5;
        else if(a>=16) square2 = 5'd4;
        else if(a>=9)  square2 = 5'd3;
        else if(a>=4)  square2 = 5'd2;
        else square2 = 5'd1;
    end
endfunction

always_comb begin
    diffColor = diff(refColor_i[23-:8],canvas_i[23-:8],strokeColor_i[23-:8]) 
                && diff(refColor_i[15-:8],canvas_i[15-:8],strokeColor_i[15-:8]) 
                && diff(refColor_i[7-:8],canvas_i[7-:8],strokeColor_i[7-:8]);
    if((strokeLen_r > minLen && diffColor) || (strokeLen_r==maxLen) || gradM_xy_i == 0) begin
        // this part may be moved to paintLayer(?
        finish_w = 1;
        // avoid latch!
    end
    else begin
        finish_w = 0;
        // pass
        dx = -gradY_xy_i
        dy = gradX_xy_i

        if(dxF_r * dx + dyF_r * dy < 0) begin
            dx2 = -dx;
            dy2 = -dy;
        end
        else begin
            dx2 = dx;
            dy2 = dy;
        end

        // fc only 1 bit
        dx3 = fc ? dx : dxF_r;
        dy3 = fc ? dy : dyF_r;

        d = dx3*dx3 + dy3*dy3
        if(|d[16:8]) begin  // d >= 2**8
            s = square1(d);
            dx4 = dx3 >> s;
            dy4 = dy3 >> s;
        end
        else begin
            s = square2(d);
            dx4 = dx3 / s;
            dy4 = dy3 / s;
        end
        // pass

        x_w = x_i + R_i * dx4;
        y_w = y_i + R_i * dy4;

        dxF_w = dx4;
        dyF_w = dy4;

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