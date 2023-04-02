quit -sim

if [file exists work] {
    vdel -all
}
vlib work

vlog tb.sv fpdiv.sv mantissa_divider.sv exponent_subtractor.sv
vsim -voptargs=+acc work.tb

add wave -noupdate -divider DIV
add wave -hex -color cyan /tb/dut/div/dividend

add wave -noupdate -divider FPDIV
add wave -hex -color cyan /tb/dut/s1 /tb/dut/e1 /tb/dut/m1
add wave -hex -color green /tb/dut/s2 /tb/dut/e2 /tb/dut/m2
add wave -hex -color yellow /tb/dut/s3 /tb/dut/e3 /tb/dut/m3

add wave -noupdate -divider TB
add wave -hex /tb/dividend /tb/divisor /tb/quotient

run 100ns