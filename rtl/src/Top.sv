module TOP(
    input           i_clk,
    input           i_rst_n,
    input   [15:0]  i_sdram_data_1,
    input   [15:0]  i_sdram_data_2,
    input   [12:0]  i_H_Cont,
    input   [12:0]  i_V_Cont,
    input           i_s_wen,
    inout   [15:0]  io_s_dq,
    input   [19:0]  o_s_addr,
    output  [9:0]   o_display_Red,
    output  [9:0]   o_display_Green,
    output  [9:0]   o_display_Blue
    output          o_CCD_pause
);

 
parameter T         =   50;
parameter fg        =   1;
parameter fs        =   0.5;
parameter fc        =   1;
parameter maxLen    =   16;
parameter minLen    =   4;
parameter brushR    =   {5'd8, 5'd4, 5'd2};

parameter BOUND = 800 * 8 * 2;

typedef enum {
    S_IDLE,
    S_RECD,
    S_PREC
} Top_state;

logic   [7:0]   OriginRed, OriginGreen, OriginBlue;
logic   [23:0]  OriginPicture;
logic   [2:0]   state_w, state_r;
logic   [19:0]  s_addr_w, s_addr_r;
logic   [15:0]  s_data_w, s_data_r;
logic           ccd_pause_w, ccd_pause_r;

assign OriginRed     = i_sdram_data_2[9:2];
assign OriginGreen   = {i_sdram_data_1[14:10], i_sdram_data_2[14:12]};
assign OriginBlue    = i_sdram_data_1[9:2];
// assign OriginPicture = {OriginRed, OriginGreen, OriginBlue};

assign o_display_Red   = {OriginPicture[23:16], 2'b00};
assign o_display_Green = {OriginPicture[15:8] , 2'b00};
assign o_display_Blue  = {OriginPicture[7:0]  , 2'b00};

assign io_s_dq = (state_r == S_RECD) ? s_data_r : 16'z;
assign i_s_wen = (state_r == S_RECD) ? 1'b0 : 1'b1; // write : read
assign o_s_addr = s_addr_r;

always_comb begin
    if(i_V_Cont < 64) begin
        OriginPicture = {OriginRed, OriginGreen, OriginBlue};
    end
    else begin
        OriginPicture = 24'd0;
    end
end
// BLUR Blur(
//     i_clk,
//     i_rst_n,
//     i_row_end,
//     i_valid,
    
// );
// always_comb begin
//     state_w = state_r;
//     case(state_r)
//         S_IDLE: begin
//             state_w = S_RECD;
//         end
//         S_RECD: begin
//             state_w = S_PREC;
//             s_addr_w = s_addr_r + 1;
//             s_data_w = i_sdram_data_1;
//             ccd_pause_w = 1'b1;
//             if(s_addr == BOUND) begin
//                 state_w = S_GIVE;
//             end
//         end
//         S_PREC: begin
//             state_w = S_RECD;
//             s_addr_w = s_addr_r + 1;
//             s_data_w = i_sdram_data_2;
//             ccd_pause_w = 1'b0;
//         end
//         S_GIVE: begin
            
//         end
//         default: begin
            
//         end
//     endcase
// end
// always_ff @(posedge i_clk or negedge i_rst_n) begin
//     if(!i_rst_n) begin
//         state_r <= S_IDLE;
//         s_addr_r <= 0;
//         s_data_r <= 0;
//     end
//     else begin
//         state_r <= state_w;
//         s_addr_r <= s_addr_w;
//         s_data_r <= s_data_w;
//     end
// end
endmodule