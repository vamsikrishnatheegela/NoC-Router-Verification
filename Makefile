TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(PWD)/rtl/noc_router.sv $(PWD)/tb/tb_top.sv
TOPLEVEL = tb_top
MODULE = test_noc_router
SIM ?= icarus
COMPILE_ARGS += -g2012
include $(shell cocotb-config --makefiles)/Makefile.sim

.PHONY: lint synth clean
lint:
	verilator --lint-only -Wall -Wno-fatal -Wall -Irtl rtl/noc_router.sv
synth:
	yosys -s scripts/synth.ys
clean:
	rm -rf sim_build results.xml dump.vcd *.vcd
