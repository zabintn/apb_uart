class uart_monitor extends uvm_monitor;
	virtual uart_if uart_vif;
	uvm_analysis_port #(uart_seq_item) item_collect_port;	
	uvm_analysis_port #(uart_seq_item) rx_collect_port;
	uart_seq_item mon_item;
	int bit_period = 16;
	`uvm_component_utils(uart_monitor)

	function new(string name="uart_monitor", uvm_component parent=null);
		super.new(name, parent);
		item_collect_port=new("item_collect_port", this);
		mon_item=new();
		rx_collect_port=new("rx_collect_port", this);
	endfunction

	function void build_phase(uvm_phase phase);
		`uvm_info(get_type_name(), "INSIDE UART MONITOR BUILD PHASE", UVM_LOW)
		if(!uvm_config_db#(virtual uart_if) :: get(this, "", "vif", uart_vif))
			`uvm_fatal(get_type_name(), "NOT SET AT TOP LEVEL UART INTERFACE")

		if (!uvm_config_db#(int)::get(this, "", "bit_period", bit_period))
			`uvm_warning(get_type_name(), $sformatf("bit_period not set, using default %0d", bit_period))
	endfunction

	function void connect_phase(uvm_phase phase);
		`uvm_info(get_full_name(),"INSIDE UART MONITOR CONNECT PHASE", UVM_LOW)
	endfunction
	
	task run_phase(uvm_phase phase);
		fork
			monitor_line(0);   // watch tx_o
                	monitor_line(1);   // watch rx_i
        	join
	endtask
	
	task monitor_line(bit is_rx);
		uart_seq_item item;
		forever begin
			if (is_rx) 
				@(negedge uart_vif.rx_i);
			else       
				@(negedge uart_vif.tx_o);

                	repeat (bit_period/2) @(posedge uart_vif.pclk);

                	if ((is_rx ? uart_vif.rx_i : uart_vif.tx_o) == 1'b0) begin
                        	item = uart_seq_item::type_id::create("item");
                        	sample_frame(item, is_rx);
                        	if (is_rx) rx_collect_port.write(item);
                        	else       
					item_collect_port.write(item);
                	end
        	end
	endtask

	task sample_frame(uart_seq_item item, bit is_rx);
        	for (int i = 0; i < 8; i++) begin
                	repeat (bit_period) @(posedge uart_vif.pclk);
                	item.uart_data[i] = is_rx ? uart_vif.rx_i : uart_vif.tx_o;
        	end
        	repeat (bit_period) @(posedge uart_vif.pclk);
        	if ((is_rx ? uart_vif.rx_i : uart_vif.tx_o) !== 1'b1)
                	`uvm_error(get_full_name(), $sformatf("STOP BIT LOW on %s", is_rx ? "rx_i" : "tx_o"))
	endtask
	endclass
