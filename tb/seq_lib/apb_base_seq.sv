class apb_base_seq extends uvm_sequence#(apb_seq_item);
	apb_seq_item req;
	`uvm_object_utils(apb_base_seq);

	function new(string name="apb_base_seq");
		super.new(name);
	endfunction
	task body();
		`uvm_info(get_type_name(), "BASE SEQUENCE INSIDE BODY", UVM_LOW);
	endtask
endclass
