vlib work

vcom -work work ../src/baud_gen.vhd 
vcom -work work ../src/uart_tx.vhd 
vcom -work work ../src/rx_fsm.vhd 
vcom -work work ../src/uart_buff.vhd 
vcom -work work ../tb/tb_uart_tx.vhd 

vsim work.tb_uart_tx

add wave -hex -r *

run 800000 ns


