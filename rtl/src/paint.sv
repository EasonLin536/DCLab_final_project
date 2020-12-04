module paint(
    input          i_clk,
    input          i_rst_n,
    input [11:0]   brushR // 4bit*3
    // input sourceImg

);

`define IMG_SHAPE_X 1
`define IMG_SHAPE_Y 1

reg [23:0] oilImg_r [0:`IMG_SHAPE_X-1][0:`IMG_SHAPE_Y-1];
reg [23:0] oilImg_w [0:`IMG_SHAPE_X-1][0:`IMG_SHAPE_Y-1];
    
integer i, j;
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        for(i=0;i<`IMG_SHAPE_X;i=i+1)
            for(j=0;j<`IMG_SHAPE_Y;j=j+1)
                oilImg_r[i][j] <= 0;
    else begin
        
    end
    end
end
endmodule