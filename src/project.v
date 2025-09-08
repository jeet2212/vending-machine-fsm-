module tt_um_vending_machine (
    input  wire [7:0] ui_in,    // dedicated inputs
    output wire [7:0] uo_out,   // dedicated outputs
    input  wire [7:0] uio_in,   // IOs: input path
    output wire [7:0] uio_out,  // IOs: output path
    output wire [7:0] uio_oe,   // IOs: enable (1=output, 0=input)
    input  wire       ena,      // always 1 when design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset (active low)
);

    // ----------------------------------------------------
    // Signal mapping
    // ----------------------------------------------------
    wire coinx = ui_in[0];   // 1 rupee
    wire coiny = ui_in[1];   // 2 rupees

    reg prod, change;

    assign uo_out[0] = prod;    // product output
    assign uo_out[1] = change;  // change output
    assign uo_out[7:2] = 6'b0;  // unused outputs

    // No bidirectional IO used
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // ----------------------------------------------------
    // FSM definition
    // ----------------------------------------------------
    typedef enum logic [1:0] {S0, S1, S2, S3} state_t;
    state_t state, next;

    // Sequential state update
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S0;
        else if (ena)
            state <= next;
    end

    // Next-state and output logic
    always @(*) begin
        prod   = 0;
        change = 0;
        next   = state;

        case (state)
            S0: begin
                if (coinx) next = S1;       // 1 rupee
                else if (coiny) next = S2;  // 2 rupees
            end
            S1: begin
                if (coinx) begin
                    prod = 1;               // vend at 2 rupees
                    next = S0;
                end
                else if (coiny) begin
                    prod = 1;               // vend at 3 rupees
                    next = S0;
                end
            end
            S2: begin
                if (coinx) begin
                    prod = 1;               // vend at 3 rupees
                    next = S0;
                end
                else if (coiny) begin
                    prod   = 1;             // vend at 4 rupees
                    change = 1;             // return change
                    next   = S0;
                end
            end
            S3: begin
                prod   = 1;   // vend
                change = 1;   // return change
                next   = S0;
            end
        endcase
    end

endmodule
