export CLOCK_PERIOD_PS = $(shell cat synth/clock_period.txt)

SHELL=/bin/bash -o pipefail
.SHELLFLAGS += -e

PKG_SRCS := $(PWD)/pkg/types.sv
HDL_SRCS := $(shell find $(PWD)/hdl -name '*.sv')
HVL_SRCS := $(shell find $(PWD)/hvl -name '*.sv' -o -name '*.v')
SRAM_SRCS := $(shell find $(PWD)/sram/output -name '*.v')
SRCS := $(PKG_SRCS) $(HDL_SRCS) $(HVL_SRCS) $(SRAM_SRCS)

export VCS_ARCH_OVERRIDE=linux
VCS_FLAGS= -full64 -lca -sverilog +lint=all,noNS -timescale=1ns/1ns -debug_acc+all -kdb -fsdb -suppress=LCA_FEATURES_ENABLED

sim/top_tb: $(SRCS)
	mkdir -p sim
	cd sim && vcs $(SRCS) $(VCS_FLAGS) -msg_config=../vcs_warn.config -l compile.log -top top_tb -o top_tb
	bash check_compile_error.sh

.PHONY: run_top_tb
run_top_tb: sim/top_tb $(PROG)
	bin/generate_memory_file.sh $(PROG)
	rm -f sim/dump.fsdb
	cd sim && ./top_tb -l simulation.log
	bash check_sim_error.sh

.PHONY: run_arbiter_tb
run_arbiter_tb: $(SRCS)
	cd sim && vcs $(SRCS) $(VCS_FLAGS) -msg_config=../vcs_warn.config -l compile_arbiter.log -top arbiter_tb -o arbiter_tb && ./arbiter_tb -l arbiter_simulation.log


.PHONY: run_btb_tb
run_btb_tb: $(SRCS)
	cd sim && vcs $(SRCS) $(VCS_FLAGS) -msg_config=../vcs_warn.config -l compile_btb.log -top btb_tb -o btb_tb && ./btb_tb -l btb_simulation.log


.PHONY: run_bp_tb
run_bp_tb: $(SRCS)
	cd sim && vcs $(SRCS) $(VCS_FLAGS) -msg_config=../vcs_warn.config -l compile_bp.log -top branch_predictor_tb -o branch_predictor_tb && ./branch_predictor_tb -l bp_simulation.log

.PHONY: run_local_bp_tb
run_local_bp_tb: $(SRCS)
	rm -f sim/dump.fsdb
	cd sim && vcs $(SRCS) $(VCS_FLAGS) -msg_config=../vcs_warn.config -l compile_local_bp.log -top local_branch_predictor_tb -o local_branch_predictor_tb && ./local_branch_predictor_tb -l local_bp_simulation.log

.PHONY: spike
spike: $(ELF)
	mkdir -p sim
	/class/ece411/software/spike_new/bin/spike --isa=rv32imc -m0x40000000:0x20000000 --log-commits $(ELF) |& tail -n +6 > sim/golden_spike0.log
	bash -c 'head -n -$$(echo $$(grep -c "$$(tail -n 1 sim/golden_spike0.log)" sim/golden_spike0.log)-1 | bc) sim/golden_spike0.log > sim/golden_spike.log'
	rm sim/golden_spike0.log

.PHONY: interactive_spike
interactive_spike: $(ELF)
	/class/ece411/software/spike_new/bin/spike --isa=rv32imc -m0x40000000:0x20000000 --log-commits -d $(ELF)

.PHONY: clean
clean:
	rm -rf sim verdi
	cd synth && $(MAKE) clean
