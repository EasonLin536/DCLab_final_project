module paintLayer(
    input           i_clk,
    input           rst_n,
    input   [23:0]  data
);
<<<<<<< HEAD
//===== for find max ====
logic   [23:0]  result_0[0:7][0:3];
logic   [2:0]   max_0[0:7][0:3];
logic   [23:0]  result_1[0:7][0:1];
logic   [2:0]   max_1[0:7][0:1];
logic   [23:0]  result_2[0:7];
logic   [2:0]   max_2[0:7];
logic   [23:0]  result_3[0:3];
logic   [2:0]   max_3[0:3];
logic   [23:0]  result_4[0:1];
logic   [2:0]   max_4[0:1];
logic   [23:0]  result_5;
logic   [2:0]   max_5;
=======
logic   [23:0]  gridRegion[0:7][0:7];
logic   [23:0]  result_0[0:7][0:3];
logic   [2:0]   max_0[0:7][0:3];
logic   [2:0]   max_x, max_y;

>>>>>>> dbce1c94c3370556f990bda303707686093feedb
genvar i, j;
generate
    for (i = 0; i < 8; i++) begin
        for (j = 0; j < 4; j++) begin
            assign result_0[i][j] = (gridRegion[i][2 * j] > gridRegion[i][2 * j + 1])? gridRegion[i][2 * j] : gridRegion[i][2 * j + 1];
            assign max_0[i][j] = (gridRegion[i][2 * j] > gridRegion[i][2 * j + 1])? 2 * j : 2 * j + 1;
        end
    end
endgenerate
<<<<<<< HEAD
generate
    for (i = 0; i < 8; i++) begin
        for (j = 0; j < 2; j++) begin
            assign result_1[i][j] = (result_0[i][2 * j] > result_0[i][2 * j + 1])? result_0[i][2 * j] : result_0[i][2 * j + 1];
            assign max_1[i][j] = (result_0[i][2 * j] > result_0[i][2 * j + 1])? max_0[i][2 * j] : max_0[i][2 * j + 1];
        end
    end
endgenerate
generate
    for (i = 0; i < 8; i++) begin
        assign result_2[i] = (result_1[i][0] > result_1[i][1])? result_1[i][j] : result_1[i][1];
        assign max_2[i] = (result_1[i][0] > result_1[i][1])? max_1[i][j] : max_1[i][1];
    end
endgenerate
generate
    for (i = 0; i < 4; i++) begin
        assign result_3[i] = (result_2[2 * i] > result_2[2 * i + 1])? result_2[2 * i] : result_2[2 * i + 1];
        assign max_3[i] = (result_2[2 * i] > result_2[2 * i + 1])? 2 * i : 2 * i + 1;
    end
endgenerate
generate
    for (i = 0; i < 2; i++) begin
        assign result_4[i] = (result_3[2 * i] > result_3[2 * i + 1])? result_3[2 * i] : result_3[2 * i + 1];
        assign max_4[i] = (result_3[2 * i] > result_3[2 * i + 1])? 2 * i : 2 * i + 1;
    end
endgenerate
assign result_5 = (result_4[0] > result_4[1])? result_4[0] : result_4[1];
assign max_5 = (result_4[0] > result_4[1])? 0 : 1;
assign max_x = max_5;
assign max_y = max_2[max_5];
//=====
logic   [23:0]  gridRegion[0:7][0:7];
logic   [2:0]   max_x, max_y;
logic   [2:0]   state_w, state_r;

always_comb begin
    
end
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        
    end
    else begin
        
    end
end
=======
>>>>>>> dbce1c94c3370556f990bda303707686093feedb
endmodule
