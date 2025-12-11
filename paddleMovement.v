// Paddle movement for DE1-SoC VGA
// Uses KEY[0] and KEY[1] pushbuttons for left/right movement.
// Paddle stays at bottom of screen.

module paddle_move_DE1SOC #(
    parameter SCREEN_WIDTH  = 640,
    parameter SCREEN_HEIGHT = 480,
    parameter PADDLE_WIDTH  = 64,
    parameter PADDLE_HEIGHT = 8,
    parameter PADDLE_Y = 440,
    parameter SPEED = 4
)(
    input  wire clk,
    input  wire rst,
    input  wire [3:0] KEY,
    output reg  [15:0] paddle_x,
    output wire [15:0] paddle_y
);

    assign paddle_y = PADDLE_Y;

    localparam [15:0] START_X = (SCREEN_WIDTH - PADDLE_WIDTH) / 2;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            paddle_x <= START_X;
        end else begin
            // KEY[0] pressed moves left
            if (!KEY[0]) begin
                if (paddle_x > SPEED)
                    paddle_x <= paddle_x - SPEED;
                else
                    paddle_x <= 16'd0;
            end
            // KEY[1] pressed  moves right
            else if (!KEY[1]) begin
                if (paddle_x + PADDLE_WIDTH + SPEED <= SCREEN_WIDTH)
                    paddle_x <= paddle_x + SPEED;
                else
                    paddle_x <= SCREEN_WIDTH - PADDLE_WIDTH;
            end
        end
    end

endmodule

                        paddle_x <= SCREEN_WIDTH - PADDLE_WIDTH;
                end
            end
        end
    end

endmodule
