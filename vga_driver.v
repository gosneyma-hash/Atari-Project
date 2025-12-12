/////////////////////////////////////////////////////////////////////////////////////
// Adaption by Peter Jamieson for DE2-115 from:
// 640x480 from https://projectf.io/posts/fpga-graphics/
/////////////////////////////////////////////////////////////////////////////////////        // DONT TOUCH
// DONT TOUCH
// DONT TOUCH
// DONT TOUCH
// DONT TOUCH driver
            
module vga_driver(

input clk,
input rst,

output reg vga_clk,

output reg hsync, // horizontal sync
output reg vsync, // vertical sync

output reg active_pixels, // is on when we're in the active draw space

output reg [9:0]xPixel, // current x
output reg [9:0]yPixel, // current y - 10 bits = 1024 ... a little bit more than we need

output reg VGA_BLANK_N,	//	VGA BLANK 

output reg VGA_SYNC_N		//	VGA SYNC
);



// horizontal timings
parameter HA_END = 10'd639;           // end of active pixels
parameter HS_STA = HA_END + 16;   // sync starts after front porch
parameter HS_END = HS_STA + 96;   // sync ends
parameter WIDTH   = 10'd799;           // last pixel on line 

// vertical timings
parameter VA_END = 10'd479;           // end of active pixels
parameter VS_STA = VA_END + 10;   // sync starts after front porch
parameter VS_END = VS_STA + 2;    // sync ends
parameter HEIGHT = 10'd524;           // last line on screen

always @(*)
begin 
	hsync = ~((xPixel >= HS_STA) && (xPixel < HS_END));
	vsync = ~((yPixel >= VS_STA) && (yPixel < VS_END));
	active_pixels = (xPixel <= HA_END && yPixel <= VA_END); 
	
	VGA_BLANK_N = active_pixels;
	VGA_SYNC_N = 1'b1;
end

always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		vga_clk <= 1'b0;
		xPixel <= 10'd0;
		yPixel <= 10'd0;
	end
	else
	begin
		vga_clk = ~vga_clk; // clock divider
		
		if (vga_clk == 1'b1)
			if(xPixel == WIDTH)
			begin
				xPixel <= 10'd0;
				if(yPixel == HEIGHT)
				begin
					yPixel<=10'd0;
				end
				else
				begin
					yPixel <= yPixel+1'b1;
				end
			end
			else
			begin
				xPixel <= xPixel+1'b1;
			end
			
			
		end
end

endmodule

