module paintLayer(
    input           i_clk,
    input           rst_n,
    input   [23:0]  data
);
logic   [23:0]  gridRegion[0:7][0:7];
logic   [23:0]  result_0[0:7][0:3];
logic   [2:0]   max_0[0:7][0:3];
logic   [2:0]   max_x, max_y;

genvar i, j;
generate
    for (i = 0; i < 8; i++) begin
        for (j = 0; j < 4; j++) begin
            assign result_0[i][j] = (gridRegion[i][2 * j] > gridRegion[i][2 * j + 1])? gridRegion[i][2 * j] : gridRegion[i][2 * j + 1];
            assign max_0[i][j] = (gridRegion[i][2 * j] > gridRegion[i][2 * j + 1])? 2 * j : 2 * j + 1;
        end
    end
endgenerate
endmodule
