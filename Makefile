TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(PWD)/rtl/noc_router.sv $(PWD)/tb/tb_top.sv
TOPLEVEL = tb_top
COCOTB_TEST_MODULES = test_noc_router
export PYTHONPATH := $(PWD)/tests:$(PYTHONPATH)
SIM ?= icarus
COMPILE_ARGS += -g2012
include $(shell cocotb-config --makefiles)/Makefile.sim

.PHONY: lint synth purge
lint:
	verilator --lint-only -Wall -Wno-fatal -Wall -Irtl rtl/noc_router.sv
synth:
	yosys -s scripts/synth.ys
purge:
	rm -rf sim_build results.xml dump.vcd *.vcd
