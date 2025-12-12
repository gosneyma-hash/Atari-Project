
module vga_driver_memory (                                        
    input wire CLOCK_50,
    output wire [6:0] HEX0,
    output wire [6:0] HEX1,
    output wire [6:0] HEX2,
    output wire [6:0] HEX3,
    input wire [3:0] KEY,
    output wire [9:0] LEDR,
    input wire [9:0] SW,
    output wire VGA_BLANK_N,
    output reg [7:0] VGA_B,
    output wire VGA_CLK,
    output wire VGA_HS,
    output reg [7:0] VGA_G,
    output reg [7:0] VGA_R,
    output wire VGA_SYNC_N,
    output wire VGA_VS
);

    // ... (parameters and other declarations stay the same)
    
    parameter SCREEN_WIDTH  = 640;
    parameter SCREEN_HEIGHT = 480;
    parameter BALL_SIZE     = 6;
    parameter PADDLE_WIDTH  = 64;
    parameter PADDLE_HEIGHT = 8;
    parameter BRICK_ROWS    = 5;
    parameter BRICK_COLS    = 10;
    parameter BRICK_WIDTH   = 64;
    parameter BRICK_HEIGHT  = 16;

    assign HEX0 = 7'h00;
    assign HEX1 = 7'h00;
    assign HEX2 = 7'h00;
    assign HEX3 = 7'h00;

    wire clk = CLOCK_50;
    wire rst = SW[1];
    wire active_pixels;
    wire [9:0] x, y;
    wire [9:0] ball_x, ball_y;
    wire [15:0] paddle_x, paddle_y;
    wire [BRICK_ROWS*BRICK_COLS-1:0] brick_state;
    wire lose;
	 wire win;
    
    // Declare the missing signals
    wire signed [2:0] ball_vx, ball_vy;
    wire brick_hit, hit_from_side;
	 wire all_bricks_gone = (brick_state == 50'd1); // 50

    vga_driver the_vga (
        .clk(clk),
        .rst(1'b1),
        .vga_clk(VGA_CLK),
        .hsync(VGA_HS),
        .vsync(VGA_VS),
        .active_pixels(active_pixels),
        .xPixel(x),
        .yPixel(y),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N)
    );


    paddle_move_DE1SOC #(
        .SCREEN_WIDTH(SCREEN_WIDTH),
        .SCREEN_HEIGHT(SCREEN_HEIGHT),
        .PADDLE_WIDTH(PADDLE_WIDTH),
        .PADDLE_HEIGHT(PADDLE_HEIGHT),
        .PADDLE_Y(440),
        .SPEED(4)
    ) paddle (
        .clk(clk),
        .rst(rst),
        .KEY(KEY),
        .paddle_x(paddle_x),
        .paddle_y(paddle_y),
        .lose(lose)
    );


    ball_logic #(
        .SCREEN_WIDTH(SCREEN_WIDTH),
        .SCREEN_HEIGHT(SCREEN_HEIGHT),
        .BALL_SIZE(BALL_SIZE),
        .PADDLE_WIDTH(PADDLE_WIDTH),
        .PADDLE_HEIGHT(PADDLE_HEIGHT)
    )(
        .clk(clk),
        .rst(rst),
        .paddle_x(paddle_x[9:0]),
        .paddle_y(paddle_y[9:0]),
        .brick_hit(brick_hit),          
        .hit_from_side(hit_from_side),  
		  .all_bricks_gone(all_bricks_gone),
        .ball_x(ball_x),
        .ball_y(ball_y),
        .ball_vx(ball_vx),              
        .ball_vy(ball_vy),              
        .lose(lose),
		  .win(win)
    );

    brick_logic #(
        .SCREEN_WIDTH(SCREEN_WIDTH),
        .SCREEN_HEIGHT(SCREEN_HEIGHT),
        .BRICK_ROWS(BRICK_ROWS),
        .BRICK_COLS(BRICK_COLS),
        .BRICK_WIDTH(BRICK_WIDTH),
        .BRICK_HEIGHT(BRICK_HEIGHT),
        .BALL_SIZE(BALL_SIZE)
    ) bricks (
        .clk(clk),
        .rst(rst),
        .ball_x(ball_x),
        .ball_y(ball_y),
        .ball_vx(ball_vx),              
        .ball_vy(ball_vy),             
        .brick_state(brick_state),
        .brick_hit(brick_hit),         
        .hit_from_side(hit_from_side)   
    );



    // Color output logic
    reg [23:0] vga_color;
   
    // Brick detection signals for each brick
    wire in_brick_00 = brick_state[0]  && (x >= 10'd0)   && (x < 10'd64)  && (y >= 10'd0)  && (y < 10'd16);
    wire in_brick_01 = brick_state[1]  && (x >= 10'd64)  && (x < 10'd128) && (y >= 10'd0)  && (y < 10'd16);
    wire in_brick_02 = brick_state[2]  && (x >= 10'd128) && (x < 10'd192) && (y >= 10'd0)  && (y < 10'd16);
    wire in_brick_03 = brick_state[3]  && (x >= 10'd192) && (x < 10'd256) && (y >= 10'd0)  && (y < 10'd16);
    wire in_brick_04 = brick_state[4]  && (x >= 10'd256) && (x < 10'd320) && (y >= 10'd0)  && (y < 10'd16);
    wire in_brick_05 = brick_state[5]  && (x >= 10'd320) && (x < 10'd384) && (y >= 10'd0)  && (y < 10'd16);
    wire in_brick_06 = brick_state[6]  && (x >= 10'd384) && (x < 10'd448) && (y >= 10'd0)  && (y < 10'd16);
    wire in_brick_07 = brick_state[7]  && (x >= 10'd448) && (x < 10'd512) && (y >= 10'd0)  && (y < 10'd16);
    wire in_brick_08 = brick_state[8]  && (x >= 10'd512) && (x < 10'd576) && (y >= 10'd0)  && (y < 10'd16);
    wire in_brick_09 = brick_state[9]  && (x >= 10'd576) && (x < 10'd640) && (y >= 10'd0)  && (y < 10'd16);
   
    wire in_brick_10 = brick_state[10] && (x >= 10'd0)   && (x < 10'd64)  && (y >= 10'd16) && (y < 10'd32);
    wire in_brick_11 = brick_state[11] && (x >= 10'd64)  && (x < 10'd128) && (y >= 10'd16) && (y < 10'd32);
    wire in_brick_12 = brick_state[12] && (x >= 10'd128) && (x < 10'd192) && (y >= 10'd16) && (y < 10'd32);
    wire in_brick_13 = brick_state[13] && (x >= 10'd192) && (x < 10'd256) && (y >= 10'd16) && (y < 10'd32);
    wire in_brick_14 = brick_state[14] && (x >= 10'd256) && (x < 10'd320) && (y >= 10'd16) && (y < 10'd32);
    wire in_brick_15 = brick_state[15] && (x >= 10'd320) && (x < 10'd384) && (y >= 10'd16) && (y < 10'd32);
    wire in_brick_16 = brick_state[16] && (x >= 10'd384) && (x < 10'd448) && (y >= 10'd16) && (y < 10'd32);
    wire in_brick_17 = brick_state[17] && (x >= 10'd448) && (x < 10'd512) && (y >= 10'd16) && (y < 10'd32);
    wire in_brick_18 = brick_state[18] && (x >= 10'd512) && (x < 10'd576) && (y >= 10'd16) && (y < 10'd32);
    wire in_brick_19 = brick_state[19] && (x >= 10'd576) && (x < 10'd640) && (y >= 10'd16) && (y < 10'd32);
   
    wire in_brick_20 = brick_state[20] && (x >= 10'd0)   && (x < 10'd64)  && (y >= 10'd32) && (y < 10'd48);
    wire in_brick_21 = brick_state[21] && (x >= 10'd64)  && (x < 10'd128) && (y >= 10'd32) && (y < 10'd48);
    wire in_brick_22 = brick_state[22] && (x >= 10'd128) && (x < 10'd192) && (y >= 10'd32) && (y < 10'd48);
    wire in_brick_23 = brick_state[23] && (x >= 10'd192) && (x < 10'd256) && (y >= 10'd32) && (y < 10'd48);
    wire in_brick_24 = brick_state[24] && (x >= 10'd256) && (x < 10'd320) && (y >= 10'd32) && (y < 10'd48);
    wire in_brick_25 = brick_state[25] && (x >= 10'd320) && (x < 10'd384) && (y >= 10'd32) && (y < 10'd48);
    wire in_brick_26 = brick_state[26] && (x >= 10'd384) && (x < 10'd448) && (y >= 10'd32) && (y < 10'd48);
    wire in_brick_27 = brick_state[27] && (x >= 10'd448) && (x < 10'd512) && (y >= 10'd32) && (y < 10'd48);
    wire in_brick_28 = brick_state[28] && (x >= 10'd512) && (x < 10'd576) && (y >= 10'd32) && (y < 10'd48);
    wire in_brick_29 = brick_state[29] && (x >= 10'd576) && (x < 10'd640) && (y >= 10'd32) && (y < 10'd48);
   
    wire in_brick_30 = brick_state[30] && (x >= 10'd0)   && (x < 10'd64)  && (y >= 10'd48) && (y < 10'd64);
    wire in_brick_31 = brick_state[31] && (x >= 10'd64)  && (x < 10'd128) && (y >= 10'd48) && (y < 10'd64);
    wire in_brick_32 = brick_state[32] && (x >= 10'd128) && (x < 10'd192) && (y >= 10'd48) && (y < 10'd64);
    wire in_brick_33 = brick_state[33] && (x >= 10'd192) && (x < 10'd256) && (y >= 10'd48) && (y < 10'd64);
    wire in_brick_34 = brick_state[34] && (x >= 10'd256) && (x < 10'd320) && (y >= 10'd48) && (y < 10'd64);
    wire in_brick_35 = brick_state[35] && (x >= 10'd320) && (x < 10'd384) && (y >= 10'd48) && (y < 10'd64);
    wire in_brick_36 = brick_state[36] && (x >= 10'd384) && (x < 10'd448) && (y >= 10'd48) && (y < 10'd64);
    wire in_brick_37 = brick_state[37] && (x >= 10'd448) && (x < 10'd512) && (y >= 10'd48) && (y < 10'd64);
    wire in_brick_38 = brick_state[38] && (x >= 10'd512) && (x < 10'd576) && (y >= 10'd48) && (y < 10'd64);
    wire in_brick_39 = brick_state[39] && (x >= 10'd576) && (x < 10'd640) && (y >= 10'd48) && (y < 10'd64);
   
    wire in_brick_40 = brick_state[40] && (x >= 10'd0)   && (x < 10'd64)  && (y >= 10'd64) && (y < 10'd80);
    wire in_brick_41 = brick_state[41] && (x >= 10'd64)  && (x < 10'd128) && (y >= 10'd64) && (y < 10'd80);
    wire in_brick_42 = brick_state[42] && (x >= 10'd128) && (x < 10'd192) && (y >= 10'd64) && (y < 10'd80);
    wire in_brick_43 = brick_state[43] && (x >= 10'd192) && (x < 10'd256) && (y >= 10'd64) && (y < 10'd80);
    wire in_brick_44 = brick_state[44] && (x >= 10'd256) && (x < 10'd320) && (y >= 10'd64) && (y < 10'd80);
    wire in_brick_45 = brick_state[45] && (x >= 10'd320) && (x < 10'd384) && (y >= 10'd64) && (y < 10'd80);
    wire in_brick_46 = brick_state[46] && (x >= 10'd384) && (x < 10'd448) && (y >= 10'd64) && (y < 10'd80);
    wire in_brick_47 = brick_state[47] && (x >= 10'd448) && (x < 10'd512) && (y >= 10'd64) && (y < 10'd80);
    wire in_brick_48 = brick_state[48] && (x >= 10'd512) && (x < 10'd576) && (y >= 10'd64) && (y < 10'd80);
    wire in_brick_49 = brick_state[49] && (x >= 10'd576) && (x < 10'd640) && (y >= 10'd64) && (y < 10'd80);
   
   //  Combine into row signals
   wire in_row0 = in_brick_00 | in_brick_01 | in_brick_02 | in_brick_03 | in_brick_04 |
               in_brick_05 | in_brick_06 | in_brick_07 | in_brick_08 | in_brick_09;


	wire in_row1 = in_brick_10 | in_brick_11 | in_brick_12 | in_brick_13 | in_brick_14 |
               in_brick_15 | in_brick_16 | in_brick_17 | in_brick_18 | in_brick_19;


	wire in_row2 = in_brick_20 | in_brick_21 | in_brick_22 | in_brick_23 | in_brick_24 |
               in_brick_25 | in_brick_26 | in_brick_27 | in_brick_28 | in_brick_29;


	wire in_row3 = in_brick_30 | in_brick_31 | in_brick_32 | in_brick_33 | in_brick_34 |
               in_brick_35 | in_brick_36 | in_brick_37 | in_brick_38 | in_brick_39;


	wire in_row4 = in_brick_40 | in_brick_41 | in_brick_42 | in_brick_43 | in_brick_44 |
               in_brick_45 | in_brick_46 | in_brick_47 | in_brick_48 | in_brick_49;



    //Paddle and ball detection
    wire in_paddle = (x >= paddle_x) && (x < paddle_x + PADDLE_WIDTH) && (y >= paddle_y) && (y < paddle_y + PADDLE_HEIGHT);
    wire in_ball = (x >= ball_x) && (x < ball_x + BALL_SIZE) && (y >= ball_y) && (y < ball_y + BALL_SIZE);


    // Color assignment with priority
    always @(*) begin
        if (!active_pixels) begin
            vga_color = 24'h000000;  // Black during blanking
        end else if (in_ball) begin
            vga_color = 24'hFFFFFF;  // White ball
        end else if (in_paddle) begin
            vga_color = 24'hFFFFFF;  // White paddle
        end else if (in_row0) begin
            vga_color = 24'hFF0000;  // TOP ROW Red row
        end else if (in_row1) begin
            vga_color = 24'hFF8800;  // ONE BELOW TOP ROW Orange row
        end else if (in_row2) begin
           vga_color = 24'hFFFF00;  //  MIDDLE ROW Yellow row
        end else if (in_row3) begin
            vga_color = 24'h00FF00;  // ONE ABOVE THE BOTTOM Green row
        end else if (in_row4) begin
            vga_color = 24'h0088FF;  // BOTTOM ROW Blue row
		  end else if(win) begin 
				vga_color = 24'h00FF00;
				
		  end else if (lose) begin
				
		      vga_color = 24'hFF0000;  //  lose red
		  
        end else begin
            vga_color = 24'h001040;  // Dark blue BAKCGORUNd
        end
    end


    // Split color into RGB channels
    always @(*) begin
        VGA_R = vga_color[23:16];
        VGA_G = vga_color[15:8];
        VGA_B = vga_color[7:0];
    end


    // LED output show remaining bricks
    assign LEDR[9:0] = brick_state[9:0];
	 
	 
	//	assign LEDR[9:0] = paddle_x[9:0];

endmodule

