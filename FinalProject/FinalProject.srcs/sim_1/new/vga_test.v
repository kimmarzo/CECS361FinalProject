`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/18/2022 09:42:33 PM
// Design Name: 
// Module Name: vga_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// Used to see if I fully coded the vga_sync correctly


module vga_test
    (
        input wire clk,reset,
        input wire [2:0] sw,
        output wire hsync, vsync,
        output wire [2:0] rgb
    );
    
    //signal declaration
    reg [2:0] rgb_reg;
    wire video_on;
    
    //instantiate vga sync circuit
    vga_sync vsync_unit (.clk(clk), .reset(reset), .hsync(hsync), .vsync(vsync), .video_on(video_on), .p_tick(), .pixel_x(), .pixel_y());
    //rgb buffer
    always @ (posedge clk, posedge reset)
        if(reset)
            rgb_reg <= 0;
        else
            rgb_reg <= sw;
        //output
        assign rgb = (video_on) ? rgb_reg : 3'b0;
endmodule
