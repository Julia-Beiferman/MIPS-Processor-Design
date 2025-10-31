//////////////////////////////////////////////////////////////////////
// ===================================================================
// This file has the following module implementations:
// 1. controller
// 2. maindec
// 3. aludec
// ===================================================================
//////////////////////////////////////////////////////////////////////
// Controller module
//////////////////////////////////////////////////////////////////////
module controller (
    input clk, reset,
    input [5:0] op, funct,
    input zero,
    output memtoreg, memwrite,
    output pcsrc, alusrc,
    output regdst, regwrite,
    output jump,input stallD,
    output [2:0] alucontrol, output memtoregE_103, output stall_state, output stallDMUL, perfmon_type, perfmon_en
);
    logic [1:0] aluop;
    logic branch;
    logic memwrite_in, memwriteD_102, memwriteE_103, memwriteM_104;
    logic regwrite_in, regwriteD_102, regwriteE_103, regwriteM_104, regwriteW_105;
    logic memtoreg_in, memtoregD_102, memtoregE_103, memtoregM_104, memtoregW_105; 
    logic branch_in, branchD_102, branchE_103, branchM_104; 
    logic [2:0] alucontrol_in, alucontrolD_102, alucontrolE_103;
    logic alusrc_in, alusrcD_102, alusrcE_103; 
    logic regdst_in, regdstD_102, regdstE_103; 

    
    assign memwrite =memwriteM_104;
    assign alucontrol = alucontrolE_103;
    assign regdst = regdstE_103 ; 
    assign alusrc = alusrcE_103;
     assign regwrite = regwriteW_105; 
     assign memtoreg = memtoregW_105;

logic [5:0] opD_102, functD_102;
    always @ (posedge clk or posedge reset) begin 
    if (reset) begin 
    	opD_102 <= 6'b0;
	functD_102 <= 6'b0;
    end else begin
	    case(stallD) 
		    1'bx: begin 
		    		opD_102 <= op ; 
				functD_102 <=funct; 
			end
			1'b0: begin
				opD_102 <= op ; 
				functD_102 <=funct;
			end	
	    endcase
    end
   end 

    logic stall_state, stallDMUL;
    wire is_muladd = (op == 6'b000000 && funct == 6'b011001);

    assign stallDMUL = is_muladd && !stall_state;

    always_ff @(posedge clk or posedge reset) begin
      	if (reset)
        	stall_state <= 1'b0;
      	else if (stallDMUL)
        	 stall_state <= 1'b1;
        else
        	stall_state <= 1'b0;
     end

	assign memwriteD_102 = memwrite_in;
        assign regwriteD_102   =regwrite_in;
	assign memtoregD_102    =memtoreg_in;
	assign branchD_102      =branch_in;
	assign alucontrolD_102  = alucontrol_in;
	assign alusrcD_102     = alusrc_in;
	assign regdstD_102     =regdst_in;

//    end
//    end
//
//
	logic stall_stateD_102, stall_stateE_103;
    always_ff @ (posedge clk or posedge reset) begin 
	if (reset) begin
	       	stall_stateD_102 <= 1'b0;
		stall_stateE_103 <= 1'b0;	
	end else begin 
		stall_stateD_102 <= stall_state;
		stall_stateE_103 <= stall_stateD_102;	
	end	
    end 

    always @ (posedge clk or posedge reset) begin 
    if (reset) begin 
	memwriteE_103 <= 1'b0;
	regwriteE_103   <=1'b0;
	memtoregE_103    <=1'b0;
	branchE_103      <=1'b0;
	alucontrolE_103  <= 1'b0;
	alusrcE_103     <= 1'b0;
	regdstE_103     <=1'b0;
    end else begin 
	if (!stall_stateE_103) begin
	memwriteE_103 <= memwriteD_102;
	regwriteE_103   <=regwriteD_102;
	memtoregE_103    <=memtoregD_102;
	branchE_103      <=branchD_102;
	alucontrolE_103  <= alucontrolD_102;
	alusrcE_103     <= alusrcD_102;
	regdstE_103     <=regdstD_102;
	end
    end
    end

    always @ (posedge clk or posedge reset) begin 
    if (reset) begin 
	memwriteM_104 <= 1'b0;
	regwriteM_104   <=1'b0;
	memtoregM_104    <=1'b0;
	branchM_104      <=1'b0;
    end else begin 
	memwriteM_104 <= memwriteE_103;
	regwriteM_104   <=regwriteE_103;
	memtoregM_104    <=memtoregE_103;
	branchM_104      <=branchE_103;

    end
    end

    always @ (posedge clk or posedge reset) begin 
    if (reset) begin 
	regwriteW_105   <=1'b0;
	memtoregW_105    <=1'b0;
    end else begin 
	regwriteW_105   <=regwriteM_104;
	memtoregW_105    <=memtoregM_104;

    end
    end


    maindec md (opD_102, memtoreg_in, memwrite_in, branch_in, alusrc_in, regdst_in, regwrite_in, jump, aluop,perfmon_type,perfmon_en);
    aludec ad (functD_102, aluop, alucontrol_in);
    
    assign pcsrc = branchM_104 & zero; //zero is M stage from datapath
endmodule


//////////////////////////////////////////////////////////////////////
// Main Decoder module
//////////////////////////////////////////////////////////////////////
module maindec(
    input [5:0] op,
    output memtoreg, memwrite,
    output branch, alusrc,
    output regdst, regwrite,
    output jump,
    output [1:0] aluop,output perfmon_type,perfmon_en
);

    logic [10:0] controls;
    
    assign {perfmon_type,perfmon_en,regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, aluop} = controls;

    always @ (*)
        case(op)
            6'b000000: controls <= 11'b00110000010; //Rtyp
            6'b100011: controls <= 11'b00101001000; //LW
            6'b101011: controls <= 11'b00001010000; //SW
            6'b000100: controls <= 11'b00000100001; //BEQ
            6'b001000: controls <= 11'b00101000000; //ADDI
            6'b000010: controls <= 11'b00000000100; //J
	    6'b111111: controls <= 11'b11110000000; //perfmon count cycles 
	    6'b111110: controls <= 11'b01110000000; //perfmon count instructions 
            default: controls <= 9'bxxxxxxxxx; //???
        endcase
endmodule


//////////////////////////////////////////////////////////////////////
// ALU Decoder module
//////////////////////////////////////////////////////////////////////
module aludec (
    input [5:0] funct,
    input [1:0] aluop,
    output logic [2:0] alucontrol 
);
    always @ (*)
        case (aluop)
            2'b00: alucontrol <= 3'b010; // add
            2'b01: alucontrol <= 3'b110; // sub
            default: case(funct) // RTYPE
                6'b100000: alucontrol <= 3'b010; // ADD
                6'b100010: alucontrol <= 3'b110; // SUB
                6'b100100: alucontrol <= 3'b000; // AND
                6'b100101: alucontrol <= 3'b001; // OR
                6'b101010: alucontrol <= 3'b111; // SLT
		6'b011001: alucontrol <= 3'b011; // MULADD (custom)
                default: alucontrol <= 3'bxxx; // ???
            endcase
        endcase
endmodule
