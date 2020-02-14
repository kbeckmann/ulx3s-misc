// X/Y video HEX decoder core
// AUTHOR=EMARD
// LICENSE=BSD

// simplified hex decoder for 8x8 font grid

module hex_decoder8
#(
  // Useful values of C_data_len: 4,8,16,32,64,128,192,256,320,448,512
  // Display has 8 lines. Each line has 16 HEX digits or 64 bits.
  // C_data_len(63 downto 0) is shown on the first line
  // C_data_len(127 downto 64) is shown on second line etc.
  parameter C_data_len = 8, // input bits report len
  parameter C_row_bits = 4, // 2^n hex digits in a row 4:16, 5:32, etc.
  parameter C_font_file = "oled_font.mem",
  parameter C_font_size = 136,
  parameter C_color_bits = 16,
  parameter C_x_bits = 8, // X screen bits
  parameter C_y_bits = 8  // Y screen bits
)
(
  input  wire clk, // 1-25 MHz clock typical
  input  wire [C_data_len-1:0] data,
  input  wire [C_x_bits-1:0] x,
  input  wire [C_y_bits-1:0] y,
  output wire [C_color_bits-1:0] color
);

  reg [4:0] C_oled_font[0:C_font_size-1];
  initial
  begin
    $readmemb(C_font_file, C_oled_font);
  end

  // RGB332
  // red   20 40 80
  // green 04 08 10
  // blue     01 02
  // RGB565
  // red        0800 1000 2000 4000 8000
  // green 0020 0040 0080 0100 0200 0400
  // blue       0001 0002 0004 0008 0010 
  localparam C_color_black         = C_color_bits < 12 ? 8'h00 : 16'h0000 ;
  localparam C_color_dark_red      = C_color_bits < 12 ? 8'h40 : 16'h4000 ;
  localparam C_color_dark_brown    = C_color_bits < 12 ? 8'h44 : 16'h2100 ;
  localparam C_color_dark_yellow   = C_color_bits < 12 ? 8'h48 : 16'h4200 ;
  localparam C_color_dark_green    = C_color_bits < 12 ? 8'h08 : 16'h0200 ;
  localparam C_color_dark_cyan     = C_color_bits < 12 ? 8'h05 : 16'h0208 ;
  localparam C_color_dark_blue     = C_color_bits < 12 ? 8'h01 : 16'h0008 ;
  localparam C_color_dark_violett  = C_color_bits < 12 ? 8'h21 : 16'h4008 ;
  localparam C_color_gray          = C_color_bits < 12 ? 8'h45 : 16'h630C ;
  localparam C_color_light_red     = C_color_bits < 12 ? 8'h80 : 16'h8000 ;
  localparam C_color_orange        = C_color_bits < 12 ? 8'h84 : 16'h4200 ;
  localparam C_color_light_yellow  = C_color_bits < 12 ? 8'h90 : 16'h8400 ;
  localparam C_color_light_green   = C_color_bits < 12 ? 8'h10 : 16'h0400 ;
  localparam C_color_light_cyan    = C_color_bits < 12 ? 8'h0A : 16'h0410 ;
  localparam C_color_light_blue    = C_color_bits < 12 ? 8'h02 : 16'h0010 ;
  localparam C_color_light_violett = C_color_bits < 12 ? 8'h42 : 16'h8010 ;
  localparam C_color_white         = C_color_bits < 12 ? 8'hFF : 16'hFFFF ;

  wire [C_color_bits-1:0] C_color_map[0:15]; // char background color map
  assign C_color_map[0] = C_color_black;
  assign C_color_map[1] = C_color_dark_red;
  assign C_color_map[2] = C_color_dark_brown;
  assign C_color_map[3] = C_color_dark_yellow;
  assign C_color_map[4] = C_color_dark_green;
  assign C_color_map[5] = C_color_dark_cyan;
  assign C_color_map[6] = C_color_dark_blue;
  assign C_color_map[7] = C_color_dark_violett;
  assign C_color_map[8] = C_color_gray;
  assign C_color_map[9] = C_color_light_red;
  assign C_color_map[10] = C_color_orange;
  assign C_color_map[11] = C_color_light_yellow;
  assign C_color_map[12] = C_color_light_green;
  assign C_color_map[13] = C_color_light_cyan;
  assign C_color_map[14] = C_color_light_blue;
  assign C_color_map[15] = C_color_light_violett;

  wire [3:0] S_data_array[C_data_len/4-1:0];
  generate
    genvar i;
    for(i = 0; i < C_data_len/4; i=i+1)
      assign S_data_array[i] = data[i*4+3:i*4];
  endgenerate
  wire [3:0] S_hex_digit = S_data_array[{y[7:3],x[2+C_row_bits:3]}];
  wire [C_color_bits-1:0] S_bg = C_color_map[S_hex_digit];
  wire [6:0] S_font_addr = {S_hex_digit,y[2:0]};
  wire S_pixel_on = x[2:0] < 5 ? C_oled_font[S_font_addr][x[2:0]] : 1'b0;
  assign color = S_pixel_on ? C_color_white : S_bg;
endmodule