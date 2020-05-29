VERILOG_FILES = $(TOP_MODULE_FILE) \
  $(CLK0_FILE_NAME) \
  $(CLK1_FILE_NAME) \
  ../../../../../hex/decoder/hex_decoder_v.v \
  ../../../../../lcd_st7789/hdl/st7789_video_verilog/lcd_video.v \
  ../../../../usbhost/usbh_sie.v \
  ../../../../usbhost/usbh_crc5.v \
  ../../../../usbhost/usbh_crc16.v \
  ../../../../usbhost/usbh_host_hid.v \

# convertible with vhd2vl
VHDL_FILES = \
  ../../../../usb11_phy_vhdl/usb_phy.vhd \
  ../../../../usb11_phy_vhdl/usb_rx_phy.vhd \
  ../../../../usb11_phy_vhdl/usb_tx_phy.vhd \
  ../../../../../dvi/hdl/vga.vhd \
  ../../../../../dvi/hdl/vga2dvid.vhd \
  ../../../../../dvi/hdl/tmds_encoder.vhd \
