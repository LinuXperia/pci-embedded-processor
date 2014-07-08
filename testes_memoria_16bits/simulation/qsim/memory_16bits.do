onerror {quit -f}
vlib work
vlog -work work memory.vo
vlog -work work memory_16bits.vt
vsim -novopt -c -t 1ps -L cycloneii_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.memory_vlg_vec_tst
vcd file -direction memory_16bits.msim.vcd
vcd add -internal memory_vlg_vec_tst/*
vcd add -internal memory_vlg_vec_tst/i1/*
add wave /*
run -all
