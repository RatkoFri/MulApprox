
// Calculates P = X*Y = X1*Y*2^14 + X0*Y1*2^14 + X0*Y0
// X1 = x[15:13], X0 = x[13:0]
// Y1 = y[15:13], Y0 = y[13:0]

module HRALM4(
    input [15:0] x,
    input [15:0] y,
    output [31:0] p
    );
    
    wire  sign_factor;
    wire [16:0] PP_1;
    wire [29:0] PP_0;
    
// Calculates PP_2 = Y*X1
    PP_1_gen High(
        .x1(x[15:13]),
        .y(y),
        .sign_factor(sign_factor),
        .PP(PP_1)
        );

// Calculates PP_0 = X0*YO
    PP_0_gen Low(
        .x0(x[13:0]),
        .y0(y),
        .PP(PP_0)
        );

// Partial product addition 
    wire [17:0] tmp1_add;
    wire [17:0] tmp2_add;
    wire [17:0] tmp_sum;

    assign tmp1_add = {PP_0[29],PP_0[29],PP_0[29:14]};
    assign tmp2_add = {PP_1[16],PP_1};
    
    //assign tmp_sum = tmp1_add + tmp2_add;
    wire [1:0] carry_adder;
    wire [1:0] sum_adder;
    
    FAd add0(tmp1_add[0],tmp2_add[0],sign_factor,carry_adder[0],tmp_sum[0]);
    FAd add1(tmp1_add[1],tmp2_add[1],carry_adder[0],carry_adder[1],tmp_sum[1]);
    
    adder16 ADDER(tmp1_add[17:2],tmp2_add[17:2],carry_adder[1],tmp_sum[17:2]);
    
    assign p = {tmp_sum,PP_0[13:0]};

        
endmodule

// Calculates PP_2 = Y*X1
module PP_1_gen(
    input [2:0] x1,
    input [15:0] y,
    output sign_factor,
    output [16:0] PP
    );
    
    // encode 
    wire one, two, sign;
    
    code encode_block(
        .one(one),
        .two(two),
        .sign(sign),
        .y2(x1[2]),
        .y1(x1[1]),
        .y0(x1[0])
        );
        
    // generation of PP
    wire [16:0] tmp1_pp; 
    assign tmp1_pp = {y[15],y}; // This variable is introduced because pp has 17 bits
    
    wire [17:0] out1;
    assign out1[0] = sign;
    
    genvar i;
    generate
        for ( i = 0; i < 17; i = i+1 )
            begin : pp_rad4_first 
            product pp_pr(tmp1_pp[i],out1[i],one,two,sign,PP[i],out1[i+1]);
            end
    endgenerate
    
    //sign factor generate
    sgn_gen sign_gen(one,two,sign,sign_factor);
       

endmodule
 

//encoding


module code(one,two,sign,y2,y1,y0);  
	input y2,y1,y0;                     
	output one,two,sign;                
	wire [1:0]k;                        
	xor x1(one,y0,y1);                  
	xor x2(k[1],y2,y1);                 
	not n1(k[0],one);                   
	and a1(two,k[0],k[1]);              
	assign sign=y2;                     
endmodule       
    
//generation of inner products

module product(x1,x0,one,two,sign,p,i);
	input x1,x0,sign,one,two;
	output p,i;
	wire [1:0] k;
	xor xo1(i,x1,sign);
	and a1(k[1],i,one);
	and a0(k[0],x0,two);
	or o1(p,k[1],k[0]);
endmodule

//sign_factor generate

module sgn_gen(one,two,sign,sign_factor);
    input sign,one,two;
    output sign_factor;
    wire k;
    or o1(k,one,two);
    and a1(sign_factor,sign,k);
endmodule



// Calculates PP_0 = Y0*X0    
module PP_0_gen(
    input signed [13:0] x0,
    input signed [15:0] y0,
    output signed [29:0] PP
    );
    
    // X branch 

    // First complement 
    wire [13:0] x0_abs;
    assign x0_abs = x0 ^ {14{x0[13]}};
    
    // LOD + Priority Encoder
    wire [15:0] k_x0;
    wire [15:0] tmp_abs;
    wire zero_x0;
    wire [3:0] k_x0_enc;

    assign tmp_abs = {2'b0,x0_abs};

    LOD16 lod_x0(
        .data_i(tmp_abs),
        .zero_o(zero_x0),
        .data_o(k_x0),
        .data_enc(k_x0_enc));
        
    // LBarrel 
    wire [3:0] x_shift;
    wire [3:0] neg_kx;
    assign neg_kx = ~ k_x0_enc;
    LBarrel Lshift_x0(
        .data_i(tmp_abs),
        .shift_i(neg_kx),
        .data_o(x_shift));
        
    // Y branch 
    
    // First complement 
    wire [15:0] y0_abs;
    assign y0_abs = y0 ^ {16{y0[15]}};
    
    // LOD + Priority Encoder
    wire [15:0] k_y0;
    wire zero_y0;
    wire [3:0] k_y0_enc;
    
    LOD16 lod_y0(
        .data_i(y0_abs),
        .zero_o(zero_y0),
        .data_o(k_y0),
        .data_enc(k_y0_enc));
        
    // LBarrel 
    wire [3:0] y_shift;
    wire [3:0] neg_ky;
    assign neg_ky = ~ k_y0_enc;
    LBarrel Lshift_y0(
        .data_i(y0_abs),
        .shift_i(neg_ky),
        .data_o(y_shift));
        
    
    // Addition 
    wire [8:0] x_log;
    wire [8:0] y_log;
    wire [8:0] p_log;
    
    assign x_log = {1'b0,k_x0_enc,x_shift};
    assign y_log = {1'b0,k_y0_enc,y_shift};

    
    assign p_log = x_log + y_log;
    
    // Antilogarithm 
    
    // L1 barell shifter 
    wire [20:0] p_l1b;
    wire [4:0] l1_input;
    
    assign l1_input = {1'b1,p_log[3:0]};
   
    L1Barrel L1shift_plog(
        .data_i(l1_input),
        .shift_i(p_log[7:4]),
        .data_o(p_l1b));
    
   
    // Low part of product 
 
    wire [29:0] PP_abs;
    assign PP_abs = p_log[8] ? p_l1b[20:4] << 16 :  p_l1b[20:4];
    

    // Sign conversion 
    wire p_sign;
    wire [29:0] PP_temp;
    
    
    assign p_sign = x0[13] ^ y0[15];
    assign PP_temp = PP_abs ^ {30{p_sign}};
    
    //Zero mux0
    wire notZeroA, notZeroB, notZeroD;
    assign notZeroA = ~zero_x0;
    assign notZeroB = ~zero_y0;
    assign notZeroD = notZeroA & notZeroB;
    
    assign PP = notZeroD? PP_temp : 30'b0;
    
endmodule

module LOD16(
    input [15:0] data_i,
    output zero_o,
    output [15:0] data_o,
    output [3:0] data_enc
    );
	
    wire [15:0] z;
	wire [3:0] zdet;
	wire [3:0] select;
	//*****************************************
	// Zero detection logic:
	//*****************************************
	assign zdet[3] = |(data_i[15:12]);
	assign zdet[2] = |(data_i[11:8]);
	assign zdet[1] = |(data_i[7:4]);
	assign zdet[0] = |(data_i[3:0]);
	assign zero_o =  ~(|zdet);
    //*****************************************
	// LODs:
	//*****************************************
	LOD4 lod4_1 (
		.data_i(data_i[3:0]), 
		.data_o(z[3:0])
	);
	 
    LOD4 lod4_2 (
        .data_i(data_i[7:4]), 
        .data_o(z[7:4])
        );
         
    LOD4 lod4_3 (
        .data_i(data_i[11:8]), 
        .data_o(z[11:8])
    );
    LOD4 lod2_4 (
        .data_i(data_i[15:12]), 
        .data_o(z[15:12])
    );
	//*****************************************
    // Select signals
    //*****************************************    
    LOD4 lod4_5 (
            .data_i(zdet), 
            .data_o(select)
        );
	//*****************************************
	// Multiplexers :
	//*****************************************
	wire [15:0] tmp_out;

	Muxes2in1Array4 Inst_MUX214_3 (
         .data_i(z[15:12]), 
         .select_i(select[3]), 
         .data_o(tmp_out[15:12])
     );
	 
	Muxes2in1Array4 Inst_MUX214_2 (
        .data_i(z[11:8]), 
        .select_i(select[2]), 
        .data_o(tmp_out[11:8])
    );

	 
	 Muxes2in1Array4 Inst_MUX214_1 (
        .data_i(z[7:4]), 
        .select_i(select[1]), 
        .data_o(tmp_out[7:4])
    );

	 Muxes2in1Array4 Inst_MUX214_0 (
		.data_i(z[3:0]), 
		.select_i(select[0]), 
		.data_o(tmp_out[3:0])
    );


    // Enconding
    wire [2:0] low_enc; 
    assign low_enc = tmp_out[3:1] | tmp_out[7:5] | tmp_out[11:9] | tmp_out[15: 13];

    assign data_enc[3] = select[3] | select[2];
    assign data_enc[2] = select[3] | select[1];
    assign data_enc[1] = low_enc[2] | low_enc[1];
    assign data_enc[0] = low_enc[2] | low_enc[0];


    // One hot
    assign data_o = tmp_out;

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

module LOD2(
    input [1:0] data_i,
    output [1:0] data_o
    );
	 
	 
	 //gates and IO assignments:
	 assign data_o[1] = data_i[1];
	 assign data_o[0] =(~data_i[1] & data_i[0]);
	 

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

module Muxes2in1Array2(
    input [1:0] data_i,
    input select_i,
    output [1:0] data_o
    );
    

	assign data_o[1] = select_i ? data_i[1] : 1'b0;
	assign data_o[0] = select_i ? data_i[0] : 1'b0;
	
endmodule


module LBarrel(
    input [15:0] data_i,
    input [3:0] shift_i,
    output [3:0] data_o);
    
    reg [15:0] tmp;
    always @*
        case (shift_i)
           4'b0000: tmp = data_i;
           4'b0001: tmp = data_i << 1;
           4'b0010: tmp = data_i << 2;
           4'b0011: tmp = data_i << 3;
           4'b0100: tmp = data_i << 4;
           4'b0101: tmp = data_i << 5;
           4'b0110: tmp = data_i << 6;
           4'b0111: tmp = data_i << 7;
           4'b1000: tmp = data_i << 8;
           4'b1001: tmp = data_i << 9;
           4'b1010: tmp = data_i << 10;
           4'b1011: tmp = data_i << 11;
           4'b1100: tmp = data_i << 12;
           4'b1101: tmp = data_i << 13;
           4'b1110: tmp = data_i << 14;
           default: tmp = data_i << 15;
        endcase
    
    assign data_o[3:1] = tmp[14:12];
    assign data_o[0] = 1'b1;

endmodule

module L1Barrel(
    input [4:0] data_i,
    input [3:0] shift_i,
    output reg [20:0] data_o);
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

module RBarell(
    input [1:0] data_i,
    input [1:0] shift_i,
    output [2:0] data_o);

    assign data_o[2] = ~(shift_i[0] | shift_i[1]);
    assign data_o[1] = ~shift_i[1] | (data_i[1] & ~shift_i[0]);
    assign data_o[0] = (~shift_i[0] & data_i[0]) | (~shift_i[0] & shift_i[1]) | (~shift_i[1] & shift_i[0] & data_i[1]);
       
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

module HAd(a,b,cy,sm);
	input a,b;
	output cy,sm;
	assign cy = a & b;
	assign sm = a ^ b;
endmodule 

module adder16(X,Y,carry_in,Z);
	input [15:0]X;
	input [15:0]Y;
	input carry_in;
	output [15:0]Z;
	wire c[3:1];


	adder4 A1(Z[3:0],c[1],X[3:0],Y[3:0],carry_in);
	adder4 A2(Z[7:4],c[2],X[7:4],Y[7:4],c[1]);
	adder4 A3(Z[11:8],c[3],X[11:8],Y[11:8],c[2]);
	adder4 A4(Z[15:12],Carry,X[15:12],Y[15:12],c[3]);
endmodule

module adder4(Sum,Cout,A,B,Cin);
	input [3:0]A,B;
	input Cin;
	output [3:0]Sum;
	output Cout;
	wire c[3:1], p[3:0], g[3:0];

	assign p[0]=A[0]^B[0], p[1]=A[1]^B[1], p[2]=A[2]^B[2], p[3]=A[3]^B[3];
	assign g[0]=A[0]&B[0], g[1]=A[1]&B[1], g[2]=A[2]&B[2], g[3]=A[3]&B[3];

	assign c[1]=g[0] | (p[0]&Cin);
	assign c[2]=g[1] | (p[1]&g[0]) | (p[1]&p[0]&Cin);
	assign c[3]=g[2] | (p[2]&g[1]) | (p[2]&p[1]&g[0]) | (p[2]&p[1]&p[0]&Cin);
	assign Cout=g[3] | (p[2]&g[2]) | (p[3]&p[2]&g[1]) | (p[3]&p[2]&p[1]&g[0]) | (p[3]&p[2]&p[1]&p[0]&Cin);

	assign Sum[0]=p[0]^Cin, Sum[1]=p[1]^c[1], Sum[2]=p[2]^c[2], Sum[3]=p[3]^c[3];
endmodule
