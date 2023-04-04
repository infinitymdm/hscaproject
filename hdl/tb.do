quit -sim

if [file exists work] {
    vdel -all
}
vlib work

vlog tb.sv fpdiv.sv f32utils.sv mdiv.sv esub.sv
vsim -voptargs=+acc work.tb

add wave -noupdate -divider TB
add wave -hex /tb/dividend /tb/divisor /tb/quotient

add wave -noupdate -divider FPDIV
add wave -hex /tb/dut/*

add wave -noupdate -divider DIV
add wave -hex /tb/dut/div/*

run 100ns