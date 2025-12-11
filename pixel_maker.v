// PIXEL MAKER TRASH I THIONK 
module pixel_maker #(
    parameter PADDLE_WIDTH  = 64,
    parameter PADDLE_HEIGHT = 8,
    parameter BALL_SIZE     = 6,
    parameter BRICK_ROWS    = 5,
    parameter BRICK_COLS    = 10,
    parameter BRICK_WIDTH   = 60,
    parameter BRICK_HEIGHT  = 18
)(
    input clk,
    input video_on,
    input [9:0] x,
    input [9:0] y,

    input [9:0] paddle_x,
    input [9:0] paddle_y,

    input [9:0] ball_x,
    input [9:0] ball_y,

    input [BRICK_ROWS*BRICK_COLS-1:0] brick_state,

    output reg [7:0] VGA_R,
    output reg [7:0] VGA_G,
    output reg [7:0] VGA_B,
    output reg [23:0] vga_color
);

    integer r, c;
    integer bx, by;

    always @(*) begin
        if (!video_on) begin
            vga_color = 24'h000000;
        end

        else if (x >= paddle_x && x < paddle_x + PADDLE_WIDTH &&
                 y >= paddle_y && y < paddle_y + PADDLE_HEIGHT) begin
            vga_color = 24'h00FF00;
        end

        else if (x >= ball_x && x < ball_x + BALL_SIZE &&
                 y >= ball_y && y < ball_y + BALL_SIZE) begin
            vga_color = 24'hFF0000;
        end

        else begin
            vga_color = 24'h000000;

            for (r = 0; r < BRICK_ROWS; r = r + 1) begin
                for (c = 0; c < BRICK_COLS; c = c + 1) begin
                    if (brick_state[r*BRICK_COLS + c]) begin
                        bx = 20 + c * BRICK_WIDTH;
                        by = 40 + r * BRICK_HEIGHT;

                        if (x >= bx && x < bx + BRICK_WIDTH &&
                            y >= by && y < by + BRICK_HEIGHT)
                            vga_color = 24'h3333FF;
                    end
                end
            end
        end

        {VGA_R, VGA_G, VGA_B} = vga_color;
    end
endmodule

