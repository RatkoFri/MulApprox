`timescale 1ns / 1ps

module RAD1024(
    input [15:0] x,
    input [15:0] y,
    output [31:0] p
    );

// Generate pp
    
    // Radix 4 pp
    
    wire [16:0] pp_rad4_0;
    wire [16:0] pp_rad4_1;
    wire [16:0] pp_rad4_2;
    wire [3:0] sign_factor;
    
    rad4_gen rad4_gen1( 
        .x1(x[15:10]), .y(y),
        .pp_rad4_0(pp_rad4_0),
        .pp_rad4_1(pp_rad4_1),
        .pp_rad4_2(pp_rad4_2),
        .sign_factor(sign_factor[3:1]));
        
    // Radix 1024 pp 
    
    wire [24:0] PP_o;
    
    app_rad1024 rad1024_gen_v1( 
      .x0(x[9:0]),.y(y),
      .PP_o(PP_o),
      .sign_factor(sign_factor[0]));
     
    // Tree
    pp_tree_ahhre wallace_tree(
        .pp_rad4_0(pp_rad4_0),
        .pp_rad4_1(pp_rad4_1),
        .pp_rad4_2(pp_rad4_2),
        .pp_rad1024(PP_o),
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
    input [5:0] x1;
    // output
    output [16:0] pp_rad4_0;
    output [16:0] pp_rad4_1;
    output [16:0] pp_rad4_2;
    output [2:0] sign_factor;
   
    wire [2:0] one,two,sign;
    
    code code0(one[0],two[0],sign[0],x1[1],x1[0], 1'b0);
    
    genvar j;
    generate
        for ( j = 1; j < 3; j = j+1 )
            begin : pp_code
            code code_gen(one[j],two[j],sign[j],x1[2*j+1],x1[2*j], x1[2*j-1]);
            end
    endgenerate
    
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

//sign_factor generate

module sgn_gen(one,two,sign,sign_factor);
	input sign,one,two;
	output sign_factor;
	wire k;
	or o1(k,one,two);
	and a1(sign_factor,sign,k);
endmodule

module app_rad1024(
    input [9:0] x0,
    input [15:0] y,
    output [24:0] PP_o,
    output sign_factor
);

// Encode 
    wire sign;
    wire [3:0] enc_vec;
    assign sign = x0[9]| x0[4] | x0[3] | x0[2] | x0[1] | x0[0];
    // assign sign = x0[9];
    assign enc_vec[3] = ((~x0[8] & ~x0[7] & ~x0[6]) | (x0[8] & x0[7] & x0[6])) & (x0[6] ^ x0[5]);
    assign enc_vec[2] = (~x0[9] & ~x0[8] & ( (~ x0[7] & x0[6] & x0[5]) | (x0[7] & ~x0[6]))) | (x0[9] & x0[8] & ( ( x0[7] & ~x0[6] & ~x0[5]) | (~x0[7] & x0[6])));
    assign enc_vec[1] = (~x0[8] & x0[7] & (x0[9] | x0[6])) | (x0[8] & ~x0[7] & (~x0[9] | ~x0[6]));
    assign enc_vec[0] = (~x0[9] & x0[8] & x0[7]) | (x0[9] & ~x0[8] & ~x0[7]); 

// Generate
 
    wire [27:0] gen_tmp;
    assign gen_tmp = {{3{y[15]}},y,9'b0};
    genvar i;
    generate
        for ( i = 0; i < 25; i = i+1 )
            begin : pp1024_gen_loop 
            rad1024_unit pp_pr(sign,enc_vec,gen_tmp[i+3:i],PP_o[i]);
            end
    endgenerate
 
 // sign factor 
 
    assign sign_factor = sign & ( (enc_vec[0] | enc_vec[1]) | (enc_vec[2] | enc_vec[3]));
endmodule

module rad1024_unit(
    input sign,
    input [3:0] enc_vec,
    input [3:0] a_vec,
    output pp_i);
      
    // sign change
    wire [3:0] a_sign;
    
    assign a_sign[3] = sign ^ a_vec[3];
    assign a_sign[2] = sign ^ a_vec[2];
    assign a_sign[1] = sign ^ a_vec[1];
    assign a_sign[0] = sign ^ a_vec[0];
    
    // enc and  a_sign
    wire [3:0] a_enc;
    assign a_enc = a_sign & enc_vec;
    
    // pp_i
    assign pp_i = (a_enc[3] | a_enc[2] | a_enc[1] | a_enc[0]);  
 
endmodule


module pp_tree_ahhre(
    input [16:0] pp_rad4_0,
    input [16:0] pp_rad4_1,
    input [16:0] pp_rad4_2,
    input [24:0] pp_rad1024,
    input [3:0] sign_factor,
    output [31:0] p);
    
    
    wire [3:0] E_MSB;
    assign E_MSB[0] = ~pp_rad1024[24];
    assign E_MSB[1] = ~pp_rad4_0[16];
    assign E_MSB[2] = ~pp_rad4_1[16];
    assign E_MSB[3] = ~pp_rad4_2[16];
    
    // first group
    wire [15:0] sum00_FA;
    wire [15:0] carry00_FA;
    
    wire [15:0] tmp001_FA;
    wire [15:0] tmp002_FA;
    wire [15:0] tmp003_FA;
    
    assign tmp001_FA = {1'b1,E_MSB[0],pp_rad1024[24:12],pp_rad1024[10]};
    assign tmp002_FA = {pp_rad4_0[16:2],pp_rad4_0[0]};
    assign tmp003_FA = {pp_rad4_1[14:0],sign_factor[1]};
    
    
    genvar i001;
    generate
        for (i001 = 0; i001 < 16; i001 = i001 + 1)
            begin : pp_fad00
            FAd pp_fad(tmp001_FA[i001],tmp002_FA[i001], tmp003_FA[i001], carry00_FA[i001],sum00_FA[i001]);
            end
    endgenerate
    
    wire [2:0] sum00_HA;
    wire [2:0] carry00_HA;
    
    wire [2:0] tmp001_HA;
    wire [2:0] tmp002_HA;
    
    assign tmp001_HA = {1'b1,E_MSB[1],pp_rad1024[11]};
    assign tmp002_HA = {pp_rad4_1[16:15],pp_rad4_0[1]};
	
	genvar i002;
	generate
		for (i002 = 0; i002 < 3; i002 = i002 + 1)
			begin : pp_had01
			HAd pp_had(tmp001_HA[i002],tmp002_HA[i002],carry00_HA[i002],sum00_HA[i002]);
			end
	endgenerate

// second group
	
	wire [1:0] sum01_HA;
        wire [1:0] carry01_HA;
	wire [1:0] tmp011_HA;
	wire [1:0] tmp012_HA;

	assign tmp011_HA = {pp_rad4_2[11],pp_rad4_2[0]};
	assign tmp012_HA = {1'b1,sign_factor[3]};

	genvar i010;
	generate
		for (i010 = 0; i010 < 2; i010 = i010 + 1)
			begin : pp_had02
			HAd pp_had(tmp011_HA[i010],tmp012_HA[i010],carry01_HA[i010],sum01_HA[i010]);
			end
	endgenerate

	

	// Second reduction 

	wire [16:0] sum10_FA;
	wire [16:0] carry10_FA;

	wire[16:0] tmp100;
	wire[16:0] tmp101;
	wire[16:0] tmp102;

	assign tmp100 = {E_MSB[2],sum00_HA[2:1],sum00_FA[15:3],sum00_FA[1]};
	assign tmp101 = {carry00_HA[2:1],carry00_FA[15:2],carry00_HA[0]};
	assign tmp102 = {pp_rad4_2[15:12],sum01_HA[1],pp_rad4_2[10:1],sum01_HA[0],sign_factor[2]};

	genvar i11;
	generate
		for(i11 = 0; i11 < 17; i11 = i11 +1 )
			begin : pp_fad10
			FAd pp_fad(tmp100[i11],tmp101[i11],tmp102[i11],carry10_FA[i11],sum10_FA[i11]);
			end
	endgenerate
	
	wire [1:0] sum10_HA;
	wire [1:0] carry10_HA;
	wire [1:0] tmp100_HA;
	wire [1:0] tmp101_HA;

	assign tmp100_HA = {1'b1,sum00_FA[2]};
	assign tmp101_HA = {pp_rad4_2[16],carry00_FA[1]};

	genvar i12;
	generate
		for (i12 = 0; i12 < 2; i12 = i12 + 1)
			begin : pp_had11
			HAd pp_had(tmp100_HA[i12],tmp101_HA[i12],carry10_HA[i12],sum10_HA[i12]);
			end
	endgenerate
	
	// Third reduction 
	
	wire [1:0] sum20_FA;
	wire [1:0] carry20_FA;
	wire [14:0] sum20_HA;
	wire [14:0] carry20_HA; 
	
	wire[14:0] tmp200_HA;
	wire[14:0] tmp201_HA;

	assign tmp200_HA = {E_MSB[3],sum10_HA[1],sum10_FA[16:14],sum10_FA[12:3]};
	assign tmp201_HA = {carry10_HA[1],carry10_FA[16:13],carry10_FA[11:2]};

	genvar i20;
	generate
		for(i20 = 0; i20 < 15; i20 = i20 +1 )
			begin : pp_had20 
			HAd pp_had(tmp200_HA[i20],tmp201_HA[i20],carry20_HA[i20],sum20_HA[i20]);
			end
	endgenerate
	
	wire[1:0] tmp200_FA;
	wire[1:0] tmp201_FA;
	wire[1:0] tmp202_FA;

	assign tmp200_FA = {sum10_FA[13],sum10_FA[2]};
	assign tmp201_FA = {carry10_FA[12],carry10_FA[1]};
	assign tmp202_FA = carry01_HA;

	genvar i21;
	generate
		for(i21 = 0; i21 < 2; i21 = i21 +1 )
			begin : pp_fad20
			FAd pp_fad(tmp200_FA[i21],tmp201_FA[i21],tmp202_FA[i21],carry20_FA[i21],sum20_FA[i21]);
			end
	endgenerate
	
	
	// Final addition
	
	// CLA adder 

	wire [31:0] tmp_ADD1;
	wire [31:0] tmp_ADD2;

	assign tmp_ADD1 = {sum20_HA[14:10],sum20_FA[1],sum20_HA[9:0],sum20_FA[0],sum10_FA[1],sum10_HA[0],sum10_FA[0],sum00_HA[0],sum00_FA[0],pp_rad1024[9:0]};
	assign tmp_ADD2 = {carry20_HA[13:10],carry20_FA[1],carry20_HA[9:0],carry20_FA[0],1'b0,carry10_HA[0],carry10_FA[0],1'b0,carry00_FA[0],10'b0,sign_factor[0]};


	// Final product

	assign p = tmp_ADD1 + tmp_ADD2;
	
endmodule

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



