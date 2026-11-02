class uart_driver extends uvm_driver#(uart_seq_item);
	virtual uart_if uart_vif;
	int bit_period = 16;
	`uvm_component_utils(uart_driver)

	function new(string name="uart_driver", uvm_component parent= null);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_full_name(), "INSIDE UART DRIVER BUILD PHASE", UVM_LOW);
		if(!uvm_config_db#(virtual uart_if) :: get(this, "", "vif", uart_vif))
			`uvm_fatal(get_type_name(), "UART INTERFACE NOT SET AT TOP LEVEL")
		
		if (!uvm_config_db#(int)::get(this, "", "bit_period", bit_period))
			`uvm_warning(get_type_name(), $sformatf("bit_period not set, using default %0d", bit_period))
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		`uvm_info(get_full_name(), "INSIDE UART DRIVER CONNECT PHASE", UVM_LOW)
	endfunction


	task run_phase(uvm_phase phase);
		`uvm_info(get_full_name(), "INSIDE UART DRIVER RUN PHASE", UVM_LOW)
		uart_vif.rx_i <= 1'b1;
		forever begin
			seq_item_port.get_next_item(req);
			drive_frame(req);
			seq_item_port.item_done();
		end
	endtask

	task drive_bit(bit b);
		uart_vif.rx_i <= b;
		repeat (bit_period) @(posedge uart_vif.pclk);
	endtask

	task drive_frame(uart_seq_item item);
		`uvm_info(get_type_name(), $sformatf("Sending 0x%02h", item.uart_data), UVM_LOW)

		drive_bit(1'b0); //start bit
		for (int i=0; i<8;i++) begin
			drive_bit(item.uart_data[i]);
		end
		drive_bit(1'b1); //stop bit

	endtask
		
endclass
