module ulx3s_ps2mouse
#(
  parameter mousecore = 1 // 0-minimig 1-oberon
)
(
  input clk_25mhz,
  input [6:0] btn,
  output [7:0] led,
  inout usb_fpga_bd_dp, usb_fpga_bd_dn,
  output usb_fpga_pu_dp, usb_fpga_pu_dn,
  output wifi_gpio0
);
    // wifi_gpio0=1 keeps board from rebooting
    // hold btn0 to let ESP32 take control over the board
    assign wifi_gpio0 = btn[0];
    wire clk;
    assign clk = clk_25mhz;
    // enable pullups 1.5k to 3.3V
    assign usb_fpga_pu_dp = 1'b1;
    assign usb_fpga_pu_dn = 1'b1;

    reg [19:0] reset_counter;
    always @(posedge clk)
    begin
      if(btn[0] == 1'b0 && reset_counter[19] == 1'b0)
        reset_counter <= reset_counter + 1;
      if(btn[0] == 1'b1)
        reset_counter <= 0;
    end
    wire reset;
    assign reset = reset_counter[19];

    wire mouse_update;
    wire [10:0] mouse_x, mouse_y, mouse_z;
    wire [2:0] mouse_btn;

    generate
      if(mousecore == 0) // using minimig core
      begin
        wire ps2mdat_in, ps2mclk_in, ps2mdat_out, ps2mclk_out;
        assign usb_fpga_bd_dp = ps2mclk_out ? 1'bz : 1'b0;
        assign usb_fpga_bd_dn = ps2mdat_out ? 1'bz : 1'b0;
        assign ps2mclk_in = usb_fpga_bd_dp;
        assign ps2mdat_in = usb_fpga_bd_dn;
        ps2mouse
        #(
          .c_x_bits(11),
          .c_y_bits(11)
        )
        ps2mouse_minimig_inst
        (
          .clk(clk),
          .reset(reset),
          .ps2mdati(ps2mdat_in),
          .ps2mclki(ps2mclk_in),
          .ps2mdato(ps2mdat_out),
          .ps2mclko(ps2mclk_out),
          .xcount(mouse_x),
          .ycount(mouse_y),
          .btn(mouse_btn)
        );
        assign mouse_update = 1'b1;
      end
      if(mousecore == 1) // using oberon core
      begin
        mousem
        #(
          .c_x_bits(11),
          .c_y_bits(11),
          .c_z_bits(11),
          .c_hotplug(1)
        )
        ps2mouse_oberon_inst
        (
          .clk(clk),
          .clk_ena(1'b1),
          .ps2m_reset(reset),
          .ps2m_clk(usb_fpga_bd_dp),
          .ps2m_dat(usb_fpga_bd_dn),
          .update(mouse_update),
          .x(mouse_x),
          .y(mouse_y),
          .z(mouse_z),
          .btn(mouse_btn)
        );
      end
    endgenerate
    
    reg [7:0] R_led;
    always @(posedge clk)
    begin
      if(mouse_update)
      begin
        R_led[7:6] <= mouse_z[1:0];
        R_led[5:4] <= mouse_y[1:0];
        R_led[3:2] <= mouse_x[1:0];
        R_led[1:0] <= mouse_btn[1:0] ^ {1'b0, mouse_btn[2]};
      end
    end
    assign led = R_led;
endmodule
