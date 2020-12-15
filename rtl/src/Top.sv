module TOP(
    input           i_clk,
    input           i_rst_n,
    input   [15:0]  i_sram_data_1,
    input   [15:0]  i_sram_data_2,
    output  [9:0]   o_display_Red,
    output  [9:0]   o_display_Green,
    output  [9:0]   o_display_Blue
);

 
parameter T         =   50;
parameter fg        =   1;
parameter fs        =   0.5;
parameter fc        =   1;
parameter maxLen    =   16;
parameter minLen    =   4;
parameter brushR    =   {5'd8, 5'd4, 5'd2};

logic   [7:0]   OriginRed, OriginGreen, OriginBlue;
logic   [23:0]  OriginPicture;

assign OriginRed     = i_sram_data_1[9:2];
assign OriginGreen   = {i_sram_data_1[14:10], i_sram_data_2[14:12]};
assign OriginBlue    = i_sram_data_2[9:2];
assign OriginPicture = {OriginRed, OriginGreen, OriginBlue};

assign o_display_Red   = {OriginPicture[23:16], 2'b00};
assign o_display_Green = {OriginPicture[15:8] , 2'b00};
assign o_display_Blue  = {OriginPicture[7:0]  , 2'b00};
endmodule