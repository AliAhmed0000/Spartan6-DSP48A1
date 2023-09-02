vlib work

vlog DSP48A1.v DSP48A1_tb.v

vsim -gui work.DSP48A1_tb -voptargs=+acc

add wave -position insertpoint  \
sim:/ALSU_tb/INPUT_PRIORITY \
sim:/ALSU_tb/FULL_ADDER \
sim:/ALSU_tb/clk \
sim:/ALSU_tb/rst \
sim:/ALSU_tb/cin \
sim:/ALSU_tb/serial_in \
sim:/ALSU_tb/red_op_A \
sim:/ALSU_tb/red_op_B \
sim:/ALSU_tb/bypass_A \
sim:/ALSU_tb/bypass_B \
sim:/ALSU_tb/direction \
sim:/ALSU_tb/A \
sim:/ALSU_tb/B \
sim:/ALSU_tb/opcode \
sim:/ALSU_tb/leds \
sim:/ALSU_tb/out \
sim:/DSP48A1_tb/D1/D_A_B_concatenate

run -all