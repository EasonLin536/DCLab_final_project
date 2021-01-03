module ColorDelay(
    input           i_clk,
    input           i_rst_n,
    input   [15:0]  i_data,
    input   [15:0]  i_s_data,
    output  [15:0]  o_data,
    output  [15:0]  o_s_data,
    output          o_s_wen,
    output  [19:0]  o_s_addr
);

parameter BUFFER_LEN = 800*10 +44;

logic   [2:0]   state_w, state_r;
logic           s_wen_w, s_wen_r;
logic   [19:0]  s_addr_w, s_addr_r;
logic   [15:0]  store_data_w, store_data_r;
logic   [15:0]  load_data_w, load_data_r;

assign o_data = load_data_r;
assign o_s_data = store_data_r;
assign o_s_wen = s_wen_r;
assign o_s_addr = s_addr_r;
typedef enum {
    S_IDLE,
    S_STORE,
    S_WAIT1,
    S_LOAD,
    S_WAIT2
} ColorDelayState;

always_comb begin
    state_w = state_r;
    s_wen_w = s_wen_r;
    s_addr_w = s_addr_r;
    store_data_w = store_data_r;
    load_data_w = load_data_r;
    case(state_r)
        S_IDLE: begin
            state_w = S_STORE;
            store_data_w = i_data;
        end
        S_STORE: begin
            state_w = S_WAIT1;
            s_wen_w = 1;
            if(s_addr_r == BUFFER_LEN) begin
                s_addr_w = 0;
            end
            else begin
                s_addr_w = s_addr_r + 1;
            end
        end
        S_WAIT1: begin
            state_w = S_LOAD;
        end
        S_LOAD: begin
            state_w = S_WAIT2;
            s_wen_w = 0;
            load_data_w = i_s_data;
        end
        S_WAIT2: begin
            state_w = S_STORE;
            store_data_w = i_data;
        end
        default: begin
            
        end
    endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state_r <= S_IDLE;
        s_wen_r <= 0;
        s_addr_r <= 0;
        store_data_r <= 0;
        load_data_r <= 0;
    end
    else begin
        state_r <= state_w;
        s_wen_r <= s_wen_w;
        s_addr_r <= s_addr_w;
        store_data_r <= store_data_w;
        load_data_r <= load_data_w;
    end
end

endmodule