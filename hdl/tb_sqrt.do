quit -sim

if [file exists work] {
    vdel -all
}
vlib work

vlog tb_sqrt.sv fpdiv.sv f32utils.sv mantissa_op.sv esub.sv goldschmidt.sv round.sv mux.sv flopenr.sv ../Wallace/mult_cs.sv
vsim -voptargs=+acc work.tb

add wave -noupdate -divider TB
add wave -hex /tb/radicand /tb/result

add wave -noupdate -divider GOLDSCHMIDT_DIVIDER
add wave -hex /tb/dut/divsqrt/*

run -all