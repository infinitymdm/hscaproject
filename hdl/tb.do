quit -sim

if [file exists work] {
    vdel -all
}
vlib work

vlog tb.sv fpdiv.sv f32utils.sv mdiv.sv esub.sv goldschmidt.sv mux.sv flopenr.sv ../Wallace/mult_cs.sv
vsim -voptargs=+acc work.tb

add wave -noupdate -divider TB
add wave -hex /tb/test_clk /tb/dividend /tb/divisor /tb/quotient

add wave -noupdate -divider GOLDSCHMIDT_DIVIDER
add wave -hex /tb/dut/div/gdiv/*

run -all