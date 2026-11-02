class uart_seq_item extends uvm_sequence_item;
	rand bit [DATA_WIDTH-1:0] uart_data;

	`uvm_object_utils_begin(uart_seq_item)
	`uvm_field_int(uart_data, UVM_ALL_ON)
	`uvm_object_utils_end

	function new(string name="uart_seq_item");
		super.new(name);
	endfunction

endclass
