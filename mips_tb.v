///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Testbench template for MIPS processor
// - This testbench uses two arrays (expected_data and expectd_addr) to store data and addresses of expected operations
// - and for each memory write, it checks if the memory writes match the expected values

// - You need to modify these arrays to match the instructions in memfile.dat file used to initialize imem
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module MIPS_Testbench ();
    reg clk;
    reg reset;
    wire [31:0] writedata, dataadr;
    wire memwrite;

    integer i;
    integer j;

    // expected memory writes
    parameter N = 11; 
    reg [31:0] expected_data[N:1];
    reg [31:0] expected_addr[N:1]; 
    
    // Instantiate top module
    top dut(
        .clk(clk),
        .reset(reset),
        .writedata(writedata),
        .dataadr(dataadr),
        .memwrite(memwrite)
    );
    
    // Initialize expected data and addresses
    initial begin
        expected_data[1] = 32'h65;
        expected_addr[1] = 32'h47;

        expected_data[2] = 32'h1;
        expected_addr[2] = 32'h43;

        expected_data[3] = 32'h7;
        expected_addr[3] = 32'h42;
	
	expected_data[4] = 32'h7;
        expected_addr[4] = 32'h44;

	expected_data[5] = 32'h0;
        expected_addr[5] = 32'h45;

	expected_data[6] = 32'h1;
        expected_addr[6] = 32'h46;

	expected_data[7] = 32'h65;
        expected_addr[7] = 32'h49;

	expected_data[8] = 32'ha;
        expected_addr[8] = 32'h50;

	expected_data[9] = 32'hd;
	expected_addr[9]= 32'h51;
	expected_data[10] = 32'ha;
        expected_addr[10] = 32'h52;

	expected_data[11] = 32'hd;
	expected_addr[11]= 32'h53;




    end

    // Clock generation
    always begin
        clk <= 1'b0; 
        #5;
        clk <= 1'b1; 
        #5;
    end
    
    //FSDB generation
    initial begin
        $fsdbDumpvars();
    end


    // Monitor memory write signals
    always begin
        // Initialize reset
        reset = 1'b1;
        @(posedge clk);
        @(posedge clk);
        reset = 1'b0;

        for(i = 1; i<=N; ) begin
            // Wait for memory write signal

            @(negedge clk);
	    if(memwrite) begin
            //Check if both data and address are expected values
            if (dataadr == expected_addr[i] && writedata == expected_data[i]) begin
                $display("Memory write %0d successful : wrote %h to address %h", i, writedata, dataadr);
            end else begin
                $display("ERROR: Memory write %0d : wrote %h to address %h ; Expected %h to address %h)", 
                         i, writedata, dataadr, expected_data[i], expected_addr[i]);
            end 
 		i=i+1;	    
            end
        end
        $display("TEST COMPLETE");
        $finish;
    end
endmodule
