onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /servo_tb/DUT/clk
add wave -noupdate /servo_tb/DUT/rst
add wave -noupdate -radix unsigned /servo_tb/DUT/position
add wave -noupdate /servo_tb/DUT/pwm
add wave -noupdate -format Analog-Step -height 100 -max 20000.0 -radix unsigned /servo_tb/DUT/counter
add wave -noupdate -radix unsigned /servo_tb/DUT/duty_cycle
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {108042000 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 199
configure wave -valuecolwidth 85
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 ns} {124598178 ns}
