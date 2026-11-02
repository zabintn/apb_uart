# ----------------------------------------
# Vivado xsim-based Makefile
# Compile -> Elaborate -> Simulate flow
# ----------------------------------------

TEST ?= apb_base_test
CLK_FREQUENCY ?= 100
RTL_DIR   = ../rtl/apb_uart/src/
TB_DIR    = .
SIM_DIR   = .

NUM_RUNS ?= 1
SEED ?= 1

UVMVM_VERBOSITY = UVM_LOW

TOP       = apb_uart_tb_top
SNAPSHOT  = apb_uart_tb_top_snap
TIMESCALE = 1ns/1ps
RTL_SRC   = $(RTL_DIR)/io_generic_fifo.sv \
	    $(RTL_DIR)/uart_interrupt.sv \
	    $(RTL_DIR)/uart_rx.sv \
	    $(RTL_DIR)/uart_tx.sv \
	    $(RTL_DIR)/apb_uart_sv.sv 
TB_SRC    = $(TB_DIR)/compile.f

TESTLIST = uart_read_test uart_write_test uart_read_write_test

REGR_SEEDS ?= 1
REGRESS_DIR ?= regr
MERGE_DIR ?= cov_merged

# Coverage settings
COV_DIR   = xsim.covdb

.PHONY: compile elaborate simulate run clean

# Step 1: Compile RTL + testbench sources
compile:
	xvlog --sv -L uvm $(RTL_SRC) -f $(TB_SRC)

# Step 2: Elaborate design into a simulation snapshot
elaborate: compile
	xelab $(TOP) -timescale=$(TIMESCALE) -s $(SNAPSHOT) \
		 -cov_db_name $(COV_DIR) \
		 -cc_type sbct \
		 -debug typical


# Step 3: Run simulation:
simulate: elaborate
	xsim $(SNAPSHOT) -runall -testplusarg UVM_TESTNAME=$(TEST) \
		-testplusarg CLK_FREQUENCY=$(CLK_FREQUENCY) \
			     --cov_db_dir $(COV_DIR)
cov_report:
	xcrg -report_format html -report_dir cov_html -dir $(COV_DIR)
	xcrg -report_format text -report_dir cov_txt  -dir $(COV_DIR)

# Convenience target: does all three in order
all: compile elaborate simulate cov_report

clean:
	rm -rf xsim.dir *.log *.jou *.pb *.wdb .Xil xelab.pb webtalk*

regress: compile elaborate
	@mkdir -p $(REGRESS_DIR)
	@rm -f $(REGRESS_DIR)/summary.log
	@rm -rf $(COV_DIR)/xsim.covdb/*_run* $(COV_DIR)/xsim.codeCov/*_run* $(COV_DIR)/report_cc
	@for t in $(TESTLIST); do \
		for i in $$(seq 1 $(NUM_RUNS)); do \
		seed=$$(( $(SEED) + i )); \
		logf=$(REGRESS_DIR)/$${t}_run$${i}.log; \
		echo "=== Running $$t (run $$i/$(NUM_RUNS) seed=$$seed) ==="; \
		xsim $(SNAPSHOT) -runall \
		-testplusarg "UVM_TESTNAME=$$t" \
		-testplusarg "UVM_VERBOSITY=$(UVM_VERBOSITY)" \
		-testplusarg "CLK_FREQUENCY=$(CLK_FREQUENCY)" \
		-sv_seed $$seed \
		-cov_db_dir $(COV_DIR) -cov_db_name $${t}_run$${i} \
		-cc_dir $(COV_DIR) -cc_db $${t}_run$${i} \
		-log $$logf; \
		if [ -f $$logf ] \
		&& grep -q "UVM Report Summary" $$logf \
		&& grep -qE "^UVM_ERROR :[[:space:]]+0[[:space:]]*$$" $$logf \
		&& grep -qE "^UVM_FATAL :[[:space:]]+0[[:space:]]*$$" $$logf; then \
		echo "$$t (run $$i seed=$$seed) : PASS" | tee -a $(REGRESS_DIR)/summary.log; \
		else \
		echo "$$t (run $$i seed=$$seed) : FAIL" | tee -a $(REGRESS_DIR)/summary.log; \
		fi; \
		done; \
		done
	@echo ""; echo "=== REGRESSION SUMMARY ==="; cat $(REGRESS_DIR)/summary.log
	@$(MAKE) regress_report
	@! grep -q ": FAIL" $(REGRESS_DIR)/summary.log

regress_report:
	xcrg -report_format text -dir $(COV_DIR) -report_dir $(COV_DIR)/report > /dev/null
	@grep -m1 "Coverage Score" $(COV_DIR)/report/functionalCoverageReport/xcrg_func_cov_report.txt | \
		awk -F',' '{printf "MERGED FUNCTIONAL COVERAGE = %.2f%%\n", $$2}'
	xcrg -report_format html -cov_db_dir $(COV_DIR) -report_dir $(COV_DIR)/report_cc > /dev/null
	@echo "MERGED CODE COVERAGE REPORT = $(COV_DIR)/report_cc (open the dashboard .html in a browser)"
