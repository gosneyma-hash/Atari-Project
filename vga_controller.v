  module vga_controller(
    input clk,
    input rst,

    output reg vga_clk,
    output reg hsync,
    output reg vsync,

    output reg active_pixels,

    output reg [9:0] xPixel,
    output reg [9:0] yPixel,

    output reg VGA_BLANK_N,
    output reg VGA_SYNC_N
);
    // parameters
    parameter HA_END = 10'd639;
    parameter HS_STA = HA_END + 16;
    parameter HS_END = HS_STA + 96;
    parameter WIDTH  = 10'd799;

    parameter VA_END = 10'd479;
    parameter VS_STA = VA_END + 10;
    parameter VS_END = VS_STA + 2;
    parameter HEIGHT = 10'd524;

    always @(*) begin
        hsync         = ~((xPixel >= HS_STA) && (xPixel < HS_END));
        vsync         = ~((yPixel >= VS_STA) && (yPixel < VS_END));
        active_pixels = (xPixel <= HA_END && yPixel <= VA_END);

        VGA_BLANK_N = active_pixels;
        VGA_SYNC_N  = 1'b1;
    end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            vga_clk <= 0;
            xPixel  <= 0;
            yPixel  <= 0;
        end else begin
            vga_clk = ~vga_clk;

            if (vga_clk) begin
                if (xPixel == WIDTH) begin
                    xPixel <= 0;

                    if (yPixel == HEIGHT)
                        yPixel <= 0;
                    else
                        yPixel <= yPixel + 1;
                end else begin
                    xPixel <= xPixel + 1;
                end
            end
        end
    end
endmodule