class uart_agent extends uvm_agent;
	`uvm_component_utils(uart_agent)
	uart_driver drv;
	uart_sequencer seqr;
	uart_monitor mon;

	function new(string name="uart_agent", uvm_component parent=null);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_full_name(), "BEFORE UART AGENT BUILD PHASE", UVM_LOW);
		if(get_is_active == UVM_ACTIVE) begin
			drv=uart_driver::type_id::create("uart_drv", this);
			seqr=uart_sequencer::type_id::create("uart_seqr", this);
		end
		mon=uart_monitor::type_id::create("uart_mon", this);
		`uvm_info(get_full_name(), "INSIDE UART AGENT BUILD PHASE", UVM_LOW)
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		`uvm_info(get_full_name(), "INSIDE UART AGENT CONNECT PHASE", UVM_LOW)
		drv.seq_item_port.connect(seqr.seq_item_export);
	endfunction

	task run_phase(uvm_phase phase);
		`uvm_info(get_full_name(), "INSIDE UART AGENT RUN PHASE", UVM_LOW);
	endtask

endclass
