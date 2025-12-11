module brick_logic #(
    parameter SCREEN_WIDTH  = 640,
    parameter SCREEN_HEIGHT = 480,
    parameter BRICK_ROWS    = 5,
    parameter BRICK_COLS    = 10,
    parameter BRICK_WIDTH   = 64,
    parameter BRICK_HEIGHT  = 16,
    parameter BALL_SIZE     = 6
)(
    input  wire clk,
    input  wire rst,
    input  wire [9:0]  ball_x,
    input  wire [9:0]  ball_y,
    input  wire signed [2:0] ball_vx,
    input  wire signed [2:0] ball_vy,
    output reg  [BRICK_ROWS*BRICK_COLS-1:0] brick_state,
    output reg brick_hit,
    output reg hit_from_side
);

    integer row, col;
    integer bx, by;
    reg signed [10:0] next_ball_x, next_ball_y;
    reg [9:0] ball_center_x, ball_center_y;
    reg [9:0] brick_center_x, brick_center_y;
    reg signed [10:0] dx, dy;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            brick_state <= {BRICK_ROWS*BRICK_COLS{1'b1}};
            brick_hit <= 0;
            hit_from_side <= 0;
        end else begin
            brick_hit <= 0;
            hit_from_side <= 0;
            
            // Predict next ball position
            next_ball_x = ball_x + ball_vx;
            next_ball_y = ball_y + ball_vy;
            
            // Calculate ball center 
            ball_center_x = next_ball_x + (BALL_SIZE / 2);
            ball_center_y = next_ball_y + (BALL_SIZE / 2);

            for (row = 0; row < BRICK_ROWS; row = row + 1) begin
                for (col = 0; col < BRICK_COLS; col = col + 1) begin
                    if (brick_state[row*BRICK_COLS + col] && !brick_hit) begin
                        bx = col * BRICK_WIDTH;
                        by = row * BRICK_HEIGHT;

                        // Check if NEXT ball position will overlap brick
                        if ((next_ball_x < bx + BRICK_WIDTH) && 
                            (next_ball_x + BALL_SIZE > bx) &&
                            (next_ball_y < by + BRICK_HEIGHT) && 
                            (next_ball_y + BALL_SIZE > by)) begin
                            
                            // Destroy brick
                            brick_state[row*BRICK_COLS + col] <= 0;
                            brick_hit <= 1;
                            
                            // Calculate brick center
                            brick_center_x = bx + (BRICK_WIDTH / 2);
                            brick_center_y = by + (BRICK_HEIGHT / 2);
                            
                            // Calculate distance from ball center to brick center
                            dx = ball_center_x - brick_center_x;
                            dy = ball_center_y - brick_center_y;
                            
                            // Determine hit direction
                            if ((dx < 0 ? -dx : dx) * BRICK_HEIGHT > 
                                (dy < 0 ? -dy : dy) * BRICK_WIDTH) begin
                                hit_from_side <= 1;
                            end else begin
                                hit_from_side <= 0;
                            end
                        end
                    end
                end
            end
        end
    end
endmodule
