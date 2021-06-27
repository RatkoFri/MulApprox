// Th = 8, Ts = 6
module LOBO_10_8_6(
    input [15:0] x,
    input [15:0] y,
    output [31:0] p
    );

// Radix 4 pp
// Generate pp

// Radix 4 pp

wire [16:0] pp_rad4_0;
wire [16:0] pp_rad4_1;
wire [16:0] pp_rad4_2;
wire [2:0] sign_factor;

rad4_gen rad4_gen1( 
	.x1(x[15:9]), .y(y),
	.pp_rad4_0(pp_rad4_0),
	.pp_rad4_1(pp_rad4_1),
	.pp_rad4_2(pp_rad4_2),
	.sign_factor(sign_factor));
	
// Radix 1024 pp 

wire [16:0] PP_oa;
wire [24:0] PP_ob;

rad1024_gen_LOBO rad1024_gen_v1( 
  .x2(x[9:0]),.y(y),
  .PP_oa(PP_oa),
  .PP_ob(PP_ob));
 
// Tree
pp_tree_red_v2 wallace_tree_quant(
	.pp_rad4_0(pp_rad4_0),
	.pp_rad4_1(pp_rad4_1),
	.pp_rad4_2(pp_rad4_2),
	.PP_oa(PP_oa),
        .PP_ob(PP_ob),
        .sign_factor(sign_factor),
	.p(p));

endmodule 

// Radix 4 gen


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

// like on the picture

module rad4_gen( x1,y,pp_rad4_0,pp_rad4_1,pp_rad4_2,sign_factor);
    // inputs
    // y multiplicand
    // x multipland 
    // P1,P2,P3 partial products
    input [15:0] y;
    input [6:0] x1;
    // output
    output [16:0] pp_rad4_0;
    output [16:0] pp_rad4_1;
    output [16:0] pp_rad4_2;
    output [2:0] sign_factor;
   
    wire [2:0] one,two,sign;
    
    code code0(one[0],two[0],sign[0],x1[2],x1[1], x1[0]);
    code code1(one[1],two[1],sign[1],x1[4],x1[3], x1[2]);
    code code2(one[2],two[2],sign[2],x1[6],x1[5], x1[4]);

    
    wire [16:0] tmp1_pp; 
    assign tmp1_pp = {y[15],y}; // This variable is introduced because pp has 17 bits
    
    // first pp generation 
    wire [17:0] out1;
    assign out1[0] = sign[0];
    
    genvar i;
    generate
        for ( i = 0; i < 17; i = i+1 )
            begin : pp_rad4_first 
            product pp_pr(tmp1_pp[i],out1[i],one[0],two[0],sign[0],pp_rad4_0[i],out1[i+1]);
            end
    endgenerate
    
    // second pp generation 
    wire[17:0] out2;
    assign out2[0] = sign[1];
    
    
    genvar i2;
    generate
        for ( i2 = 0; i2 < 17; i2 = i2+1 )
            begin : pp_second 
            product pp_pr(tmp1_pp[i2],out2[i2],one[1],two[1],sign[1],pp_rad4_1[i2],out2[i2+1]);
            end
    endgenerate
    
    // third pp generation 
    wire [17:0] out3;
    assign out3[0] = sign[2];
    
    genvar i3;
    generate
        for ( i3 = 0; i3 < 17; i3 = i3+1 )
            begin : pp_third 
            product pp_pr(tmp1_pp[i3],out3[i3],one[2],two[2],sign[2],pp_rad4_2[i3],out3[i3+1]);
            end
    endgenerate
    
    
    genvar i_sign;
    generate
        for ( i_sign = 0; i_sign < 3; i_sign = i_sign+1 )
            begin : sgn_fac
            sgn_gen sgn_genXX(one[i_sign],two[i_sign],sign[i_sign],sign_factor[i_sign]);
            end
    endgenerate

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

// like on the picture

//sign_factor generate




//sign_factor generate

module sgn_gen(one,two,sign,sign_factor);
	input sign,one,two;
	output sign_factor;
	wire k;
	or o1(k,one,two);
	and a1(sign_factor,sign,k);
endmodule

// Rad1024 gen


module rad1024_gen_LOBO(x2,y,PP_oa,PP_ob);
// inputs
// y multiplicand
// x multipland 
// P0a -> x,P0b -> partial products
input [15:0] y;
input [9:0] x2;

// output
output [16:0] PP_oa;
output [24:0] PP_ob;

// LOD detection X
// First calculate abs(x2)
// then apply LOD

wire [9:0] abs_x2;
wire [4:0] k_x2;
wire [2:0] k_x_enc;
wire zero_x2;


one_complement_w10 x0_abs_gen
		(
            .data_in(x2), 
            .sign(x2[9]),
            .data_out(abs_x2) 
        );
		  
LOD10_quant lod_x_2(abs_x2,zero_x2,k_x2);

PriorityEncoder_5 enc_kx(
            .data_i(k_x2),
            .code_o(k_x_enc));
    


// LOD detection Y
wire [7:0] k_y;
wire [2:0] k_y_enc;
wire [15:0] y_abs;
wire zero_y;
		  
one_complement_w16 y_abs_gen 
		(
            .data_in(y), 
            .sign(y[15]),
            .data_out(y_abs) 
        );	

LOD16_quant lod_y(y_abs[15:8],zero_y,k_y);

PriorityEncoder_8 enc_ky(
            .data_i(k_y),
            .code_o(k_y_enc));

				
// Reset bit on k_x position of X and invert it i
wire [9:0] x20; // value after bit reset


assign x20[9:6] =  abs_x2[9:6] & (~(k_x2[4:1]));
assign x20[5:1] =  abs_x2[5:1];
assign x20[0] =  abs_x2[0] & (~(k_x2[0]));

// generation of P0a and P0b
wire prod_sign;
wire [9:0] tmp_out0;
wire [15:0] tmp_out1;

wire [9:0] x20_signed;
wire [15:0] y_signed;

assign prod_sign = x2[9] ^ y[15];


one_complement_w10 x20_sign_gen 
		(
            .data_in(x20), 
            .sign(prod_sign),
            .data_out(tmp_out0) 
        );

		  
one_complement_w16 y_sign_gen 
		(
            .data_in(y_abs), 
            .sign(prod_sign),
            .data_out(tmp_out1) 
        );



assign y_signed = (!zero_x2 ) ? tmp_out1 : 16'b0;			
assign x20_signed = (!zero_y) ? tmp_out0 : 10'b0;

Barrel27L_10_quant gen_P0b(
	     .shift_i(k_x_enc),
             .data_i(y_signed),
             .data_o(PP_ob));
						  
Barrel17L_16 gen_P0a(
            .data_i(x20_signed),
            .shift_i(k_y_enc),
            .data_o(PP_oa));
				
//assign tmp_out0 = tmp_neg0 ^ {27{prod_sign}};
//assign tmp_out1 = tmp_neg1 ^ {27{prod_sign}};



endmodule 

module LOD16_quant(
    input [7:0] data_i,
    output zero_o,
    output [7:0] data_o
    );
	 
	 wire [7:0] z;
	 wire [1:0] select;
	 wire [1:0] zdet;
	 
	 //*****************************************
	 // Zero detection logic:
	 //*****************************************
	 assign zdet[1] = data_i[7] | data_i[6] | data_i[5] | data_i[4];
	 assign zdet[0] = data_i[3] | data_i[2] | data_i[1] | data_i[0];
	 assign zero_o = ~( zdet[1] | zdet[0]);
		 
		 
	 //*****************************************
	 // LODs:
	 //*****************************************
	 LOD4 lod4_1 (
		.data_i(data_i[7:4]), 
		.data_o(z[7:4])
	 );
	 
	 LOD4 lod4_0 (
		.data_i(data_i[3:0]), 
		.data_o(z[3:0])
	 );

	 LOD2 lod2_middle (
		.data_i(zdet), 
		.data_o(select)
	 );
	 
	 
	 //*****************************************
	 // Multiplexers :
	 //*****************************************
	 
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



	
module LOD10_quant(
    input [9:0] data_i,
    output zero_o,
    output [4:0] data_o
    );
    
     wire zdet;
     wire [4:0] tmp_in;	 
	  //*****************************************
    // Quantization 
    //*****************************************
    assign tmp_in[3:1] = data_i[8:6];
    assign tmp_in[0] = |data_i[5:0];
    //*****************************************
    // Zero detection logic:
    //*****************************************
    assign zdet = data_i[9] | tmp_in[3] | tmp_in[2] | tmp_in[1] | tmp_in[0];
    assign zero_o = ~( zdet);
        
        
    //*****************************************
    // LODs:
    //*****************************************
    LOD4 lod4_1 (
        .data_i(tmp_in[3:0]), 
        .data_o(data_o[3:0])
    );

   assign	data_o[4] = data_i[9];


endmodule


module LOD3(
    input [2:0] data_i,
    output [2:0] data_o
    );
	 
	 
	 wire mux0;
	 wire mux1;
	
	 
	 // multiplexers:
	 assign mux1 = (data_i[2]==1) ? 1'b0 : 1'b1;
	 assign mux0 = (data_i[1]==1) ? 1'b0 : mux1;
	 
	 //gates and IO assignments:
	 assign data_o[2] = data_i[2];
	 assign data_o[1] =(mux1 & data_i[1]);
	 assign data_o[0] =(mux0 & data_i[0]);
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
	 assign data_o[1] =(data_i[1]);
	 assign data_o[0] =(~data_i[1] & data_i[0]);
endmodule


module Muxes2in1Array2(
    input [1:0] data_i,
    input select_i,
    output [1:0] data_o
    );
	assign data_o[1] = select_i ? data_i[1] : 1'b0;
	assign data_o[0] = select_i ? data_i[0] : 1'b0;
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


module PriorityEncoder_8(
    input [7:0] data_i,
    output reg [2:0] code_o
    );

	always @*
		case (data_i)
	     8'b00000001 : code_o = 3'b000;
         8'b00000010 : code_o = 3'b001;
         8'b00000100 : code_o = 3'b010;
         8'b00001000 : code_o = 3'b011;
         8'b00010000 : code_o = 3'b100;
         8'b00100000 : code_o = 3'b101;
	  default     : code_o = 3'b110;
		endcase		
endmodule

module PriorityEncoder_5(
    input [4:0] data_i,
    output reg [2:0] code_o
    );

	always @*
	case (data_i)
	 5'b00001 : code_o = 3'b000;
         5'b00010 : code_o = 3'b001;
         5'b00100 : code_o = 3'b010;
         5'b01000 : code_o = 3'b011;
	  default  : code_o = 3'b100;
		endcase		
endmodule

module Barrel17L_16(
    input [9:0] data_i,
    input [2:0] shift_i,
    output reg [16:0] data_o
    );
	wire [16:0] tmp;
    assign tmp = {{7{data_i[9]}},data_i};
   
   always @*
      case (shift_i)
         3'b000: data_o = tmp;
         3'b001: data_o = tmp << 1;
         3'b010: data_o = tmp << 2;
         3'b011: data_o = tmp << 3;
         3'b100: data_o = tmp << 4;
         3'b101: data_o = tmp << 5;
         3'b110: data_o = tmp << 6;   
         default: data_o = tmp << 7;
      endcase
endmodule

module Barrel27L_10_quant(
    input [15:0] data_i,
    input [2:0] shift_i,
    output reg [24:0] data_o
    );
	wire [24:0] tmp;
   assign tmp = {{9{data_i[15]}},data_i};

   always @*
      case (shift_i)
         3'b000: data_o = tmp;
         3'b001: data_o = tmp << 6;
         3'b010: data_o = tmp << 7;
         3'b011: data_o = tmp << 8;
         default: data_o = tmp << 9;
      endcase
endmodule


// reduction stage

module pp_tree_red_v2(pp_rad4_0,pp_rad4_1,pp_rad4_2,PP_oa,PP_ob,sign_factor,p);
// inputs
// pp_rad4_x - Rad4
// PP_oa, PP_ob - Rad1024
input [16:0] pp_rad4_0;
input [16:0] pp_rad4_1;
input [16:0] pp_rad4_2;
input [16:0] PP_oa;
input [24:0] PP_ob;
input [2:0] sign_factor;
// output
// product p
output [31:0] p;

// generate negative MSBs
wire [4:0] E_MSB;
not n1(E_MSB[0],PP_ob[24]);
not n2(E_MSB[1],PP_oa[16]);
not n3(E_MSB[2],pp_rad4_0[16]);
not n4(E_MSB[3],pp_rad4_1[16]);
not n5(E_MSB[4],pp_rad4_2[16]);


// Reduction 

// First reduction

// first group
wire [15:0] sum00_FA;
wire [15:0] carry00_FA;


wire [15:0] tmp001_FA;
wire [15:0] tmp002_FA;
wire [15:0] tmp003_FA;

assign tmp001_FA = {E_MSB[0],PP_ob[24:10]};
assign tmp002_FA = {E_MSB[1],PP_oa[16:2]};
assign tmp003_FA = {pp_rad4_0[15:0]};


genvar i001;
generate
	for (i001 = 0; i001 < 16; i001 = i001 + 1)
		begin : pp_fad00
		FAd pp_fad(tmp001_FA[i001],tmp002_FA[i001], tmp003_FA[i001], carry00_FA[i001],sum00_FA[i001]);
		end
endgenerate

wire sum00_HA;
wire carry00_HA;

assign sum00_HA = ~pp_rad4_0[16];
assign carry00_HA = pp_rad4_0[16];

// second group

wire sum01_FA;
wire carry01_FA;
wire [16:0] sum01_HA;
wire [16:0] carry01_HA;

wire [16:0] tmp011_HA;
wire [16:0] tmp012_HA;

assign tmp011_HA = {1'b1,E_MSB[3],pp_rad4_1[16:3],pp_rad4_1[0]};
assign tmp012_HA = {pp_rad4_2[16:1],sign_factor[1]};

genvar i010;
generate
	for (i010 = 0; i010 < 17; i010 = i010 + 1)
		begin : pp_had01
		HAd pp_had(tmp011_HA[i010],tmp012_HA[i010],carry01_HA[i010],sum01_HA[i010]);
		end
endgenerate

FAd pp_fad010(pp_rad4_1[2],pp_rad4_2[0],sign_factor[2],carry01_FA,sum01_FA);

// Second reduction 

wire [16:0] sum10_FA;
wire [16:0] carry10_FA;

wire[16:0] tmp100;
wire[16:0] tmp101;
wire[16:0] tmp102;

assign tmp100 = {1'b1,E_MSB[2],sum00_HA,sum00_FA[15:2]};
assign tmp101 = {sum01_HA[14],carry00_HA,carry00_FA[15:1]};
assign tmp102 = {carry01_HA[13],sum01_HA[13:1],sum01_FA,pp_rad4_1[1],sum01_HA[0]};

genvar i11;
generate
	for(i11 = 0; i11 < 17; i11 = i11 +1 )
		begin : pp_fad10
		FAd pp_fad(tmp100[i11],tmp101[i11],tmp102[i11],carry10_FA[i11],sum10_FA[i11]);
		end
endgenerate


wire [2:0] tmp100_HA;
wire [2:0] tmp101_HA;

wire [2:0] sum10_HA;
wire [2:0] carry10_HA;


assign tmp100_HA = {E_MSB[4],sum01_HA[16:15]};
assign tmp101_HA = {carry01_HA[16:14]};

genvar i12;
generate
	for (i12 = 0; i12 < 3; i12 = i12 + 1)
		begin : pp_had10000
		HAd pp_had(tmp100_HA[i12],tmp101_HA[i12],carry10_HA[i12],sum10_HA[i12]);
		end
endgenerate

// Third reduction

wire [13:0] sum20_FA;
wire [13:0] carry20_FA;
wire [4:0] sum20_HA;
wire [4:0] carry20_HA; 

wire[4:0] tmp200_HA;
wire[4:0] tmp201_HA;

assign tmp200_HA = {sum10_HA,sum10_FA[16],sum10_FA[2]};
assign tmp201_HA = {carry10_HA[1:0],carry10_FA[16:15],carry10_FA[1]};

genvar i20;
generate
	for(i20 = 0; i20 < 5; i20 = i20 +1 )
		begin : pp_had20 
		HAd pp_had(tmp200_HA[i20],tmp201_HA[i20],carry20_HA[i20],sum20_HA[i20]);
		end
endgenerate

wire[13:0] tmp200_FA;
wire[13:0] tmp201_FA;
wire[13:0] tmp202_FA;

assign tmp200_FA = {sum10_FA[15:3],sum10_FA[1]};
assign tmp201_FA = {carry10_FA[14:2],carry10_FA[0]};
assign tmp202_FA = {carry01_HA[12:1],carry01_FA,carry01_HA[0]};

genvar i21;
generate
	for(i21 = 0; i21 < 14; i21 = i21 +1 )
		begin : pp_fad20
		FAd pp_fad(tmp200_FA[i21],tmp201_FA[i21],tmp202_FA[i21],carry20_FA[i21],sum20_FA[i21]);
		end
endgenerate

// CLA adder 

wire [31:0] tmp_ADD1;
wire [31:0] tmp_ADD2;

assign tmp_ADD1 = {sum20_HA[4:1],sum20_FA[13:1],sum20_HA[0],sum20_FA[0],sum10_FA[0],sum00_FA[1:0],PP_oa[1:0],8'b0};
assign tmp_ADD2 = {carry20_HA[3:1],carry20_FA[13:1],carry20_HA[0],carry20_FA[0],1'b0,1'b0,carry00_FA[0],sign_factor[0],PP_ob[9:0]};


// Final product

assign p = tmp_ADD1 + tmp_ADD2;

endmodule 

//adders design
module HAd(a,b,c,s);
	input a,b;
	output c,s;
	xor x1(s,a,b);
	and a1(c,a,b);
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

module one_complement_w10
  (
   input [9:0] data_in,
   input sign,
   output [9:0] data_out
   );
     

 
  // Create the HA Adders
  genvar  ii;
  generate
    for (ii=0; ii<10; ii=ii+1) 
      begin: pc
         //assign data_out[ii] = data_in[ii] ^ (sign & w_C[ii-1]);
         assign data_out[ii] = data_in[ii] ^ (sign);

      end
  endgenerate
 
endmodule // carry_lookahead_adder

module one_complement_w16
  (
   input [15:0] data_in,
   input sign,
   output [15:0] data_out
   );
     

 
  // Create the HA Adders
  genvar  ii;
  generate
    for (ii=0; ii<16; ii=ii+1) 
      begin: pc
         //assign data_out[ii] = data_in[ii] ^ (sign & w_C[ii-1]);
	 assign data_out[ii] = data_in[ii] ^ (sign);

      end
  endgenerate
 
endmodule // carry_lookahead_adder
