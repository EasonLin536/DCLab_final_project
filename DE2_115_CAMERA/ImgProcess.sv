`include "VGA_Param.h" 

module ImgProcess(
    input                   i_clk,
    input                   i_rst_n,
    input                   i_is_new_read,
    input   [DATA_SIZE-1:0] i_data,
    output  [DATA_SIZE-1:0] o_data
);
`ifdef VGA_640x480p60
    parameter H_LIMIT = 800;
    parameter V_LIMIT = 525;
`else
    parameter H_LIMIT = 1056;
    parameter V_LIMIT = 628;
`endif
parameter BUFFER_WIDTH = 5;
parameter DATA_SIZE    = 15;

typedef enum {
    S_IDLE,
    S_READ
} IP_state;

logic   [2:0]            state_w, state_r;
logic   [10:0]           H_cursor_w, H_cursor_r;
logic   [10:0]           V_cursor_w, V_cursor_r;
logic   [DATA_SIZE-1:0]  grid_region_w[0:BUFFER_WIDTH-1][0:H_LIMIT-1], grid_region_r[0:BUFFER_WIDTH-1][0:H_LIMIT-1];

logic   [DATA_SIZE-1:0]  out_data_w, out_data_r;

assign o_data = out_data_r;

integer i, j;
always_comb begin
    state_w = state_r;
    H_cursor_w = H_cursor_r;
    V_cursor_w = V_cursor_r;
    for(i = 0; i < BUFFER_WIDTH; i = i + 1) begin
        for(j = 0; j < H_LIMIT; j = j + 1) begin
            grid_region_w[i][j] = grid_region_r[i][j];
        end
    end
    case(state_r)
        S_IDLE: begin
            if(i_is_new_read) begin
                state_w = S_READ;
                grid_region_w[BUFFER_WIDTH-1][0] = i_data;
                H_cursor_w = H_cursor_r + 1;
            end
        end
        S_READ: begin
            grid_region_w[BUFFER_WIDTH-1][H_cursor_r] = i_data;
            H_cursor_w = H_cursor_r + 1;
            if(H_cursor_r == H_LIMIT - 1) begin
                H_cursor_w = 0;
                if(V_cursor_r == V_LIMIT - 1) begin
                    V_cursor_w = 0;
                    for(i = 0; i < BUFFER_WIDTH; i = i + 1) begin
                        for(j = 0; j < H_LIMIT; j = j + 1) begin
                            grid_region_w[i][j] = 0;
                        end
                    end
                end
                else begin
                    V_cursor_w = V_cursor_r + 1;
                    for(i = 0; i < BUFFER_WIDTH-1; i = i + 1) begin
                        for(j = 0; j < H_LIMIT; j = j + 1) begin
                            grid_region_w[i][j] = grid_region_r[i+1][j];
                        end
                    end
                end
            end
        end
        default: begin
            
        end
    endcase
end

always_comb begin
    out_data_w = out_data_r;
    if(H_cursor_r >= 5) begin
        out_data_w = grid_region_r[BUFFER_WIDTH - 1][H_cursor_r - 5];
    end
    else begin
        out_data_w = grid_region_r[BUFFER_WIDTH - 2][H_LIMIT + H_cursor_r - 5];
    end
end

integer a, b;
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state_r <= S_IDLE;
        H_cursor_r <= 0;
        V_cursor_r <= 0;
        for(a = 0; a < BUFFER_WIDTH; a = a + 1) begin
            for(b = 0; b < H_LIMIT; b = b + 1) begin
                grid_region_r[a][b] <= 0;
            end
        end
        out_data_r <= 0;
    end
    else begin
        state_r <= state_w;
        H_cursor_r <= H_cursor_w;
        V_cursor_r <= V_cursor_w;
        for(a = 0; a < BUFFER_WIDTH; a = a + 1) begin
            for(b = 0; b < H_LIMIT; b = b + 1) begin
                grid_region_r[a][b] <= grid_region_w[a][b];
            end
        end
        out_data_r <= out_data_w;
    end
end
endmodule