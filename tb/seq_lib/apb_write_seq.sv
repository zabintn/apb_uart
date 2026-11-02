class apb_write_seq extends apb_base_seq;
	`uvm_object_utils(apb_write_seq)

	function new (string name= "apb_write_seq");
		super.new(name);
	endfunction

	rand bit [ADDR_WIDTH-1:0] paddr;

	task body();
		super.body();
		req=apb_seq_item::type_id::create("req");
		start_item(req);
		req.randomize with {presetn==1 && pwrite == 1;
		paddr==local::paddr;};
		finish_item(req);
		req.print();
	endtask
endclass
