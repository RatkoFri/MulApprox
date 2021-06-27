`timescale 1ns / 1ps

module MITCH_TRUNC_W8_C2(
    input [15:0] x,
    input [15:0] y,
    output [31:0] p
    );
    
	// Generate abs values
	wire [15:0] x_abs;
	wire [15:0] y_abs;
	
	// Going for X_abs
	assign x_abs = x ^ {16{x[15]}};


	// Going for Y_abs
	assign y_abs = y ^ {16{y[15]}};

			 
	// LOD x
	wire [15:0] kx;
	wire zero_x;
	wire [3:0] code_x;


	LOD16 LODx (
		.data_i(x_abs),
		.zero_o(zero_x),
		.data_o(kx)
	 ); 
	 

	PriorityEncoder_16 PEx (
		.data_i(kx),
		.code_o(code_x)
	 ); 

	 
		
	 
	// LOD y

	wire [15:0] ky;
	wire zero_y;
	wire [3:0] code_y;

	LOD16 LODy (
		.data_i(y_abs),
		.zero_o(zero_y),
		.data_o(ky)
	 ); 

	PriorityEncoder_16 PEy (
			.data_i(ky),
			.code_o(code_y)
		 ); 
		 
	
	// Barell shift X
	
	wire [3:0] code_x_inv;
	wire [15:0] barrel_x;
	
	assign code_x_inv = ~code_x;
	
	Barrel16L BShiftx (
		.data_i(x_abs),
		.shift_i(code_x_inv),
		.data_o(barrel_x)
 	 ); 
	
	
	// Barell shift Y
	wire [3:0] code_y_inv;
	wire [15:0] barrel_y;
	
	assign code_y_inv = ~code_y;
	
	Barrel16L BShifty (
		.data_i(y_abs),
		.shift_i(code_y_inv),
		.data_o(barrel_y)
 	 );
	
	// Addition of Op1 and Op2
	// Here comes the truncation trend [15-1:16-6-1]
	wire [11:0] op1;
	wire [11:0] op2;
	wire [11:0] L;
	wire [11:0] bias;


	assign op1 = {1'b0,code_x,barrel_x[14:8]};
	assign op2 = {1'b0,code_y,barrel_y[14:8]};
	
	assign bias = {5'b0,3'b0,1'b1,3'b0};
    assign L = op1 + op2 + bias;	 
	// Anti logarithm 
	
	wire [31:0] tmp_out; 
	AntiLog_W8 anti_log(
		.data_i(L),
		.data_o(tmp_out)
	);
	
	// xor 
	wire prod_sign; 
	wire [31:0] tmp_sign;
	
	assign prod_sign = x[15] ^ y[15];
	assign tmp_sign = {32{prod_sign}} ^ tmp_out;
	
	// is zero 
	wire not_zero;
	assign not_zero = (~zero_x | x[15] | x[0]) & (~zero_y | y[15] | y[0]);
	
	assign p = not_zero ? tmp_sign : 32'b0;
	
endmodule


module AntiLog_W8(
	input [11:0] data_i,
	output [31:0] data_o
	);
	
	// L1 Barell
	wire [23:0] l1_in;
	wire [23:0] l1_out;
	assign l1_in = {16'b0,1'b1,data_i[6:0]};
	wire [4:0] tmp_l1_enc;
	wire [4:0] l1_enc;
	
	assign tmp_l1_enc = {1'b0,data_i[10:7]};
	
	
	carry_lookahead_inc INC_INST(
	        .i_add1(tmp_l1_enc),
	        .o_result(l1_enc)
	        );
	        
	
	Barrel24L L1shift (
		.data_i(l1_in),
		.shift_i(l1_enc),
		.data_o(l1_out)
 	 );
	
	// R Barell 
	wire [7:0] r_in;
	wire [7:0] r_out;
	wire [2:0] enc;
	
	assign enc = ~data_i[10:8];
	assign r_in = {1'b1,data_i[6:0]};
	
	
	Barrel8R Rshift (
		.data_i(r_in),
		.shift_i(enc),
		.data_o(r_out)
 	 );
	
	// And
	wire lr;
	wire [15:0] out_msb;
	
	assign lr = data_i[11];
	assign out_msb = {16{lr}} & l1_out[23:8];
	
	
	// mux
	wire [7:0] out_lsb;
	assign out_lsb = lr ? l1_out[7:0] : r_out[7:0];
	// concanate
	assign data_o = {out_msb,out_lsb,8'b0};
	
endmodule

module PriorityEncoder_16_old(
    input [15:0] data_i,
    output reg [3:0] code_o
    );

	always @*
		case (data_i)
	     16'b0000000000000001 : code_o = 4'b0000;
         16'b0000000000000010 : code_o = 4'b0001;
         16'b0000000000000100 : code_o = 4'b0010;
         16'b0000000000001000 : code_o = 4'b0011;
         16'b0000000000010000 : code_o = 4'b0100;
         16'b0000000000100000 : code_o = 4'b0101;
         16'b0000000001000000 : code_o = 4'b0110;
         16'b0000000010000000 : code_o = 4'b0111;
		 16'b0000000100000000 : code_o = 4'b1000;
         16'b0000001000000000 : code_o = 4'b1001;
         16'b0000010000000000 : code_o = 4'b1010;
         16'b0000100000000000 : code_o = 4'b1011;
         16'b0001000000000000 : code_o = 4'b1100;
         16'b0010000000000000 : code_o = 4'b1101;
         16'b0100000000000000 : code_o = 4'b1110;
         16'b1000000000000000 : code_o = 4'b1111;
			
			default     : code_o = 4'b0000;
		endcase
		
endmodule

module PriorityEncoder_16(
    input [15:0] data_i,
    output [3:0] code_o
    );
    
    wire [7:0] tmp0;
    assign tmp0 = {data_i[15],data_i[13],data_i[11],data_i[9],data_i[7],data_i[5],data_i[3],data_i[1]};
    OR_tree code0(tmp0,code_o[0]);
    
    wire [7:0] tmp1;
    assign tmp1 = {data_i[15],data_i[14],data_i[11],data_i[10],data_i[7],data_i[6],data_i[3],data_i[2]};
    OR_tree code1(tmp1,code_o[1]);
    
    wire [7:0] tmp2;
    assign tmp2 = {data_i[15],data_i[14],data_i[13],data_i[12],data_i[7],data_i[6],data_i[5],data_i[4]};
    OR_tree code2(tmp2,code_o[2]);
    
    wire [7:0] tmp3;
    assign tmp3 = {data_i[15],data_i[14],data_i[13],data_i[12],data_i[11],data_i[10],data_i[9],data_i[8]};
    OR_tree code3(tmp3,code_o[3]);
endmodule


module OR_tree(
    input [7:0] data_i,
    output data_o
    );
    
    wire [3:0] tmp1;
    wire [1:0] tmp2;
    
    assign tmp1 = data_i[3:0] | data_i[7:4];
    assign tmp2 = tmp1[1:0] | tmp1[3:2];
    assign data_o = tmp2[0] | tmp2[1];
endmodule


module LOD4(
    input [3:0] data_i,
    output [3:0] data_o
    );
	 
	 
	 wire mux0;
	 wire mux1;
	 wire mux2;
	 
	 // multiplexers:
	 assign mux2 = (data_i[3]==1) ? 1'b0 : 1'b1;
	 assign mux1 = (data_i[2]==1) ? 1'b0 : mux2;
	 assign mux0 = (data_i[1]==1) ? 1'b0 : mux1;
	 
	 //gates and IO assignments:
	 assign data_o[3] = data_i[3];
	 assign data_o[2] =(mux2 & data_i[2]);
	 assign data_o[1] =(mux1 & data_i[1]);
	 assign data_o[0] =(mux0 & data_i[0]);
	 

endmodule

module Muxes2in1Array4(
    input [3:0] data_i,
    input select_i,
    output [3:0] data_o
    );


	assign data_o[3] = select_i ? data_i[3] : 1'b0;
	assign data_o[2] = select_i ? data_i[2] : 1'b0;
	assign data_o[1] = select_i ? data_i[1] : 1'b0;
	assign data_o[0] = select_i ? data_i[0] : 1'b0;
	
	
endmodule



module LOD16(
    input [15:0] data_i,
    output zero_o,
    output [15:0] data_o
    );
	 
	 wire [15:0] z;
	 wire [3:0] select;
	 wire [3:0] zdet;
	 
	 
	 
	 
	 
	 //*****************************************
	 // Zero detection logic:
	 //*****************************************
	 assign zdet[3] = data_i[15] | data_i[14] | data_i[13] | data_i[12];
	 assign zdet[2] = data_i[11] | data_i[10] | data_i[9] | data_i[8];
	 assign zdet[1] = data_i[7] | data_i[6] | data_i[5] | data_i[4];
	 assign zdet[0] = data_i[3] | data_i[2] | data_i[1] | data_i[0];
	 assign zero_o = ~(zdet[3] | zdet[2] | zdet[1] | zdet[0]);
		 
		 
	 //*****************************************
	 // LODs:
	 //*****************************************
	 LOD4 lod4_3 (
		.data_i(data_i[15:12]), 
		.data_o(z[15:12])
	 );
	 
	 LOD4 lod4_2 (
		.data_i(data_i[11:8]), 
		.data_o(z[11:8])
	 );

	 LOD4 lod4_1 (
		.data_i(data_i[7:4]), 
		.data_o(z[7:4])
	 );
	 
	 LOD4 lod4_0 (
		.data_i(data_i[3:0]), 
		.data_o(z[3:0])
	 );
	 
	 LOD4 lod4_middle (
		.data_i(zdet), 
		.data_o(select)
	 );
	 
	 
	 //*****************************************
	 // Multiplexers :
	 //*****************************************
	 
	 Muxes2in1Array4 Inst_MUX214_3 (
		.data_i(z[15:12]), 
		.select_i(select[3]), 
		.data_o(data_o[15:12])
    );
	 
	 Muxes2in1Array4 Inst_MUX214_2 (
		.data_i(z[11:8]), 
		.select_i(select[2]), 
		.data_o(data_o[11:8])
    );
	 
	 Muxes2in1Array4 Inst_MUX214_1 (
		.data_i(z[7:4]), 
		.select_i(select[1]), 
		.data_o(data_o[7:4])
    );
	 
	 Muxes2in1Array4 Inst_MUX214_0 (
		.data_i(z[3:0]), 
		.select_i(select[0]), 
		.data_o(data_o[3:0])
    );


endmodule


module Barrel16L(
    input [15:0] data_i,
    input [3:0] shift_i,
    output reg [15:0] data_o
    );
	 
   
   always @*
      case (shift_i)
         4'b0000: data_o = data_i;
         4'b0001: data_o = data_i << 1;
         4'b0010: data_o = data_i << 2;
         4'b0011: data_o = data_i << 3;
         4'b0100: data_o = data_i << 4;
         4'b0101: data_o = data_i << 5;
         4'b0110: data_o = data_i << 6;
         4'b0111: data_o = data_i << 7;
         4'b1000: data_o = data_i << 8;
         4'b1001: data_o = data_i << 9;
         4'b1010: data_o = data_i << 10;
         4'b1011: data_o = data_i << 11;
         4'b1100: data_o = data_i << 12;
         4'b1101: data_o = data_i << 13;
         4'b1110: data_o = data_i << 14;
         default: data_o = data_i << 15;
      endcase
endmodule


module Barrel8R(
    input [7:0] data_i,
    input [2:0] shift_i,
    output reg [7:0] data_o
    );
   
   always @*
      case (shift_i)
         3'b000: data_o = data_i;
         3'b001: data_o = data_i >> 1;
         3'b010: data_o = data_i >> 2;
         3'b011: data_o = data_i >> 3;
         3'b100: data_o = data_i >> 4;
         3'b101: data_o = data_i >> 5;
         3'b110: data_o = data_i >> 6;
         default: data_o = data_i << 7;
      endcase
endmodule

module Barrel24L(
    input [23:0] data_i,
    input [4:0] shift_i,
    output reg [23:0] data_o
    );
	 
   
   always @*
      case (shift_i)
         5'b00000: data_o = data_i;
         5'b00001: data_o = data_i << 1;
         5'b00010: data_o = data_i << 2;
         5'b00011: data_o = data_i << 3;
         5'b00100: data_o = data_i << 4;
         5'b00101: data_o = data_i << 5;
         5'b00110: data_o = data_i << 6;
         5'b00111: data_o = data_i << 7;
         5'b01000: data_o = data_i << 8;
         5'b01001: data_o = data_i << 9;
         5'b01010: data_o = data_i << 10;
         5'b01011: data_o = data_i << 11;
         5'b01100: data_o = data_i << 12;
         5'b01101: data_o = data_i << 13;
         5'b01110: data_o = data_i << 14;
         5'b01111: data_o = data_i << 15;
         default:  data_o = data_i << 16;
      endcase


endmodule


module carry_lookahead_inc
  (
   input [4:0] i_add1,
   output [4:0]  o_result
   );
     
  wire [5:0]     w_C;
  wire [4:0]   w_SUM;
 
  // Create the HA Adders
  genvar  ii;
  generate 
    for (ii=0; ii<5; ii=ii+1) 
      begin: oncetold
         assign w_SUM[ii] = i_add1[ii] ^ w_C[ii];
      end
  endgenerate
 
  // Create the Generate (G) Terms:  Gi=Ai*Bi
  // Create the Propagate Terms: Pi=Ai+Bi
  // Create the Carry Terms:
  genvar jj;
  generate
    for (jj=0; jj<5; jj=jj+1) 
      begin : somebody
        assign w_C[jj+1] = (i_add1[jj] & w_C[jj]);
      end
  endgenerate
   
  assign w_C[0] = 1'b1; // Input carry is 1
 
  assign o_result =  w_SUM;   // Verilog Concatenation
 
endmodule // carry_lookahead_adder


