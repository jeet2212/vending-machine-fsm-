`default_nettype none

module tt_um_vending_machine (
    input  wire [7:0] ui_in,    // inputs
    output wire [7:0] uo_out,   // outputs
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // Coins
    wire coinx = ui_in[0];  // 1 rupee
    wire coiny = ui_in[1];  // 2 rupee

    // Outputs
    reg prod, change;
    assign uo_out[0] = prod;
    assign uo_out[1] = change;
    assign uo_out[7:2] = 6'b0;
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // States
    typedef enum logic [1:0] {
        S0 = 2'b00,  // idle
        S1 = 2'b01,  // 1 stored
        S2 = 2'b10   // 2 stored
    } state_t;

    state_t state, next;

    reg prod_next, change_next;

    // State update
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state  <= S0;
            prod   <= 0;
            change <= 0;
        end else begin
            state  <= next;
            prod   <= prod_next;
            change <= change_next;
        end
    end

    // FSM logic
    always @* begin
        // defaults
        next        = state;
        prod_next   = 0;
        change_next = 0;

        case (state)
            S0: begin
                if (coinx) begin
                    next = S1;
                end else if (coiny) begin
                    next = S2;
                end
            end

            S1: begin
                if (coinx) begin
                    prod_next = 1;  // 1+1=2
                    next = S0;
                end else if (coiny) begin
                    prod_next = 1;  // 1+2=3
                    next = S0;
                end
            end

            S2: begin
                if (coinx) begin
                    prod_next = 1;  // 2+1=3
                    next = S0;
                end else if (coiny) begin
                    prod_next   = 1;  // 2+2=4
                    change_next = 1;
                    next = S0;
                end else begin
                    prod_next = 1;  // single 2
                    next = S0;
                end
            end
        endcase
    end

endmodule

`default_nettype wire
