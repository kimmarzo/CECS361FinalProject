`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/19/2022 02:30:35 PM
// Design Name: 
// Module Name: UsefulFunctionsFound
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


module UsefulFunctionsFound();
//Used to animate a bar in its y-axis using the buttons
always @(*)
begin
bar_y_next = bar_y_reg; // no move
if (refr_tick)
    if(btn[1] & (bar_y_b < (MAX_Y-1-BAR_V)))
        bar_y_next = bar_y_reg + BAR_V; //move down
    else if (btn[0] & (bar_y_t > BAR_V))
        bar_y_next = bar_y_reg - BAR_V; //move up
        
// So the following can be used on pac man to move him around. He is a circle ideally
// Function used for new circle location
assign ball_x_next = (refr_tick) ? ball_x_reg+x_delta_reg : ball_x_reg;
assign ball_y_next = (refr_tick) ? ball_y_reg+y_delta_reg : ball_y_reg;
// movement of circle
always @ (*)
begin
x_delta_next = x_delta_reg;
y_delta_next = y_delta_reg;
if (ball_y_t < 1) //reached the top
    y_delta_next = BALL_V_P;
else if (ball_y_b > (MAX_Y-1))//reached the bottom
    y_delta_next = BALL_V_N;
else if (ball_x_l <= WALL_X_R) // reached a wall
    x_delta_next = BALL_V_P;
else if ((BAR_X_L <= ball_x_r) && (ball_x_r <= BAR_X_R) && (bar_y_t <= ball_y_b) && (ball_y_t <= bar_y_b)
    //reach balls hits something and bounces back
    x_delta_next = BALL_V_N;
end
endmodule

// Another VGA module found in the game book in case the original from main textbook does not work
`ifndef HVSYNC_GENERATOR_H
`define HVSYNC_GENERATOR_H

/*
Video sync generator, used to drive a simulated CRT.
To use:
- Wire the hsync and vsync signals to top level outputs
- Add a 3-bit (or more) "rgb" output to the top level
*/

module hvsync_generator(clk, reset, hsync, vsync, display_on, hpos, vpos);
  input clk;
  input reset;
  output reg hsync, vsync;
  output display_on;
  output reg [8:0] hpos;
  output reg [8:0] vpos;
  // declarations for TV-simulator sync parameters
  // horizontal constants
  parameter H_DISPLAY       = 256; // horizontal display width
  parameter H_BACK          =  23; // horizontal left border (back porch)
  parameter H_FRONT         =   7; // horizontal right border (front porch)
  parameter H_SYNC          =  23; // horizontal sync width
  // vertical constants
  parameter V_DISPLAY       = 240; // vertical display height
  parameter V_TOP           =   5; // vertical top border
  parameter V_BOTTOM        =  14; // vertical bottom border
  parameter V_SYNC          =   3; // vertical sync # lines
  // derived constants
  parameter H_SYNC_START    = H_DISPLAY + H_FRONT;
  parameter H_SYNC_END      = H_DISPLAY + H_FRONT + H_SYNC - 1;
  parameter H_MAX           = H_DISPLAY + H_BACK + H_FRONT + H_SYNC - 1;
  parameter V_SYNC_START    = V_DISPLAY + V_BOTTOM;
  parameter V_SYNC_END      = V_DISPLAY + V_BOTTOM + V_SYNC - 1;
  parameter V_MAX           = V_DISPLAY + V_TOP + V_BOTTOM + V_SYNC - 1;

  wire hmaxxed = (hpos == H_MAX) || reset;	// set when hpos is maximum
  wire vmaxxed = (vpos == V_MAX) || reset;	// set when vpos is maximum
   
  // horizontal position counter
  always @(posedge clk)
  begin
    hsync <= (hpos>=H_SYNC_START && hpos<=H_SYNC_END);
    if(hmaxxed)
      hpos <= 0;
    else
      hpos <= hpos + 1;
  end

  // vertical position counter
  always @(posedge clk)
  begin
    vsync <= (vpos>=V_SYNC_START && vpos<=V_SYNC_END);
    if(hmaxxed)
      if (vmaxxed)
        vpos <= 0;
      else
        vpos <= vpos + 1;
  end
  
  // display_on is set when beam is in "safe" visible frame
  assign display_on = (hpos<H_DISPLAY) && (vpos<V_DISPLAY);

endmodule

`endif

//test module for the 2nd vga mod

`include "hvsync_generator.v"

/*
A simple test pattern using the hvsync_generator module.
*/

module test_hvsync_top(clk, reset, hsync, vsync, rgb);

  input clk, reset;	// clock and reset signals (input)
  output hsync, vsync;	// H/V sync signals (output)
  output [2:0] rgb;	// RGB output (BGR order)
  wire display_on;	// display_on signal
  wire [8:0] hpos;	// 9-bit horizontal position
  wire [8:0] vpos;	// 9-bit vertical position

  // Include the H-V Sync Generator module and
  // wire it to inputs, outputs, and wires.
  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(0),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );

  // Assign each color bit to individual wires.
  wire r = display_on & (((hpos&7)==0) | ((vpos&7)==0));
  wire g = display_on & vpos[4];
  wire b = display_on & hpos[4];
  
  // Concatenation operator merges the red, green, and blue signals
  // into a single 3-bit vector, which is assigned to the 'rgb'
  // output. The IDE expects this value in BGR order.
  assign rgb = {b,g,r};

endmodule
