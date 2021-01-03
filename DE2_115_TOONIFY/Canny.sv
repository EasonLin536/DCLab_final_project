`include "VGA_Param.h" 
`define DATA_SIZE 4

module Canny (
    input                   i_clk,
    input                   i_rst_n,
    input  [3:0]            i_seg_width,
    input  [4:0]            i_SW,
    input                   i_is_new_read,
    input  [`DATA_SIZE-1:0] i_data,
    output [`DATA_SIZE-1:0] o_data
);

`ifdef VGA_640x480p60
    parameter H_LIMIT = 800;
    // parameter H_START = 144;
    parameter H_START = 0;
    parameter V_LIMIT = 525;
`else
    parameter H_LIMIT = 1056;
    parameter H_START = 216;
    parameter V_LIMIT = 628;
`endif

parameter H_VALID      = H_LIMIT - H_START;
parameter BUFFER_WIDTH = 3;
parameter REF_WIDTH    = 3;

typedef enum {
    S_IDLE,
    S_READ
} IP_state;

logic [2:0]            state_w, state_r;
// image processing cursor
logic [10:0]           H_reg_cursor;
logic [10:0]           H_cursor_w, H_cursor_r;
logic [10:0]           V_cursor_w, V_cursor_r;
// buffer registers
logic [`DATA_SIZE-1:0] grid_region_w   [0:BUFFER_WIDTH-1][0:H_VALID-1], grid_region_r   [0:BUFFER_WIDTH-1][0:H_VALID-1];
logic [`DATA_SIZE-1:0] blur_region_w   [0:BUFFER_WIDTH-1][0:H_VALID-1], blur_region_r   [0:BUFFER_WIDTH-1][0:H_VALID-1];
logic [`DATA_SIZE-1:0] grad_region_w   [0:BUFFER_WIDTH-1][0:H_VALID-1], grad_region_r   [0:BUFFER_WIDTH-1][0:H_VALID-1];
logic [1:0]            angle_region_w  [0:BUFFER_WIDTH-1][0:H_VALID-1], angle_region_r  [0:BUFFER_WIDTH-1][0:H_VALID-1];
logic [`DATA_SIZE-1:0] nonmax_region_w [0:BUFFER_WIDTH-1][0:H_VALID-1], nonmax_region_r [0:BUFFER_WIDTH-1][0:H_VALID-1];
// output
logic [`DATA_SIZE-1:0] out_data_w, out_data_r;

assign H_reg_cursor = H_cursor_r - H_START;
assign o_data = out_data_r;

// ===== blur input =====
logic        [(`DATA_SIZE + 4)*9-1:0] blur_in;
logic signed [10:0]                   blur_cursor;
logic        [(`DATA_SIZE + 4)-1:0]   blur_out;

assign blur_cursor = H_reg_cursor - REF_WIDTH - 1;
genvar x, y;
generate
    for(x = 0; x < 3; x = x + 1) begin :V_blur_BLOCK
        for(y = 0; y < 3; y = y + 1) begin :H_blur_BLOCK
            assign blur_in[(`DATA_SIZE + 4)*9-1 - (`DATA_SIZE + 4)*(3*x + y) -: (`DATA_SIZE + 4)] 
                   = (blur_cursor + x >= 0)? 
                   { grid_region_r[y + BUFFER_WIDTH - REF_WIDTH][blur_cursor + x], 4'b0001 }:
                   { grid_region_r[y + BUFFER_WIDTH - REF_WIDTH][0], 4'b0001 };
        end
    end
endgenerate

Gau_Fil gau_fil (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_pixel(blur_in), // input pixel
    .o_pixel(blur_out)  // output pixel
);

// ===== sobel input =====
logic        [(`DATA_SIZE + 4)*9-1:0] sobel_in;
logic signed [10:0]                   sobel_cursor;
logic        [(`DATA_SIZE + 4)-1:0]   sobel_grad;
logic        [1:0]                    sobel_angle;

assign sobel_cursor = blur_cursor - REF_WIDTH - 1;
generate
    for(x = 0; x < 3; x = x + 1) begin :V_sobel_BLOCK
        for(y = 0; y < 3; y = y + 1) begin :H_sobel_BLOCK
            assign sobel_in[(`DATA_SIZE + 4)*9-1 - (`DATA_SIZE + 4)*(3*x + y) -: (`DATA_SIZE + 4)] 
                   = (sobel_cursor + x >= 0)? 
                   { blur_region_r[y + BUFFER_WIDTH - REF_WIDTH][sobel_cursor + x], 4'b0001 } :
                   { blur_region_r[y + BUFFER_WIDTH - REF_WIDTH][0], 4'b0001 };
        end
    end
endgenerate

Sobel sobel(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_pixel(sobel_in),
    .o_grad(sobel_grad), // gradient
    .o_angle(sobel_angle) // angle
);

// ===== nonmax input =====
logic   [(`DATA_SIZE)*9-1:0]  nonmax_grad;
logic   [1:0]                 nonmax_angle;
logic signed [10:0]               nonmax_cursor;
logic   [(`DATA_SIZE)-1:0]    nonmax_out;

assign nonmax_cursor = sobel_cursor - REF_WIDTH - 1;
assign nonmax_angle = angle_region_r[1][nonmax_cursor + 1];
generate
    for(x = 0; x < 3; x = x + 1) begin :V_nonmax_BLOCK
        for(y = 0; y < 3; y = y + 1) begin :H_nonmax_BLOCK
            assign nonmax_grad[(`DATA_SIZE)*9-1 - (`DATA_SIZE)*(3*x + y) -: (`DATA_SIZE)] 
                   = (nonmax_cursor + x >= 0)? 
                   grad_region_r[y + BUFFER_WIDTH - REF_WIDTH][nonmax_cursor + x]:
                   grad_region_r[y + BUFFER_WIDTH - REF_WIDTH][0];
        end
    end
endgenerate

NonMax nonmax(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_angle(nonmax_angle),
    .i_grad(nonmax_grad),
    .o_pixel(nonmax_out)
);

// ===== hyster input =====
logic        [(`DATA_SIZE)*9-1:0] hyster_in;
logic signed [10:0]               hyster_cursor;
logic                             hyster_out;

assign hyster_cursor = nonmax_cursor - REF_WIDTH - 1;
generate
    for(x = 0; x < 3; x = x + 1) begin :V_hyster_BLOCK
        for(y = 0; y < 3; y = y + 1) begin :H_hyster_BLOCK
            assign hyster_in[(`DATA_SIZE)*9-1 - (`DATA_SIZE)*(3*x + y) -: (`DATA_SIZE)] 
                   = (hyster_cursor + x >= 0)? 
                   nonmax_region_r[y + BUFFER_WIDTH - REF_WIDTH][hyster_cursor + x]:
                   nonmax_region_r[y + BUFFER_WIDTH - REF_WIDTH][0];
        end
    end
endgenerate

Hyster hyster(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_seg_width(i_seg_width),
	.i_pixel(hyster_in),
	.o_pixel(hyster_out)
);

// store gray pixel to buffer registers
integer i, j;
always_comb begin
    state_w    = state_r;
    H_cursor_w = H_cursor_r;
    V_cursor_w = V_cursor_r;
    for (i = 0; i < BUFFER_WIDTH; i = i + 1) begin
        for (j = 0; j < H_VALID; j = j + 1) begin
            grid_region_w[i][j] = grid_region_r[i][j];
        end
    end
    case (state_r)
        S_IDLE: begin
            if (i_is_new_read) begin
                state_w = S_READ;
                grid_region_w[BUFFER_WIDTH-1][0] = i_data;
                H_cursor_w = H_cursor_r + 1;
            end
        end
        S_READ: begin
            grid_region_w[BUFFER_WIDTH-1][H_reg_cursor] = i_data;
            H_cursor_w = H_cursor_r + 1;
            if (H_cursor_r == H_LIMIT - 1) begin
                H_cursor_w = 0;
                if (V_cursor_r == V_LIMIT - 1) begin
                    V_cursor_w = 0;
                end
                else begin
                    V_cursor_w = V_cursor_r + 1;
                    for (i = BUFFER_WIDTH-REF_WIDTH; i < BUFFER_WIDTH-1; i = i + 1) begin
                        for (j = 0; j < H_VALID; j = j + 1) begin
                            grid_region_w[i][j] = grid_region_r[i+1][j];
                        end
                    end
                    grid_region_w[BUFFER_WIDTH-2][H_reg_cursor] = i_data;
                end
            end
        end
    endcase
end
// store output of blur to registers
always_comb begin
    for (i = 0; i < BUFFER_WIDTH; i = i + 1) begin
        for (j = 0; j < H_VALID; j = j + 1) begin
            blur_region_w[i][j] = blur_region_r[i][j];
        end
    end
    blur_region_w[BUFFER_WIDTH-1][H_reg_cursor] = blur_out[7:4];
    if (H_cursor_r == H_LIMIT - 1) begin
        if (V_cursor_r != V_LIMIT - 1) begin
            for (i = BUFFER_WIDTH-REF_WIDTH; i < BUFFER_WIDTH-1; i = i + 1) begin
                for (j = 0; j < H_VALID; j = j + 1) begin
                    blur_region_w[i][j] = blur_region_r[i+1][j];
                end
            end
            blur_region_w[BUFFER_WIDTH-2][H_reg_cursor] = blur_out[7:4];
        end
    end
end
// store output of sobel to registers
always_comb begin
    for (i = 0; i < BUFFER_WIDTH; i = i + 1) begin
        for (j = 0; j < H_VALID; j = j + 1) begin
            grad_region_w[i][j] = grad_region_r[i][j];
            angle_region_w[i][j] = angle_region_r[i][j];
        end
    end
    grad_region_w[BUFFER_WIDTH-1][H_reg_cursor] = sobel_grad[7:4];
    angle_region_w[BUFFER_WIDTH-1][H_reg_cursor] = sobel_angle;
    if (H_cursor_r == H_LIMIT - 1) begin
        if (V_cursor_r != V_LIMIT - 1) begin
            for (i = BUFFER_WIDTH-REF_WIDTH; i < BUFFER_WIDTH-1; i = i + 1) begin
                for (j = 0; j < H_VALID; j = j + 1) begin
                    grad_region_w[i][j] = grad_region_r[i+1][j];
                    angle_region_w[i][j] = angle_region_r[i+1][j];
                end
            end
            grad_region_w[BUFFER_WIDTH-2][H_reg_cursor] = sobel_grad[7:4];
            angle_region_w[BUFFER_WIDTH-2][H_reg_cursor] = sobel_angle;
        end
    end
end
// store output of nonmax to registers
always_comb begin
    for (i = 0; i < BUFFER_WIDTH; i = i + 1) begin
        for (j = 0; j < H_VALID; j = j + 1) begin
            nonmax_region_w[i][j] = nonmax_region_r[i][j];
        end
    end
    nonmax_region_w[BUFFER_WIDTH-1][H_reg_cursor] = nonmax_out;
    if (H_cursor_r == H_LIMIT - 1) begin
        if (V_cursor_r != V_LIMIT - 1) begin
            for (i = BUFFER_WIDTH-REF_WIDTH; i < BUFFER_WIDTH-1; i = i + 1) begin
                for (j = 0; j < H_VALID; j = j + 1) begin
                    nonmax_region_w[i][j] = nonmax_region_r[i+1][j];
                end
            end
            nonmax_region_w[BUFFER_WIDTH-2][H_reg_cursor] = nonmax_out;
        end
    end
end

// output logic
always_comb begin
    out_data_w = out_data_r;
    if (i_SW[4]) begin
        out_data_w = i_data;
    end
    else if (i_SW[3]) begin
        out_data_w = blur_out[7:4];
    end
    else if (i_SW[2]) begin
        out_data_w = sobel_grad[7:4];
    end
    else if (i_SW[1]) begin
        out_data_w = nonmax_out;
    end
    else begin
        out_data_w = { 4{hyster_out} };
    end
end

integer a, b;
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state_r    <= S_IDLE;
        H_cursor_r <= 0;
        V_cursor_r <= 0;
        
        for(a = 0; a < BUFFER_WIDTH; a = a + 1) begin
            for(b = 0; b < H_VALID; b = b + 1) begin
                grid_region_r[a][b] <= 0;
            end
        end
        for(a = 0; a < BUFFER_WIDTH; a = a + 1) begin
            for(b = 0; b < H_VALID; b = b + 1) begin
                blur_region_r[a][b] <= 0;
            end
        end
        for(a = 0; a < BUFFER_WIDTH; a = a + 1) begin
            for(b = 0; b < H_VALID; b = b + 1) begin
                grad_region_r[a][b] <= 0;
                angle_region_r[a][b] <= 0;
            end
        end
        for(a = 0; a < BUFFER_WIDTH; a = a + 1) begin
            for(b = 0; b < H_VALID; b = b + 1) begin
                nonmax_region_r[a][b] <= 0;
            end
        end
        out_data_r <= 0;
    end
    else begin
        state_r    <= state_w;
        H_cursor_r <= H_cursor_w;
        V_cursor_r <= V_cursor_w;
        
        for(a = 0; a < BUFFER_WIDTH; a = a + 1) begin
            for(b = 0; b < H_VALID; b = b + 1) begin
                grid_region_r[a][b] <= grid_region_w[a][b];
            end
        end
        for(a = 0; a < BUFFER_WIDTH; a = a + 1) begin
            for(b = 0; b < H_VALID; b = b + 1) begin
                blur_region_r[a][b] <= blur_region_w[a][b];
            end
        end
        for(a = 0; a < BUFFER_WIDTH; a = a + 1) begin
            for(b = 0; b < H_VALID; b = b + 1) begin
                grad_region_r[a][b] <= grad_region_w[a][b];
                angle_region_r[a][b] <= angle_region_w[a][b];
            end
        end
        for(a = 0; a < BUFFER_WIDTH; a = a + 1) begin
            for(b = 0; b < H_VALID; b = b + 1) begin
                nonmax_region_r[a][b] <= nonmax_region_w[a][b];
            end
        end
        out_data_r <= out_data_w;
    end
end

endmodule