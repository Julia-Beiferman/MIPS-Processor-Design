//////////////////////////////////////////////////////////////////////
// ===================================================================
// This file has the following module implementations:
// 1. datapath
// 2. regfile
// 3. alu
// 4. adder
// 5. mux2
// 6. sl2
// 7. signext
// 8. flopr
// ===================================================================
//////////////////////////////////////////////////////////////////////
// Datapath module
//////////////////////////////////////////////////////////////////////
module datapath (
    input clk, reset,
    input memtoreg, pcsrc,
    input alusrc, regdst,
    input regwrite, jump,
    input [2:0] alucontrol,
    output zero,
    output [31:0] pc,
    input [31:0] instr,
    output [31:0] aluout, writedata,
    input [31:0] readdata,
    output stallD, input memtoregE_fromctl,input stall_state,stallDMUL,input perfmon_type, input perfmon_en
);

    logic [4:0] writereg, writeregE_103, writeregM_104, writeregW_105;
    logic [2:0] alucontrolE_103,alucontrolD_102; 
    logic [31:0] pcnext, pcnextbr, pcplus4, pcbranch;
    logic [31:0] signimm, signimmsh;
    logic [31:0] srca, srcb;
    logic [31:0] result;
    
    /* Non-pipelined code
    // next PC logic
    //flopr #(32) pcreg(clk, reset, pcnext, pc);
    //adder pcadd1 (pc, 32'b100, pcplus4);
    sl2 immsh(signimm, signimmsh);        //shift left block 
    adder pcadd2(pcplus4, signimmsh, pcbranch); //execute stage ki adder
    mux2 #(32) pcbrmux(pcplus4, pcbranch, pcsrc, pcnextbr);  //fetch stage mux 
    mux2 #(32) pcmux(pcnextbr, {pcplus4[31:28], instr[25:0], 2'b00}, jump, pcnext); //fetch stage mux extra 

    // register file logic
    //regfile rf(clk, regwrite, instr[25:21], instr[20:16], writereg, result, srca, writedata);
    mux2 #(5) wrmux(instr[20:16], instr[15:11], regdst, writereg); //Rte Rtd gen mux
    mux2 #(32) resmux(aluout, readdata, memtoreg, result); //final mux choosing between aluout and readdata
    //signext se(instr[15:0], signimm);  //sign extender module
    
    // ALU logic
    mux2 #(32) srcbmux(writedata, signimm, alusrc, srcb); //mux feeding ALU
    alu alu(srca, srcb, alucontrol, aluout, zero);        //ALU component
*/

   logic zeroM_104, regdstD_102, regdstE_103,zeroE_103 ; 
   logic [31:0] aluoutM_104, writedataM_104, pcbranchM_104; 
   logic [31:0] pcplus4D_102, instrD_102;
   logic [4:0] writeregD_102; 
   logic [31:0] resultD_102, signimmD_102,srcaD_102,writedataD_102; 
   logic memtoregD_102, memtoregE_103, memtoregM_104, memtoregW_105; 
   logic alusrcD_102; 
   logic [31:0] instrE_103, pcplus4E_103, srcbE_103, srcaE_103, writedataE_103, signimmE_103; 
   logic alusrcE_103 ;
   logic [31:0] aluoutW_105,readdataW_105, resultW_105;
   logic regwriteD_102;
 
   logic [1:0] perfmon,perfmonD,perfmonE,perfmonM,perfmonW ; 
   assign perfmonD = {perfmon_type,perfmon_en};
   assign aluout       = aluoutM_104; 
   //assign pc           = 
   assign writedata    = writedataM_104;
   assign zero         = zeroM_104;
//Pipelined MIPS 

   logic stallF ;
   assign stallF = (((instrD_102[25:21]==instrE_103[20:16])||(instrD_102[20:16]==instrE_103[20:16]))&&((instrD_102[25:21]!=5'b0)&&(instrD_102[20:16]!=5'b0))&&memtoregE_fromctl) || stallDMUL;
	  assign stallD = stallF || stallDMUL ; 
   // Fetch logic ;
   flopr #(32) pcreg(clk, reset,stallF, pcnext, pc);
   adder pcadd1 (pc, 32'b100, pcplus4);
   mux2 #(32) pcbrmux(pcplus4, pcbranchM_104, pcsrc, pcnextbr);  //fetch stage mux 
   mux2 #(32) pcmux(pcnextbr, {pcplus4[31:28], instr[25:0], 2'b00}, jump, pcnext); //fetch stage mux extra 

   
   //Fetch to decode pipeline registers
     always @ (posedge clk or posedge reset) begin 
	   if (reset) begin 
	   	pcplus4D_102 <= 32'b0;
		instrD_102 <= 32'b0;
		//writeregD_102<=5'b0;
		regwriteD_102<=1'b0;
	        alusrcD_102 <= 1'b0; 
		memtoregD_102 <= 1'b0 ;
	       alucontrolD_102<=3'b0;
               regdstD_102 <=1'b0;	 
	   end else begin
		   
		  case(stallD) 
			  1'b0: begin 
	   			pcplus4D_102 <= pcplus4;
				instrD_102 <= instr;
	        		regdstD_102<=regdst;	
				regwriteD_102 <=regwrite;
	        		alusrcD_102 <= alusrc ; 
	        		memtoregD_102 <= memtoreg ; 
	       			alucontrolD_102<=alucontrol;
			 end	
			 1'bx: begin 
	   			pcplus4D_102 <= pcplus4;
				instrD_102 <= instr;
	        		regdstD_102<=regdst;	
				regwriteD_102 <=regwrite;
	        		alusrcD_102 <= alusrc ; 
	        		memtoregD_102 <= memtoreg ; 
	       			alucontrolD_102<=alucontrol;
			 end	
			 1'b1:  begin 
				pcplus4D_102 <= pcplus4D_102;
				instrD_102 <= instrD_102;
	        		regdstD_102<=regdstD_102;	
				regwriteD_102 <=regwriteD_102;
	        		alusrcD_102 <= alusrcD_102 ; 
	        		memtoregD_102 <= memtoregD_102 ; 
	       			alucontrolD_102<=alucontrolD_102;
		 	 end
		 endcase


	   end 
   end 

   logic stall_stateD_102;
   always @ (posedge clk or posedge reset) begin 
	if (reset) stall_stateD_102 <=1'b0; 
	else stall_stateD_102 <= stall_state;
   end
   // 2. Latch accumulator (rd value) during stal

	logic [4:0] rf_read_addr2;
	assign rf_read_addr2 = stall_stateD_102 ? instrD_102[15:11] : instrD_102[20:16]; // Read rd during stall
	//assign rf_read_addr2 = stallDMUL ? instrD_102[15:11] : instrD_102[20:16]; // Read rd during stall
   // Decode/RF logic (Including an instance of register file and other logic)
   regfile rf(clk, regwrite, instrD_102[25:21], rf_read_addr2, writeregW_105, resultW_105, srcaD_102, writedataD_102);
   signext se(instrD_102[15:0], signimmD_102);

    //Decode-to-execute pipeline registers
 
   logic stall_stateE_103;
   always @ (posedge clk or posedge reset) begin 
	if (reset) stall_stateE_103 <=1'b0; 
	else stall_stateE_103 <= stall_stateD_102;
   end

   logic [31:0] accumD_102, accumE_103;
     always_ff @(posedge clk or posedge reset) begin
    		if (reset) accumE_103 <= 32'b0;
    		else if (stall_stateE_103) accumE_103 <= writedataD_102;
    	end


   always @ (posedge clk or posedge reset) begin 
	   if (reset) begin 
		instrE_103<=32'b0 ; 
		pcplus4E_103<=32'b0; 
		srcaE_103<=32'b0;
		writedataE_103<=32'b0;
		signimmE_103 <= 32'b0; 
		alusrcE_103 <= 1'b0 ; 
		srcaE_103 <= 32'b0; 
		regdstE_103 <= 1'b0 ; 
		  memtoregE_103 <= 1'b0; 
                alucontrolE_103<=3'b0;
		perfmonE<=2'b0;
	   end else begin

		if(!stall_stateE_103) begin
		  instrE_103<=instrD_102 ; 
		  pcplus4E_103<=pcplus4D_102; 
		  srcaE_103<=srcaD_102;
		  writedataE_103<=writedataD_102;
		  signimmE_103 <= signimmD_102;
		  alusrcE_103 <= alusrcD_102 ; 
		  regdstE_103 <= regdstD_102 ;
		  memtoregE_103 <= memtoregD_102; 
                  alucontrolE_103 <= alucontrolD_102;
		  perfmonE<=perfmonD;
		end
	   end 
   end
	   logic [31:0] aluoutE_103; 
           logic [31:0] pcbranchE_103, signimmshE_103;


  //Execute logic (Including an instance of ALU and other logic)
    mux2 #(32) srcbmux(writedataE_103, signimmE_103, alusrc, srcbE_103); //mux feeding ALU
    alu alu(srcaE_103, srcbE_103, accumE_103, alucontrol, aluoutE_103, zeroE_103);        //ALU component
    sl2 immsh(signimmE_103, signimmshE_103);        //shift left block 
    mux2 #(5) wrmux(instrE_103[20:16], instrE_103[15:11], regdst, writeregE_103); //Rte Rtd gen mux
    adder pcadd2(pcplus4E_103, signimmshE_103, pcbranchE_103); //execute stage ki adder


   logic [31:0] instrM_104,instrW_105;
   // Execute-to-memory pipeline registers
     always @ (posedge clk or posedge reset) begin 
	   if (reset) begin 
		   pcbranchM_104   <=  32'b0 ; 
		   aluoutM_104     <=  32'b0; 
		   writedataM_104  <=  32'b0; 
		   zeroM_104       <=  1'b0 ; 
		  memtoregM_104 <= 1'b0;
		  writeregM_104 <= 5'b0; 
		  instrM_104 <=32'b0; 
		  perfmonM<=2'b0;

	   end else begin 
		   pcbranchM_104   <=  pcbranchE_103 ; 
		   aluoutM_104     <=  aluoutE_103; 
		   writedataM_104  <=  writedataE_103; 
		   zeroM_104       <=  zeroE_103 ; 
		  memtoregM_104 <= memtoregE_103;
		  writeregM_104 <= writeregE_103; 
		  instrM_104<=instrE_103;
		  perfmonM<=perfmonE;

	   end 
     end



   // Memory logic (if any)
   

   // Memory-to-writeback pipeline registers
   //

     
     always @ (posedge clk or posedge reset) begin 
	   if (reset) begin
		  aluoutW_105   <= 32'b0 ; 
		  readdataW_105 <= 32'b0 ;
		  memtoregW_105 <= 1'b0 ; 
		  writeregW_105 <= 5'b0 ; 
		  instrW_105 <= 32'b0;
		  perfmonW <=2'b0;
	   end else begin 
		  aluoutW_105   <= aluoutM_104 ; 
		  readdataW_105 <= readdata ;
		  memtoregW_105 <= memtoregM_104; 
		  writeregW_105 <= writeregM_104;
		  instrW_105 <= instrM_104;
		  perfmonW <= perfmonM;

           end 
     end

     logic instrW_105_prev ; 

     always @ (posedge clk or posedge reset) begin 
	if (reset) instrW_105_prev<=32'b0;
	else instrW_105_prev <= instrW_105;

     end

   // Writeback logic    
   logic [31:0] resultW_105_pre;
    mux2 #(32) resmux(aluoutW_105, readdataW_105, memtoreg, resultW_105_pre); //final mux choosing between aluout and readdata
   
    logic [63:0] perf_ctr , perf_ctr_inst; 
    logic instr_complete ; 

    always_comb begin 
	instr_complete = |(instrW_105^instrW_105_prev);
    end 
    always @ (posedge clk or posedge reset) begin 
	    if (reset) begin 
		    perf_ctr <=32'b0;
		    perf_ctr_inst <= 32'b0 ;
	    end else begin 
	    	perf_ctr <= perf_ctr + 1'b1 ; 
	    	if (instr_complete) perf_ctr_inst <= perf_ctr_inst + 1'b1 ;
    	    end 
            
    end 

   always_comb begin 
   	case(perfmonW)  
		2'b11: resultW_105 = perf_ctr_inst ; 
		2'b10: resultW_105 = resultW_105_pre;
		2'b01: resultW_105 = perf_ctr;
		2'b00: resultW_105 = resultW_105_pre;
		default: resultW_105 = resultW_105_pre;
	endcase
	
   end 
    
   endmodule


//////////////////////////////////////////////////////////////////////
// Register File Module
//////////////////////////////////////////////////////////////////////
module regfile (
    input clk,
    input we3,
    input [4:0] ra1, ra2, wa3,
    input [31:0] wd3,
    output [31:0] rd1, rd2
);
    
    logic [31:0] rf[31:0];
    // three ported register file
    // read two ports combinationally
    // write third port on rising edge of clock
    // register 0 hardwired to 0
    always @ (posedge clk)
        if (we3) rf[wa3] <= wd3;

    assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
    assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
endmodule

//////////////////////////////////////////////////////////////////////
// ALU Module
////////////////////////////////////////////////////////////////////// 
module alu(
    input [31:0] a,          // First operand
    input [31:0] b,          // Second operand
    input [31:0] c,          // Third operand
    input [2:0] control,     // ALU control signal
    output logic [31:0] result, // ALU result
    output zero              // Zero flag
);

    // Define ALU operations based on control signal
    localparam ALU_AND = 3'b000;
    localparam ALU_OR  = 3'b001;
    localparam ALU_ADD = 3'b010;
    localparam ALU_SUB = 3'b110;
    localparam ALU_SLT = 3'b111;
    localparam ALU_MULADD = 3'b011;
    
    
    // Calculate result based on control input
    always @(*) begin
        case(control)
            ALU_AND: result = a & b;                     // AND
            ALU_OR:  result = a | b;                     // OR
            ALU_ADD: result = a + b;                     // ADD
            ALU_SUB: result = a - b;                     // SUB
            ALU_SLT: result = ($signed(a) < $signed(b)); // Set Less Than (signed)
	    ALU_MULADD: result = a*c+b;              // MULADD
            default: result = 32'bx;                     // Undefined operation
        endcase
    end
    
    // Set zero flag when result is 0
    assign zero = (result == 32'b0);
    
endmodule


//////////////////////////////////////////////////////////////////////
// Adder Module
//////////////////////////////////////////////////////////////////////
module adder (
    input [31:0] a, b,
    output [31:0] y
);
    assign y = a + b;
endmodule


//////////////////////////////////////////////////////////////////////
// 2-to-1 Multiplexer Module
//////////////////////////////////////////////////////////////////////
module mux2 # (parameter WIDTH = 8) (
    input [WIDTH-1:0] d0, d1,
    input s,
    output [WIDTH-1:0] y
);
    assign y = s ? d1 : d0;
endmodule


//////////////////////////////////////////////////////////////////////
// Shift Left by 2 Module
//////////////////////////////////////////////////////////////////////
module sl2 (
    input [31:0] a,
    output [31:0] y
);
    // shift left by 2
    assign y = {a[29:0], 2'b00};
endmodule


//////////////////////////////////////////////////////////////////////
// Sign Extension Module
//////////////////////////////////////////////////////////////////////
module signext (
    input [15:0] a,
    output [31:0] y
);
    assign y = {{16{a[15]}}, a};
endmodule


//////////////////////////////////////////////////////////////////////
// Flop Register Module
//////////////////////////////////////////////////////////////////////
module flopr # (parameter WIDTH = 8)(
    input clk, reset,stallF,
    input [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
    always @ (posedge clk, posedge reset)
        if (reset) q <= 0;

	else begin 
		case(stallF)
	       	1'bx: q <= d;
		1'b0: q<=d;
		1'b1: q<=q;
	endcase
	end
endmodule
