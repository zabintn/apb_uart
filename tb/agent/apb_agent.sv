class apb_agent extends uvm_agent;
	`uvm_component_utils(apb_agent)
	apb_driver drv;
	apb_seqcr seqr;
	apb_monitor mon;

	function new(string name= "apb_agent", uvm_component parent=null);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_type_name(), "BEFORE AGENT BUILD PHASE", UVM_LOW);
		if(get_is_active == UVM_ACTIVE) begin
			drv=apb_driver::type_id::create("drv", this);
			seqr=apb_seqcr::type_id::create("seqr", this);
		end

		mon=apb_monitor::type_id::create("mon", this);
		`uvm_info(get_type_name(), "AFTER AGENT BUILD PHASE", UVM_LOW);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		`uvm_info(get_type_name(), "INSIDE AGENT CONNECT PHASE", UVM_LOW);
		drv.seq_item_port.connect(seqr.seq_item_export);
	endfunction

	task run_phase(uvm_phase phase);
		`uvm_info(get_type_name(), "INSIDE AGENT RUN PHASE", UVM_LOW);
	endtask
endclass
