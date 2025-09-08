`default_nettype none

module tt_um_vending_machine (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
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

    // FSM states
    typedef enum logic [1:0] {
        S0 = 2'b00,  // idle
        S1 = 2'b01   // 1 stored
    } state_t;

    state_t state, next;
    reg prod_next, change_next;
    reg last_two;  // remembers if last vend was from a 2

    // State update
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= S0;
            prod     <= 0;
            change   <= 0;
            last_two <= 0;
        end else begin
            state    <= next;
            prod     <= prod_next;
            change   <= change_next;
            if (prod_next && coiny) begin
                last_two <= 1;  // just vended from a 2
            end else begin
                last_two <= 0;
            end
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
                    next = S1;             // store 1
                end else if (coiny) begin
                    prod_next = 1;         // immediate vend for 2
                    next = S0;
                end
            end

            S1: begin
                if (coinx) begin
                    prod_next = 1;         // 1+1
                    next = S0;
                end else if (coiny) begin
                    prod_next = 1;         // 1+2
                    next = S0;
                end
            end
        endcase

        // Handle 2+2 → product + change
        if (last_two && coiny) begin
            prod_next   = 1;
            change_next = 1;
            next        = S0;
        end
    end

endmodule

`default_nettype wire
