module vending_machine(
  input clk,
  input rst,
  input coinx,
  input coiny,
  output reg prod,
  output reg change
);

  // States
  localparam IDLE       = 2'b00;
  localparam ONE_RUPEE  = 2'b01;
  localparam TWO_RUPEE  = 2'b10;

  reg [1:0] state;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      state  <= IDLE;
      prod   <= 0;
      change <= 0;
    end else begin
      // default outputs low every cycle
      prod   <= 0;
      change <= 0;

      case (state)
        IDLE: begin
          if (coinx && !coiny) begin
            state <= ONE_RUPEE;
          end else if (!coinx && coiny) begin
            state <= TWO_RUPEE;
          end
        end

        ONE_RUPEE: begin
          if (coinx && !coiny) begin
            state <= TWO_RUPEE;
          end else if (!coinx && !coiny) begin
            state <= IDLE;
            prod  <= 1;   // dispense product
          end
        end

        TWO_RUPEE: begin
          if (!coinx && coiny) begin
            state  <= ONE_RUPEE;
            change <= 1; // return change
          end else if (!coinx && !coiny) begin
            state <= IDLE;
            prod  <= 1;   // dispense product
          end
        end
      endcase
    end
  end

endmodule
