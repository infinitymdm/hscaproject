quit -sim

if [file exists work] {
    vdel -all
}
vlib work

vlog tb.sv fpdiv.sv f32utils.sv mdiv.sv esub.sv goldschmidt.sv mux.sv flopenr.sv
vsim -voptargs=+acc work.tb

add wave -noupdate -divider TB
add wave -hex /tb/dividend /tb/divisor /tb/quotient

add wave -noupdate -divider FPDIV
add wave -hex /tb/dut/*

add wave -noupdate -divider DIV
add wave -hex /tb/dut/div/*

add wave -noupdate -divider GOLDSCHMIDT_CTRL
add wave -hex /tb/dut/div/gctrl/*

add wave -noupdate -divider GOLDSCHMIDT_DIVIDER
add wave -hex /tb/dut/div/gdiv/*

run -all