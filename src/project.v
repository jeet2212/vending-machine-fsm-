/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_vending_machine (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: unused
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input wire ena,
    input  wire clk,            // clock
    input  wire rst_n           // async reset (active low)
);

    // Map TinyTapeout signals to vending machine
    wire coinx  = ui_in[0];
    wire coiny  = ui_in[1];
    wire rst    = ~rst_n;       // active-high reset for FSM

    wire prod_sig;
    wire change_sig;

    // Instantiate your vending machine FSM
    vending_machine vm_inst (
        .clk(clk),
        .rst(rst),
        .coinx(coinx),
        .coiny(coiny),
        .prod(prod_sig),
        .change(change_sig)
    );

    // Drive TinyTapeout outputs
    assign uo_out[0] = prod_sig;
    assign uo_out[1] = change_sig;
    assign uo_out[7:2] = 6'b0;   // unused

    // Bidirectional IOs unused
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

endmodule
