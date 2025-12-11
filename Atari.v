// was Top-level module for Breakout-style paddle control on DE1-SoC
// - Instantiates paddle movement logic
// - Connects to pushbuttons (KEY) for left/right
// - Exposes paddle coordinates for VGA rendering
// old trash 
module Atari (
    input CLOCK_50,
    input [3:0] KEY,

    output [9:0] LEDR,

    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B,
    output VGA_HS,
    output VGA_VS,
    output VGA_CLK,
    output VGA_BLANK_N,
    output VGA_SYNC_N
);
    assign LEDR = 10'b0;

    wire rst = ~KEY[3];

    // ---------- VGA DRIVER ----------
    wire active_pixels;
    wire [9:0] xPixel, yPixel;
    wire vga_clk;

    vga_driver v_drv(
        .clk(CLOCK_50),
        .rst(KEY[3]),         // active LOW for vga_driver
        .vga_clk(VGA_CLK),
        .hsync(VGA_HS),
        .vsync(VGA_VS),
        .active_pixels(active_pixels),
        .xPixel(xPixel),
        .yPixel(yPixel),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N)
    );

    // ---------- MODULES ----------
    wire [9:0] paddle_x, paddle_y;
    wire [9:0] ball_x, ball_y;

    paddle_move_DE1SOC p(
        .clk(CLOCK_50),
        .rst(rst),
        .KEY(KEY),
        .paddle_x(paddle_x),
        .paddle_y(paddle_y)
    );

    ball_logic b(
        .clk(CLOCK_50),
        .rst(rst),
        .paddle_x(paddle_x),
        .paddle_y(paddle_y),
        .ball_x(ball_x),
        .ball_y(ball_y)
    );

    // ---------- BRICK STATE ----------
    reg [49:0] brick_state = 50'hFFFFFFFFFFFF;

    // ---------- PIXEL MAKER ----------
    wire [7:0] R, G, B;
    wire [23:0] col;

    pixel_maker pix(
        .clk(vga_clk),
        .video_on(active_pixels),
        .x(xPixel),
        .y(yPixel),
        .paddle_x(paddle_x),
        .paddle_y(paddle_y),
        .ball_x(ball_x),
        .ball_y(ball_y),
        .brick_state(brick_state),
        .VGA_R(R),
        .VGA_G(G),
        .VGA_B(B),
        .vga_color(col)
    );

    assign VGA_R = R;
    assign VGA_G = G;
    assign VGA_B = B;

endmodule
