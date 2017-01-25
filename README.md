# 16x2-LCD-Controller-VHDL
A little program I wrote to control the LCD on my FPGA
It is a derivation of one I found [here](https://eewiki.net/download/attachments/4096079/lcd_controller.vhd?version=3&modificationDate=1339620193283&api=v2) and modified it so that it has two 128 bit wide busses to control each line of the LCD. The program is hardcoded with a message from me, but it can be configured to take in anything.

This provided UCF in the repository is for the [Genesys FPGA dev board](http://store.digilentinc.com/genesys-virtex-5-fpga-development-board-limited-time-see-genesys2/) so your pin layout will differ if you are using a different dev board.
