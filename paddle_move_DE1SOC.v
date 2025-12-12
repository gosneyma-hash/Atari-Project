module paddle_move_DE1SOC #(
    parameter SCREEN_WIDTH  = 640,
    parameter SCREEN_HEIGHT = 480,
    parameter PADDLE_WIDTH  = 64,
    parameter PADDLE_HEIGHT = 8,
    parameter PADDLE_Y      = 440,
    parameter SPEED         = 4,
    parameter SPEED_DIV     = 23'd1_666_666 //  50 MHz
)(
    input  wire clk,
    input  wire rst,
    input  wire [3:0] KEY,
    input  wire lose,              // freeze paddle when lose=1

    output reg  [15:0] paddle_x,
    output wire [15:0] paddle_y
);

    assign paddle_y = PADDLE_Y;
    localparam [15:0] START_X = (SCREEN_WIDTH - PADDLE_WIDTH) / 2;

    // FSM states
    localparam IDLE = 2'b00;
    localparam MOVE_LEFT = 2'b01;
    localparam MOVE_RIGHT = 2'b10;

    reg [1:0] state, next_state;

    // Divider for ~30 Hz updates
    reg [22:0] div;
    wire tick = (div == 0);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state    <= IDLE;
            paddle_x  <= START_X;
            div       <= 23'd0;
        end else if (!lose) begin
            // Only update when game is not lost
            if (div == SPEED_DIV)
                div <= 0;
            else
                div <= div + 1'b1;

            state <= next_state;

            if (tick) begin
                case (state)
                    MOVE_LEFT: begin
                        if (paddle_x > SPEED)
                            paddle_x <= paddle_x - SPEED;
                        else
                            paddle_x <= 16'd0;
                    end
                    MOVE_RIGHT: begin
                        if (paddle_x + PADDLE_WIDTH + SPEED <= SCREEN_WIDTH)
                            paddle_x <= paddle_x + SPEED;
                        else
                            paddle_x <= SCREEN_WIDTH - PADDLE_WIDTH;
                    end
                    default: begin
                        paddle_x <= paddle_x; // hold
                    end
                endcase
            end
        end
        // If lose==1, paddle_x just holds its last value
    end

    // Next state logic 
    always @(*) begin
        if (!KEY[1])
            next_state = MOVE_LEFT;
        else if (!KEY[0])
            next_state = MOVE_RIGHT;
        else
            next_state = IDLE;
    end

endmodule

