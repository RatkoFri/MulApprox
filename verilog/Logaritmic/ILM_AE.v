`timescale 1ns / 1ps

module ILM_AE(
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
	wire [16:0] kx;
	wire zero_x;
	wire [4:0] code_x;


	NOD16 NODx (
		.data_i(x_abs),
		.zero_o(zero_x),
		.data_o(kx)
	 ); 
	 

	PriorityEncoder_16 PEx (
		.data_i(kx),
		.code_o(code_x)
	 ); 
	 
	// LOD y

	wire [16:0] ky;
	wire zero_y;
	wire [4:0] code_y;

	NOD16 NODy (
		.data_i(y_abs),
		.zero_o(zero_y),
		.data_o(ky)
	 ); 

	PriorityEncoder_16 PEy (
			.data_i(ky),
			.code_o(code_y)
		 ); 

	// Subtractor 
	wire [16:0] sub_x;
	wire [16:0] tmp_x;
	assign tmp_x = {1'b0,x_abs};
	assign sub_x = tmp_x - kx;	
	
 
	wire [16:0] sub_y;
	wire [16:0] tmp_y;
	assign tmp_y = {1'b0,y_abs};
	assign sub_y = tmp_y - ky;	
	
	// Add k_x and k_y
	wire [6:0] code_sum;
	assign code_sum = code_x + code_y;

	// decoder 
	wire [31:0] dec_out;
	Decoder32 dec(code_sum,dec_out);

	// shifter sub_x and ky
	wire [31:0] pp_x;
	assign pp_x = sub_x << code_y;

	// shifter sub_x and ky
	wire [31:0] pp_y;
	assign pp_y = sub_y << code_x;
	 
	// shigfter
	wire [31:0] tmp_pp;
	wire [31:0] pp_abs;
	assign tmp_pp = sub_x + sub_y + dec_out;

	assign pp_abs = {tmp_pp[31:12],1'b0,1'b1,1'b0,1'b1,1'b0,1'b1,1'b0,1'b1,1'b0,1'b1,1'b0};
	// xor 
	wire prod_sign; 

	wire [31:0] tmp_sign;
	
	assign prod_sign = x[15] ^ y[15];
	assign tmp_sign = {32{prod_sign}} ^ pp_abs;
	
	// is zero 
	wire not_zero;
	assign not_zero = (~zero_x | x[15] | x[0]) & (~zero_y | y[15] | y[0]);
	
	assign p = not_zero ? tmp_sign : 32'b0;
	
endmodule



module PriorityEncoder_16(
    input [16:0] data_i,
    output [4:0] code_o
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

	assign code_o[4] = data_i[16];
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



module NOD16(
    input [15:0] data_i,
    output zero_o,
    output [16:0] data_o
    );

	assign data_o[16] = data_i[15] & data_i[14];

	NOD_unit_basic nod_basic_unit15(.in0(data_i[15]),.in1(data_i[14]),.in2(data_i[13]),.out0(data_o[15]));

	wire [14:0] t_in;
	assign t_in[14] = 1'b1;
	// Bits from 14 to 2
	genvar i;
    generate
        for ( i = 2; i < 15; i = i+1 )
            begin : nod_cels
            NOD_unit Nod_bits(.data_i(data_i[i+1:i-2]),.t_in(t_in[i]),.data_o(data_o[i]),.t_out(t_in[i-1]));
            end
    endgenerate

	assign t_in[0] =  t_in[1] & ~data_i[2];

	assign data_o[1] = t_in[0] & data_i[1] & ~data_i[0];

	assign data_o[0] = t_in[0] & ~data_i[1] & data_i[0];

	assign zero_o = ~|(data_i);
endmodule

module NOD_unit_basic(
	input in0,
	input in1,
	input in2,
	output out0
	);

	wire tmp1,tmp2,tmp3;
	assign tmp1 = in0 & ~in1;
	assign tmp2 = in1 & in2 &(~in0);
	assign out0 = tmp1 | tmp2;

endmodule 

module NOD_unit(
	input [3:0] data_i,
	input t_in,
	output data_o,
	output t_out
	);

	wire tmp1,t_wire;
	NOD_unit_basic nod_basic_unit(.in0(data_i[2]),.in1(data_i[1]),.in2(data_i[0]),.out0(tmp1));

	assign t_wire = ~data_i[3] & t_in;
	assign t_out = t_wire;
	assign data_o = t_wire & tmp1;

endmodule 

module Decoder32(
    input [6:0] code_i,
    output [31:0] data_o
    );
	 
	assign data_o = (1 << code_i);
endmodule

module FAd(a,b,c,cy,sm);
	input a,b,c;
	output cy,sm;
	wire x,y,z;
	xor x1(x,a,b);
	xor x2(sm,x,c);
	and a1(y,a,b);
	and a2(z,x,c);
	or o1(cy,y,z);
endmodule


