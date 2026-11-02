class uart_base_seq extends uvm_sequence#(uart_seq_item);
uart_seq_item req;
rand int unsigned num_items = 5;
`uvm_object_utils(uart_base_seq);

function new(string name="uart_base_seq");
	super.new(name);
endfunction
task body();
	uart_seq_item item;
	`uvm_info(get_type_name(), "BASE SEQUENCE INSIDE BODY", UVM_LOW)
	repeat (num_items) begin
		item = uart_seq_item::type_id::create("item");
		start_item(item);
		if (!item.randomize())
			`uvm_error(get_type_name(), "randomization failed")
		finish_item(item);
	end
  endtask
endclass
