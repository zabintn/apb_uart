class apb_reset_seq extends apb_base_seq;
	`uvm_object_utils(apb_reset_seq)

	function new (string name= "apb_reset_seq");
		super.new(name);
	endfunction

	task body();
		super.body();
		req=apb_seq_item::type_id::create("req");
		start_item(req);
		req.randomize with {presetn==0;};
		finish_item(req);
	endtask
endclass
