class apb_seq_item extends uvm_sequence_item;

	rand bit [ADDR_WIDTH-1:0] paddr;
	rand bit [DATA_WIDTH-1:0] pwdata;
	rand int pwrite;
	int psel;
	int penable;
	int pready;
	bit [DATA_WIDTH-1:0] prdata;
	int pslverr;
	rand int presetn;

	`uvm_object_utils_begin(apb_seq_item)
	`uvm_field_int(paddr, UVM_ALL_ON)
	`uvm_field_int(pwdata, UVM_ALL_ON)
	`uvm_field_int(pwrite, UVM_ALL_ON)
	`uvm_field_int(psel, UVM_ALL_ON)
	`uvm_field_int(pready, UVM_ALL_ON)
	`uvm_field_int(prdata, UVM_ALL_ON)
	`uvm_field_int(penable, UVM_ALL_ON)
	`uvm_field_int(pslverr, UVM_ALL_ON)
	`uvm_object_utils_end

	function new(string name= "apb_seq_item");
		super.new(name);
	endfunction
		

endclass
