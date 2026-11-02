class apb_env extends uvm_env;
	`uvm_component_utils(apb_env)
	apb_agent agt1;
	uart_agent agt2;
	apb_scoreboard sb;
	apb_functional_cov fc;

	function new(string name = "apb_env", uvm_component parent= null);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		`uvm_info(get_type_name(), "BEFORE ENVIRONMENT CONSTRUCTOR", UVM_LOW);
		super.build_phase(phase);
		agt1=apb_agent::type_id::create("agt1", this);	
		agt2=uart_agent::type_id::create("agt2", this);
		sb=apb_scoreboard::type_id::create("sb", this);
		fc=apb_functional_cov::type_id::create("fc", this);
		`uvm_info(get_type_name(), "AFTER ENVIRONMENT CONSTRUCTOR", UVM_LOW);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		`uvm_info(get_type_name(), "INSIDE CONNECT PHASE OF UVM ENVIRONMENT", UVM_LOW);
		agt1.mon.item_collect_port.connect(sb.item_collect_export);
		agt1.mon.item_collect_port.connect(fc.analysis_export);
		agt2.mon.item_collect_port.connect(sb.utx_export);
		agt2.mon.rx_collect_port.connect(sb.urx_export);
	endfunction

	task run_phase(uvm_phase phase);
		`uvm_info(get_type_name(), "INSIDE RUN PHASE OF UVM ENVIRONMENT", UVM_LOW);
	endtask

endclass
