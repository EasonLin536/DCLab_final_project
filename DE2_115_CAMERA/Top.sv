module TOP(
    input           i_clk,
    input           i_rst_n,
    input   [15:0]  i_sdram_data_1,
    input   [15:0]  i_sdram_data_2,
    input           i_sdram_valid, // current sdram data is valid
    input   [12:0]  i_H_Cont,
    input   [12:0]  i_V_Cont,
    input   [15:0]  i_s_data,
    output  [15:0]  o_s_data,
    output          o_s_wen,
    output  [19:0]  o_s_addr,
    output  [9:0]   o_display_Red,
    output  [9:0]   o_display_Green,
    output  [9:0]   o_display_Blue,
    output          o_CCD_pause
);

 
parameter T         =   50;
parameter fg        =   1;
parameter fs        =   0.5;
parameter fc        =   1;
parameter maxLen    =   16;
parameter minLen    =   4;
parameter brushR    =   {5'd8, 5'd4, 5'd2};

parameter BOUND   = 800*600;
parameter H_BOUND = 512;
parameter V_BOUND = 384;

typedef enum {
    S_IDLE1,
    S_STOP,
    S_REC1,
    S_IDLE2,
    S_REC2,
    S_WAIT,
    S_GIVE
} Top_state;

logic   [9:0]   OriginRed, OriginGreen, OriginBlue;
logic   [15:0]  OriginPicture_w, OriginPicture_r;
logic   [2:0]   state_w, state_r;
logic   [19:0]  s_addr_w, s_addr_r;
logic           s_wen_w, s_wen_r;
logic   [15:0]  s_data_w, s_data_r;
logic           ccd_pause_w, ccd_pause_r;
logic   [14:0]  reduce_color;
logic   [3:0]   cnt_w, cnt_r;
logic   [12:0]  last_H_Cont_w, last_H_Cont_r;
// logic   [15:0]  store_color_w[800*5-1:0], store_color_r[800*5-1:0];

assign OriginRed     = i_sdram_data_2[9:0];
assign OriginGreen   = { i_sdram_data_1[14:10], i_sdram_data_2[14:10] };
assign OriginBlue    = i_sdram_data_1[9:0];
// assign OriginPicture = { OriginRed, OriginGreen, OriginBlue };

assign o_s_data = s_data_r;

assign o_display_Red   = { OriginPicture_r[14:10], 5'd0 };
assign o_display_Green = { OriginPicture_r[9:5],   5'd0 };
assign o_display_Blue  = { OriginPicture_r[4:0],   5'd0 };

// output entire reduced image
// assign o_display_Red   = { reduce_color[14:10], 5'd0 };
// assign o_display_Green = { reduce_color[9:5],   5'd0 };
// assign o_display_Blue  = { reduce_color[4:0],   5'd0 };

// output the reduced pixel from sdram in region
// assign o_display_Red   = (i_H_Cont < 650 && i_H_Cont >= 300 && i_V_Cont < 400 && i_V_Cont >= 100)? { reduce_color[14:10], 5'd0 } : { 10'd500 };
// assign o_display_Green = (i_H_Cont < 650 && i_H_Cont >= 300 && i_V_Cont < 400 && i_V_Cont >= 100)? { reduce_color[9:5],   5'd0 } : { 10'd500 };
// assign o_display_Blue  = (i_H_Cont < 650 && i_H_Cont >= 300 && i_V_Cont < 400 && i_V_Cont >= 100)? { reduce_color[4:0],   5'd0 } : { 10'd500 };

// output the original pixel from sdram in region
// assign o_display_Red   = (i_H_Cont < 650 && i_H_Cont >= 300 && i_V_Cont < 400 && i_V_Cont >= 100)? { OriginRed   } : { 10'd500 };
// assign o_display_Green = (i_H_Cont < 650 && i_H_Cont >= 300 && i_V_Cont < 400 && i_V_Cont >= 100)? { OriginGreen } : { 10'd500 };
// assign o_display_Blue  = (i_H_Cont < 650 && i_H_Cont >= 300 && i_V_Cont < 400 && i_V_Cont >= 100)? { OriginBlue  } : { 10'd500 };

assign o_s_wen = s_wen_r;
assign o_s_addr = s_addr_r;
assign o_CCD_pause = ccd_pause_r;

assign reduce_color = { i_sdram_data_2[9:5], i_sdram_data_1[14:10], i_sdram_data_1[9:5] };

assign last_H_Cont_w = i_H_Cont;

parameter X_cord = 144;
parameter X_width = 640;
parameter Y_cord = 35;
parameter Y_height = 100;

always_comb begin
    state_w = state_r;
    s_addr_w = s_addr_r;
    s_wen_w = s_wen_r;
    s_data_w = s_data_r;
    OriginPicture_w = OriginPicture_r;
    ccd_pause_w = ccd_pause_r;
    cnt_w = cnt_r;
    
    case (state_r)
        S_IDLE1: begin
            if (i_H_Cont == X_cord && i_V_Cont == Y_cord) begin
                state_w = S_REC1;
                s_wen_w = 0;
                s_addr_w = 0;
                s_data_w = { 1'b0, reduce_color };
            end
        end
        
        S_REC1: begin
            if (i_H_Cont < X_cord+X_width && i_V_Cont < Y_cord+Y_height && i_H_Cont >= X_cord && i_V_Cont >= Y_cord) begin
                // if (last_H_Cont_r != i_H_Cont) begin
                    s_addr_w = s_addr_r + 1;
                    s_data_w =  { 1'b0, reduce_color };
                // end
                if (i_H_Cont == X_cord+X_width-1 && i_V_Cont == Y_cord+Y_height-1) begin
                    state_w = S_WAIT;
                    s_wen_w = 1;
                    s_addr_w = 0;
                end
            end
        end
        
        S_WAIT: begin
            if (i_H_Cont == X_cord-1 && i_V_Cont == Y_cord) begin
                state_w = S_GIVE;
                s_wen_w = 1;
                s_addr_w = 0;
            end   
        end

        S_GIVE: begin
            if (i_H_Cont < X_cord+X_width && i_V_Cont < Y_cord+Y_height && i_H_Cont >= X_cord && i_V_Cont >= Y_cord) begin
                // if (last_H_Cont_r != i_H_Cont) begin
                    s_addr_w = s_addr_r + 1;
                    OriginPicture_w = i_s_data;
                // end
                if (i_H_Cont == X_cord+X_width-1 && i_V_Cont == Y_cord+Y_height-1) begin
                    state_w = S_IDLE1;
                end
            end
            else begin
                OriginPicture_w = 16'hffff;
            end
        end
        default: begin
            
        end
    endcase
end

// integer i;
// always_comb begin
//     state_w = state_r;
//     s_addr_w = s_addr_r;
//     s_wen_w = s_wen_r;
//     s_data_w = s_data_r;
//     OriginPicture_w = OriginPicture_r;
//     ccd_pause_w = ccd_pause_r;
//     cnt_w = cnt_r;
//     // for(i = 0; i < 800*5; i = i + 1) begin
//     //     store_color_w[i] = store_color_r[i];
//     // end
//     case(state_r)
//         S_IDLE1: begin
//             if(i_H_Cont == 200 && i_V_Cont == 100) begin
//                 state_w = S_REC1;
//                 // state_w = S_STOP;
//                 s_wen_w = 0;
//                 if(last_H_Cont_r != i_H_Cont) begin
//                     s_addr_w = s_addr_r + 1;
//                 end
//                 s_data_w = {1'b0, reduce_color};
//                 // store_color_w[s_addr_r] = {1'b0, reduce_color};
//                 // s_data_w = 30 << 5;
//                 // cnt_w = 0;
//             end
//         end
//         // S_STOP: begin
//         //     cnt_w = cnt_r + 1;
//         //     if(cnt_r == 20) begin
//         //         if(s_wen_r) begin
//         //             state_w = S_GIVE;
//         //         end
//         //         else begin
//         //             state_w = S_REC1;
//         //         end
//         //     end
//         // end
//         S_REC1: begin
//             if(i_H_Cont < 600 && i_V_Cont < 200) begin // i_H_Cont >= 200 && i_V_Cont >= 100
//                 if(last_H_Cont_r != i_H_Cont) begin
//                     s_addr_w = s_addr_r + 1;
//                 end
//                 // store_color_w[s_addr_r] = {1'b0, reduce_color};
//                 // s_data_w = 30 << 5;
//                 s_data_w =  {1'b0, reduce_color};
//                 // state_w = S_STOP;
//                 if(s_addr_r == 400 * 100 - 1) begin
//                     state_w = S_WAIT;
//                     s_wen_w = 1;
//                     s_addr_w = 0;
//                 end
//             end
//         end
//         // S_IDLE2: begin
//         //     if(i_H_Cont == 0 && i_V_Cont == 0) begin
//         //         state_w = S_REC2;
//         //         s_wen_w = 0;
//         //         s_addr_w = s_addr_r + 1;
//         //         s_data_w = i_sdram_data_2;
//         //     end
//         // end
//         // S_REC2: begin
//         //     s_addr_w = s_addr_r + 1;
//         //     s_data_w = i_sdram_data_2;
//         //     if(s_addr_r == (BOUND << 1) - 1) begin
//         //         // state_w = S_WAIT;
//         //         state_w = S_GIVE;
//         //         s_wen_w = 1;
//         //         s_addr_w = 0;
//         //     end
//         // end
//         S_WAIT: begin
//             if(i_H_Cont == 198 && i_V_Cont == 100) begin
//                 state_w = S_GIVE;
//                 if(last_H_Cont_r != i_H_Cont) begin
//                     s_addr_w = s_addr_r + 1;
//                 end
//             end
//             // if(s_addr_r == (BOUND << 1)) begin
//             //     ccd_pause_w = 1'b0;
//             //     state_w = S_IDLE1;
//             // end
//         end
//         S_GIVE: begin
//             // OriginPicture_w = store_color_r[s_addr_r];
//             // state_w = S_STOP;
//             // OriginPicture_w = {OriginRed, OriginGreen, OriginBlue};
//             // state_w = S_WAIT;
//             if(i_H_Cont < 599 && i_H_Cont >= 199 && i_V_Cont < 200 && i_V_Cont >= 100) begin
//                 OriginPicture_w = i_s_data;
//                 if(last_H_Cont_r != i_H_Cont) begin
//                     s_addr_w = s_addr_r + 1;
//                 end
//                 if(s_addr_r == 400 * 100 - 1) begin
//                     s_addr_w = 0;
//                     state_w = S_IDLE1;
//                 end
//             end
//             else begin
//                 // OriginPicture_w = {1'b0, reduce_color};
//                 OriginPicture_w = 0;
//             end
//         end
//         default: begin
            
//         end
//     endcase
// end


integer j;
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state_r <= S_IDLE1;
        s_addr_r <= 0;
        s_wen_r <= 0;
        s_data_r <= 0;
        OriginPicture_r <= 0;
        ccd_pause_r <= 0;
        cnt_r <= 0;
        last_H_Cont_r <= 0;
    end
    else begin
        state_r <= state_w;
        s_addr_r <= s_addr_w;
        s_wen_r <= s_wen_w;
        s_data_r <= s_data_w;
        OriginPicture_r <= OriginPicture_w;
        ccd_pause_r <= ccd_pause_w;
        cnt_r <= cnt_w;
        last_H_Cont_r <= last_H_Cont_w;
    end
end
endmodule