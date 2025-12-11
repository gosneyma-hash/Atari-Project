   module ball_logic #(
    parameter SCREEN_WIDTH  = 640,
    parameter SCREEN_HEIGHT = 480,
    parameter BALL_SIZE     = 6,
    parameter PADDLE_WIDTH  = 64,
    parameter PADDLE_HEIGHT = 8,
    parameter SPEED_DIV     = 23'd1_000_000  // ~50 Hz
)(
    input  wire       clk,
    input  wire       rst,
    input  wire [9:0] paddle_x,
    input  wire [9:0] paddle_y,
    input  wire       brick_hit,
    input  wire       hit_from_side,
	 input wire all_bricks_gone,
    output reg  [9:0] ball_x,
    output reg  [9:0] ball_y,
    output reg  signed [2:0] ball_vx,
    output reg  signed [2:0] ball_vy,
    output reg lose,
	 output reg win
);


    reg flip_vx;
	 reg flip_vy;
	

    // Divider
    reg [22:0] div;
    wire tick = (div == SPEED_DIV);
    
    // Predicted next position 
    reg signed [10:0] next_x, next_y;
    
    // Temporary variable for paddle hit position
    integer hit_pos;
    
    // Initial positions
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ball_x <= SCREEN_WIDTH/2;
            ball_y <= 440;
            ball_vx <= 2;
            ball_vy <= -2;  // negative = moving up
            div <= 0;
            lose <= 0;
				win <= 0;
				flip_vx = 0;
				flip_vy = 0;
        end else begin
            if (div == SPEED_DIV)
                div <= 0;
            else
                div <= div + 1'b1;
				if(all_bricks_gone && !win) begin
					win <= 1;
					ball_vx <= 0;
					ball_vy <= 0;
					end
                
            if (tick && !lose && !win) begin
                flip_vx = 0; 
					 flip_vy = 0;
					 
					 
					 // Calculate next position BEFORE updating
                next_x = ball_x - ball_vx;
                next_y = ball_y - ball_vy;
                
                // Default: update position normally
                ball_x <= next_x;
                ball_y <= next_y;
                
                // Check PREDICTED paddle collision first
                // This checks if the ball WILL hit the paddle on this move
                if (ball_vy > 0 &&  // ball moving down
                    next_y + BALL_SIZE >= paddle_y &&
                    ball_y < paddle_y &&  // wasn't already past paddle
                    next_x + BALL_SIZE > paddle_x &&
                    next_x < paddle_x + PADDLE_WIDTH) 
                begin
                    // Bounce off paddle
						  flip_vy = 1;
                    
                    ball_y  <= paddle_y - BALL_SIZE;  // Position just above paddle
                    
                    // Adjust x-velocity based on where ball hits paddle
                    hit_pos = (next_x + BALL_SIZE/2) - paddle_x;
                    if (hit_pos < PADDLE_WIDTH/3)
                        ball_vx <= -2;  // Hit left side, bounce left
                    else if (hit_pos > 2*PADDLE_WIDTH/3)
                        ball_vx <= 2;   // Hit right side, bounce right
                    else
                        ball_vx <= (ball_vx > 0) ? 1 : -1;  // Center hit, slight angle
                end
                
                // Left wall collision
                else if (next_x < 0) begin
						  flip_vx = 1;
                    ball_x  <= 0;
                    
                end 
                // Right wall collision
                else if (next_x > SCREEN_WIDTH - BALL_SIZE) begin
                    ball_x  <= SCREEN_WIDTH - BALL_SIZE;
                    flip_vx = 1;
                end
                
                // Top wall collision
                if (next_y < 0) begin
                    ball_y  <= 0;
                    flip_vy = 1;
                end
                
                // Brick collision 
                // Handle them AFTER position update to avoid conflicts
                if (brick_hit) begin
                    if (hit_from_side) begin
                        flip_vx = 1;  // Flip x velocity for side hit
                    end else begin
                        flip_vy = 1;  // Flip y velocity for top/bottom hit
                    end
                end
					 
					 
					 if(flip_vx) begin
					 ball_vx <= -ball_vx;
					 end  

					  if(flip_vy) begin
					 ball_vy <= -ball_vy;
					 end 
					 
					 
                
                // Lose condition 
                if (next_y > SCREEN_HEIGHT) begin
                    lose    <= 1;
                    ball_vx <= 0;
                    ball_vy <= 0;
                end
            end
        end
    end
endmodule


 

