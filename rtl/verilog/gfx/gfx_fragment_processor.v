/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

PER-PIXEL COLORING MODULE

 This file is part of orgfx.

 orgfx is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version. 

 orgfx is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with orgfx.  If not, see <http://www.gnu.org/licenses/>.

*/

/*
This module adds color to the pixel generated by the rasterizer. It can either draw a flat color (using pixel_color_i) or
colors from a texture by using the u and v coordinates generated by the rasterizer. 
*/
module gfx_fragment_processor(clk_i, rst_i,
  pixel_alpha_i,
  x_counter_i, y_counter_i, z_i, u_i, v_i, bezier_factor0_i, bezier_factor1_i, bezier_inside_i, write_i, curve_write_i, ack_o, // from raster
  pixel_x_o, pixel_y_o, pixel_z_o, pixel_color_i, pixel_color_o, pixel_alpha_o, write_o, ack_i,  // to blender
  texture_ack_i, texture_data_i, texture_addr_o, texture_sel_o, texture_request_o, // to/from wishbone master read
  texture_enable_i, tex0_base_i, tex0_size_x_i, tex0_size_y_i, color_depth_i, colorkey_enable_i, colorkey_i // from wishbone slave
  );

parameter point_width = 16;

input clk_i;
input rst_i;

input [7:0]  pixel_alpha_i;

// from raster
input [point_width-1:0] x_counter_i;
input [point_width-1:0] y_counter_i;
input signed [point_width-1:0] z_i;
input [point_width-1:0] u_i; // x-ish texture coordinate
input [point_width-1:0] v_i; // y-ish texture coordinate
input [point_width-1:0] bezier_factor0_i; // Used for curve writing
input [point_width-1:0] bezier_factor1_i; // Used for curve writing
input                   bezier_inside_i;
input            [31:0] pixel_color_i;
input                   write_i;
input                   curve_write_i;
output reg              ack_o;

//to render
output reg [point_width-1:0] pixel_x_o;
output reg [point_width-1:0] pixel_y_o;
output reg signed [point_width-1:0] pixel_z_o;
output reg            [31:0] pixel_color_o;
output reg             [7:0] pixel_alpha_o;
output reg                   write_o;
input                        ack_i;

// to/from wishbone master read
input              texture_ack_i;
input       [31:0] texture_data_i;
output      [31:2] texture_addr_o;
output reg  [ 3:0] texture_sel_o;
output reg         texture_request_o;

// from wishbone slave
input                   texture_enable_i;
input            [31:2] tex0_base_i;
input [point_width-1:0] tex0_size_x_i;
input [point_width-1:0] tex0_size_y_i;
input            [ 1:0] color_depth_i;
input                   colorkey_enable_i;
input            [31:0] colorkey_i;

wire             [31:0] pixel_offset;

// Calculate the memory address of the texel to read 
assign pixel_offset = (color_depth_i == 2'b00) ? (tex0_size_x_i*v_i + {16'h0, u_i})      : // 8  bit
                      (color_depth_i == 2'b01) ? (tex0_size_x_i*v_i + {16'h0, u_i}) << 1 : // 16 bit
                      (tex0_size_x_i*v_i + {16'h0, u_i})                            << 2 ; // 32 bit
assign texture_addr_o = tex0_base_i + pixel_offset[31:2];

// State machine
reg [1:0] state;
parameter wait_state = 2'b00, texture_read_state = 2'b01, write_pixel_state = 2'b10;

wire [31:0] mem_conv_color_o;

// Color converter
memory_to_color color_proc(
.color_depth_i (color_depth_i),
.mem_i         (texture_data_i),
.mem_lsb_i     (u_i[1:0]),
.color_o       (mem_conv_color_o),
.sel_o         ()
);

// Does the fetched texel match the colorkey?
wire transparent_pixel = (color_depth_i == 2'b00) ? (mem_conv_color_o[7:0]  == colorkey_i[7:0])  : // 8  bit
                         (color_depth_i == 2'b01) ? (mem_conv_color_o[15:0] == colorkey_i[15:0]) : // 16 bit
                         (mem_conv_color_o == colorkey_i);                                         // 32 bit

// These variables are used when rendering bezier shapes. If bezier_draw is true, pixel is drawn, if it is false, pixel is discarded.
// These variables are only used if curve_write_i is high

// Calculate if factor0*factor0 > factor1
// Values are in the range [0..1], represented by a [point_width-1:0] bit array
wire [2*point_width-1:0] bezier_factor0_squared = bezier_factor0_i*bezier_factor0_i;
wire bezier_eval = bezier_factor0_squared[2*point_width-1:point_width] > bezier_factor1_i;
wire bezier_draw = bezier_inside_i ^ bezier_eval; // inside xor eval

// Acknowledge when a command has completed
always @(posedge clk_i or posedge rst_i)
begin
  // reset, init component
  if(rst_i)
  begin
    ack_o             <= 1'b0;
    write_o           <= 1'b0;
    pixel_x_o         <= 1'b0;
    pixel_y_o         <= 1'b0;
    pixel_z_o         <= 1'b0;
    pixel_color_o     <= 1'b0;
    pixel_alpha_o     <= 1'b0;
    texture_request_o <= 1'b0;
    texture_sel_o     <= 4'b1111;
  end
  // Else, set outputs for next cycle
  else
  begin
    case (state)

      wait_state:
      begin
        ack_o   <= write_i & curve_write_i & ~bezier_draw;

        if(write_i & texture_enable_i & (~curve_write_i | bezier_draw))
          texture_request_o <= 1'b1;
        else if(write_i & (~curve_write_i | bezier_draw))
        begin
          pixel_x_o         <= x_counter_i;
          pixel_y_o         <= y_counter_i;
          pixel_z_o         <= z_i;
          pixel_color_o     <= pixel_color_i;
          pixel_alpha_o     <= pixel_alpha_i;
          write_o           <= 1'b1; // Note, colorkey only supported for texture reads
        end
      end


      texture_read_state:
        if(texture_ack_i)
        begin
          pixel_x_o         <= x_counter_i;
          pixel_y_o         <= y_counter_i;
          pixel_z_o         <= z_i;
          pixel_color_o     <= mem_conv_color_o;
          pixel_alpha_o     <= pixel_alpha_i;
          texture_request_o <= 1'b0;
          if(colorkey_enable_i & transparent_pixel)
            ack_o           <= 1'b1; // Colorkey enabled: Only write if the pixel doesn't match the colorkey
          else
            write_o         <= 1'b1;
        end


      write_pixel_state:
      begin
        write_o  <= 1'b0;
        ack_o    <= ack_i;
      end

    endcase
  end
end

// State machine
always @(posedge clk_i or posedge rst_i)
begin
  // reset, init component
  if(rst_i)
    state <= wait_state;
  // Move in statemachine
  else
    case (state)

      wait_state:
        if(write_i & texture_enable_i & (~curve_write_i | bezier_draw))
          state <= texture_read_state;
        else if(write_i & (~curve_write_i | bezier_draw))
          state <= write_pixel_state;

      texture_read_state:
        // Check for texture ack. If we have colorkeying enabled, only goto the write state if the texture doesn't match the colorkey
        if(texture_ack_i & colorkey_enable_i)
          state <= transparent_pixel ? wait_state : write_pixel_state;
        else if(texture_ack_i)
          state <= write_pixel_state;

      write_pixel_state:
        if(ack_i)
          state <= wait_state;

    endcase
end

endmodule

