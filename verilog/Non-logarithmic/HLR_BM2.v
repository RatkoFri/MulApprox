`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/29/2018 10:46:24 AM
// Design Name: 
// Module Name: AHHRE_10bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module HLR_BM2(
    input [15:0] x,
    input [15:0] y,
    output [31:0] p
    );

// Generate pp
    
    // Radix 4 pp
    
    wire [16:0] pp_rad4_0;
    wire [16:0] pp_rad4_1;
    wire [5:0] sign_factor;
    
    rad4_gen rad4_gen1( 
        .x1(x[15:11]), .y(y),
        .pp_rad4_0(pp_rad4_0),
        .pp_rad4_1(pp_rad4_1),
        .sign_factor(sign_factor[5:4]));
        
    // Radix 1024 pp 
    
    wire [17:0] pp_rad8_0;
    wire [17:0] pp_rad8_1;
    wire [17:0] pp_rad8_2; 
    wire [17:0] pp_rad8_3; 

    rad8_approx_gen rad8_gen1( 
        .x1(x[11:0]), .y(y),
        .pp_rad8_0(pp_rad8_0),
        .pp_rad8_1(pp_rad8_1),
        .pp_rad8_2(pp_rad8_2),
        .pp_rad8_3(pp_rad8_3),
        .sign_factor(sign_factor[3:0]));
        

    // Tree
    pp_tree_hlrbm2 wallace_tree(
        .pp_rad4_0(pp_rad4_0),
        .pp_rad4_1(pp_rad4_1),
        .pp_rad8_0(pp_rad8_0),
        .pp_rad8_1(pp_rad8_1),
        .pp_rad8_2(pp_rad8_2),
        .pp_rad8_3(pp_rad8_3),
        .sign_factor(sign_factor),
        .p(p));
      
endmodule

// Radix 4 gen



// like on the picture

module rad4_gen( x1,y,pp_rad4_0,pp_rad4_1,sign_factor);
    // inputs
    // y multiplicand
    // x multipland 
    // P1,P2,P3 partial products
    input [15:0] y;
    input [4:0] x1;
    // output
    output [16:0] pp_rad4_0;
    output [16:0] pp_rad4_1;
    output [1:0] sign_factor;
   
    wire [1:0] one,two,sign;
    
    code code0(one[0],two[0],sign[0],x1[2],x1[1], x1[0]);
    code code1(one[1],two[1],sign[1],x1[4],x1[3], x1[2]);

 
    
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
    
    genvar i_sign;
    generate
        for ( i_sign = 0; i_sign < 2; i_sign = i_sign+1 )
            begin : sgn_fac
            sgn_gen sgn_genXX(one[i_sign],two[i_sign],sign[i_sign],sign_factor[i_sign]);
            end
    endgenerate

endmodule


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


module rad8_approx_gen( x1,y,pp_rad8_0,pp_rad8_1,pp_rad8_2,pp_rad8_3,sign_factor);
    // inputs
    // y multiplicand
    // x multipland 
    // P1,P2,P3 partial products
    input [15:0] y;
    input [11:0] x1;
    // output
    output [17:0] pp_rad8_0;
    output [17:0] pp_rad8_1;
    output [17:0] pp_rad8_2;
    output [17:0] pp_rad8_3;
    output [3:0] sign_factor;
   
    wire [3:0] one,two,four,sign;
    
    wire [3:0] ls_enc;
    assign ls_enc={x1[2:0],1'b0};

    code_rad8 code0(one[0],two[0],four[0],sign[0],ls_enc);
    code_rad8 code1(one[1],two[1],four[1],sign[1],x1[5:2]);
    code_rad8 code2(one[2],two[2],four[2],sign[2],x1[8:5]);
    code_rad8 code3(one[3],two[3],four[3],sign[3],x1[11:8]);
    
    wire [19:0] tmp1_pp; 
    assign tmp1_pp = {y[15],y[15],y,1'b0,1'b0}; // This variable is introduced because pp has 17 bits
    
    // first pp generation 
    wire [17:0] out1;
    assign out1[0] = sign[0];
    
    genvar i;
    generate
        for ( i = 0; i < 18; i = i+1 )
            begin : pp_rad8_first 
            rad8_unit pp_gen(pp_rad8_0[i],sign[0],one[0],two[0],four[0],tmp1_pp[i],tmp1_pp[i+1],tmp1_pp[i+2]);
            end
    endgenerate
    
    genvar i1;
    generate
        for ( i1 = 0; i1 < 18; i1 = i1+1 )
            begin : pp_rad8_second 
            rad8_unit pp_gen(pp_rad8_1[i1],sign[1],one[1],two[1],four[1],tmp1_pp[i1],tmp1_pp[i1+1],tmp1_pp[i1+2]);
            end
    endgenerate
    
    genvar i2;
    generate
        for ( i2 = 0; i2 < 18; i2 = i2+1 )
            begin : pp_rad8_third
            rad8_unit pp_gen(pp_rad8_2[i2],sign[2],one[2],two[2],four[2],tmp1_pp[i2],tmp1_pp[i2+1],tmp1_pp[i2+2]);
            end
    endgenerate

    genvar i3;
    generate
        for ( i3 = 0; i3 < 18; i3 = i3+1 )
            begin : pp_rad8_fourth
            rad8_unit pp_gen(pp_rad8_3[i3],sign[3],one[3],two[3],four[3],tmp1_pp[i3],tmp1_pp[i3+1],tmp1_pp[i3+2]);
            end
    endgenerate
    

    assign sign_factor = sign;

endmodule

//generation of inner products

module code_rad8(one,two,four,sign,x_enc);  
	input [3:0] x_enc;                     
	output one,two,four,sign;
      
    assign sign = x_enc[3];

    wire [1:0] tmp_four;
    assign tmp_four[0] = ~x_enc[3] &  x_enc[2]  &  x_enc[1];
    assign tmp_four[1] =  x_enc[3] & ~x_enc[2]  & ~x_enc[1];
    assign four = tmp_four[0] | tmp_four[1];

    wire [3:0] tmp_two;
    assign tmp_two[0] = ~x_enc[2] &  x_enc[1] &  x_enc[0];
    assign tmp_two[1] =  x_enc[2] & ~x_enc[1] & ~x_enc[0];
    assign tmp_two[2] =  x_enc[3] & ~x_enc[2] &  x_enc[1];
    assign tmp_two[3] = ~x_enc[3] &  x_enc[2] & ~x_enc[1];
    assign two = |(tmp_two);

    wire [3:0] tmp_one;
    assign tmp_one[0] = ~x_enc[3] & ~x_enc[2] & ~x_enc[1] &  x_enc[0];
    assign tmp_one[1] = ~x_enc[3] & ~x_enc[2] &  x_enc[1] & ~x_enc[0];
    assign tmp_one[2] =  x_enc[3] &  x_enc[2] & ~x_enc[1] &  x_enc[0];
    assign tmp_one[3] =  x_enc[3] &  x_enc[2] &  x_enc[1] & ~x_enc[0];
    assign one = |{tmp_one};           
endmodule  


module rad8_unit(pp_i,sign,one,two,four, x2, x1, x0);
    input sign, one, two,four;
    input x2,x1,x0;
    output pp_i;

    wire [2:0] a_vec;
    wire [2:0] enc_vec;

    assign a_vec = {x2,x1,x0};
    assign enc_vec = {four,two,one};
    // sign change
    wire [2:0] a_sign;
    
    assign a_sign[2] = sign ^ a_vec[2];
    assign a_sign[1] = sign ^ a_vec[1];
    assign a_sign[0] = sign ^ a_vec[0];
    
    // enc and  a_sign
    wire [2:0] a_enc;
    assign a_enc = a_sign & enc_vec;
    
    // pp_i
    assign pp_i = ( a_enc[2] | a_enc[1] | a_enc[0]);  
 
endmodule


module sgn_gen_rad8(one,two,four,sign,sign_factor);
	input sign,one,two,four;
	output sign_factor;
	wire k;
	assign k = one & two & four;
	assign sign_factor = k & sign;
endmodule


module pp_tree_hlrbm2(
    input [16:0] pp_rad4_0,
    input [16:0] pp_rad4_1,
    input [17:0] pp_rad8_0,
    input [17:0] pp_rad8_1,
    input [17:0] pp_rad8_2,
    input [17:0] pp_rad8_3,
    input [5:0] sign_factor,
    output [31:0] p);
    
    
    wire [5:0] E_MSB;
    assign E_MSB[0] = ~pp_rad8_0[17];
    assign E_MSB[1] = ~pp_rad8_1[17];
    assign E_MSB[2] = ~pp_rad8_2[17];
    assign E_MSB[3] = ~pp_rad8_3[17];
    assign E_MSB[4] = ~pp_rad4_0[16];
    assign E_MSB[5] = ~pp_rad4_1[16];
    
    wire [1:0] OR_bit;
    assign OR_bit[0] = pp_rad4_0[0] | sign_factor[4];
    assign OR_bit[1] = pp_rad4_1[0] | sign_factor[5];

    // first reduction

    // first group
    wire [16:0] sum00_FA;
    wire [16:0] carry00_FA;
    
    wire [16:0] tmp001_FA;
    wire [16:0] tmp002_FA;
    wire [16:0] tmp003_FA;
    
    assign tmp001_FA = {E_MSB[0],pp_rad8_0[17],pp_rad8_0[17],pp_rad8_0[17],pp_rad8_0[17:6],pp_rad8_0[3]};
    assign tmp002_FA = {E_MSB[1],pp_rad8_1[17:3],pp_rad8_1[0]};
    assign tmp003_FA = {pp_rad8_2[15:0],sign_factor[1]};
    
    
    genvar i001;
    generate
        for (i001 = 0; i001 < 17; i001 = i001 + 1)
            begin : pp_fad010
            FAd pp_fad(tmp001_FA[i001],tmp002_FA[i001], tmp003_FA[i001], carry00_FA[i001],sum00_FA[i001]);
            end
    endgenerate
    
    wire [3:0] sum00_HA;
    wire [3:0] carry00_HA;
    
    wire [3:0] tmp001_HA;
    wire [3:0] tmp002_HA;
    
    assign tmp001_HA = {1'b1,1'b1,pp_rad8_0[5:4]};
    assign tmp002_HA = {pp_rad8_2[17:16],pp_rad8_1[2:1]};
	
	genvar i002;
	generate
		for (i002 = 0; i002 < 4; i002 = i002 + 1)
			begin : pp_had010
			HAd pp_had(tmp001_HA[i002],tmp002_HA[i002],carry00_HA[i002],sum00_HA[i002]);
			end
	endgenerate

    // second group
	wire [14:0] sum01_FA;
    wire [14:0] carry01_FA;
    
    wire [14:0] tmp011_FA;
    wire [14:0] tmp012_FA;
    wire [14:0] tmp013_FA;
	
    assign tmp011_FA = {E_MSB[3],pp_rad8_3[17:4]};
    assign tmp012_FA = {pp_rad4_0[16:2]};
    assign tmp013_FA = {pp_rad4_1[14:1],OR_bit[1]};

    genvar i011;
    generate
        for (i011 = 0; i011 < 15; i011 = i011 + 1)
            begin : pp_fad011
            FAd pp_fad(tmp011_FA[i011],tmp012_FA[i011], tmp013_FA[i011], carry01_FA[i011],sum01_FA[i011]);
            end
    endgenerate

    wire [4:0] sum01_HA;
    wire [4:0] carry01_HA;
    
    wire [4:0] tmp011_HA;
    wire [4:0] tmp012_HA;

    assign tmp011_HA = {1'b1,E_MSB[4],pp_rad8_3[3:2],pp_rad8_3[0]};
    assign tmp012_HA = {pp_rad4_1[16:15],pp_rad4_0[1],OR_bit[0],sign_factor[3]};

    genvar i012;
	generate
		for (i012 = 0; i012 < 5; i012 = i012 + 1)
			begin : pp_had011
			HAd pp_had(tmp011_HA[i012],tmp012_HA[i012],carry01_HA[i012],sum01_HA[i012]);
			end
	endgenerate


    // second reduction
    wire [18:0] sum10_FA;
    wire [18:0] carry10_FA;
    
    wire [18:0] tmp101_FA;
    wire [18:0] tmp102_FA;
    wire [18:0] tmp103_FA;

	assign tmp101_FA = {1'b1, 1'b1, E_MSB[2],sum00_HA[3:2],sum00_FA[16:4],sum00_FA[1]};
    assign tmp102_FA = {sum01_FA[13:12],carry00_HA[3:2],carry00_FA[16:3],carry00_HA[1]};
    assign tmp103_FA = {carry01_FA[12:11],sum01_FA[11:0],sum01_HA[2:1],pp_rad8_3[1],sum01_HA[0],sign_factor[2]};

    genvar i101;
    generate
        for (i101 = 0; i101 < 19; i101 = i101 + 1)
            begin : pp_fad110
            FAd pp_fad(tmp101_FA[i101],tmp102_FA[i101], tmp103_FA[i101], carry10_FA[i101],sum10_FA[i101]);
            end
    endgenerate

    wire [5:0] sum10_HA;
    wire [5:0] carry10_HA;
    
    wire [5:0] tmp101_HA;
    wire [5:0] tmp102_HA;

    assign tmp101_HA ={E_MSB[5],sum01_HA[4:3],sum01_FA[14],sum00_FA[3:2]};
    assign tmp102_HA ={carry01_HA[4:3],carry01_FA[14:13],carry00_FA[2:1]};

    genvar i102;
    generate
        for (i102 = 0; i102 < 6; i102 = i102 + 1)
            begin : pp_fad120
            HAd pp_fad(tmp101_HA[i102],tmp102_HA[i102], carry10_HA[i102],sum10_HA[i102]);
            end
    endgenerate
    // third reduction
    wire [13:0] sum20_FA;
    wire [13:0] carry20_FA;
    
    wire [13:0] tmp201_FA;
    wire [13:0] tmp202_FA;
    wire [13:0] tmp203_FA;

    assign tmp201_FA = {sum10_FA[16:4],sum10_FA[2]};
    assign tmp202_FA = {carry10_FA[15:3],carry10_FA[1]};
    assign tmp203_FA = {carry01_FA[10:0],carry01_HA[2:0]};

    genvar i201;
    generate
        for (i201 = 0; i201 < 14; i201 = i201 + 1)
            begin : pp_fad210
            FAd pp_fad(tmp201_FA[i201],tmp202_FA[i201], tmp203_FA[i201], carry20_FA[i201],sum20_FA[i201]);
            end
    endgenerate

    wire [7:0] sum20_HA;
    wire [7:0] carry20_HA;
    
    wire [7:0] tmp201_HA;
    wire [7:0] tmp202_HA;

    assign tmp201_HA ={1'b1,sum10_HA[5:2],sum10_FA[18:17],sum10_FA[3]};
    assign tmp202_HA ={carry10_HA[5:2],carry10_FA[18:16],carry10_FA[2]};

    genvar i202;
    generate
        for (i202 = 0; i202 < 8; i202 = i202 + 1)
            begin : pp_fad220
            HAd pp_fad(tmp201_HA[i202],tmp202_HA[i202], carry20_HA[i202],sum20_HA[i202]);
            end
    endgenerate

    // Final addition
	// CLA adder 

	wire [31:0] tmp_ADD1;
	wire [31:0] tmp_ADD2;

	assign tmp_ADD1 = {1'b0,sum20_HA[7:1],sum20_FA[13:1],sum20_HA[0],sum20_FA[0],sum10_FA[1],sum10_HA[1:0],sum10_FA[0],sum00_HA[1:0],sum00_FA[0],pp_rad8_0[2:0]};
	assign tmp_ADD2 = {carry20_HA[7:1],carry20_FA[13:1],carry20_HA[0],carry20_FA[0],carry10_FA[1],carry10_HA[1:0],carry10_FA[0],1'b0,carry00_HA[0],carry00_FA[0],3'b0,sign_factor[0]};
	// Final product

	assign p = tmp_ADD1 + tmp_ADD2;
	
endmodule


module pp_tree_hlrbm2_v3(
    input [16:0] pp_rad4_0,
    input [16:0] pp_rad4_1,
    input [17:0] pp_rad8_0,
    input [17:0] pp_rad8_1,
    input [17:0] pp_rad8_2,
    input [17:0] pp_rad8_3,
    input [5:0] sign_factor,
    output [31:0] p);
    
    
    wire [5:0] E_MSB;
    assign E_MSB[0] = ~pp_rad8_0[17];
    assign E_MSB[1] = ~pp_rad8_1[17];
    assign E_MSB[2] = ~pp_rad8_2[17];
    assign E_MSB[3] = ~pp_rad8_3[17];
    assign E_MSB[4] = ~pp_rad4_0[16];
    assign E_MSB[5] = ~pp_rad4_1[16];
    
    wire [1:0] OR_bit;
    assign OR_bit[0] = pp_rad4_0[0] | sign_factor[4];
    assign OR_bit[1] = pp_rad4_1[0] | sign_factor[5];

    // first reduction

    // first group
    wire [15:0] sum00_FA;
    wire [15:0] carry00_FA;
    
    wire [15:0] tmp001_FA;
    wire [15:0] tmp002_FA;
    wire [15:0] tmp003_FA;
    
    assign tmp001_FA = {E_MSB[0],pp_rad8_0[17],pp_rad8_0[17],pp_rad8_0[17],pp_rad8_0[16:6],pp_rad8_0[3]};
    assign tmp002_FA = {E_MSB[1],pp_rad8_1[16:3],pp_rad8_1[0]};
    assign tmp003_FA = {pp_rad8_2[14:0],sign_factor[1]};
    
    
    genvar i001;
    generate
        for (i001 = 0; i001 < 16; i001 = i001 + 1)
            begin : pp_fad010
            FAd pp_fad(tmp001_FA[i001],tmp002_FA[i001], tmp003_FA[i001], carry00_FA[i001],sum00_FA[i001]);
            end
    endgenerate
    
    wire [3:0] sum00_HA;
    wire [3:0] carry00_HA;
    
    wire [3:0] tmp001_HA;
    wire [3:0] tmp002_HA;
    
    assign tmp001_HA = {1'b1,1'b1,pp_rad8_0[5:4]};
    assign tmp002_HA = {pp_rad8_2[16:15],pp_rad8_1[2:1]};
	
	genvar i002;
	generate
		for (i002 = 0; i002 < 4; i002 = i002 + 1)
			begin : pp_had010
			HAd pp_had(tmp001_HA[i002],tmp002_HA[i002],carry00_HA[i002],sum00_HA[i002]);
			end
	endgenerate

    // second group
	wire [13:0] sum01_FA;
    wire [13:0] carry01_FA;
    
    wire [13:0] tmp011_FA;
    wire [13:0] tmp012_FA;
    wire [13:0] tmp013_FA;
	
    assign tmp011_FA = {E_MSB[3],pp_rad8_3[16:4]};
    assign tmp012_FA = {pp_rad4_0[15:2]};
    assign tmp013_FA = {pp_rad4_1[13:1],OR_bit[1]};

    genvar i011;
    generate
        for (i011 = 0; i011 < 14; i011 = i011 + 1)
            begin : pp_fad011
            FAd pp_fad(tmp011_FA[i011],tmp012_FA[i011], tmp013_FA[i011], carry01_FA[i011],sum01_FA[i011]);
            end
    endgenerate

    wire [4:0] sum01_HA;
    wire [4:0] carry01_HA;
    
    wire [4:0] tmp011_HA;
    wire [4:0] tmp012_HA;

    assign tmp011_HA = {1'b1,E_MSB[4],pp_rad8_3[3:2],pp_rad8_3[0]};
    assign tmp012_HA = {pp_rad4_1[15:14],pp_rad4_0[1],OR_bit[0],sign_factor[3]};

    genvar i012;
	generate
		for (i012 = 0; i012 < 5; i012 = i012 + 1)
			begin : pp_had011
			HAd pp_had(tmp011_HA[i012],tmp012_HA[i012],carry01_HA[i012],sum01_HA[i012]);
			end
	endgenerate


    // second reduction
    wire [17:0] sum10_FA;
    wire [17:0] carry10_FA;
    
    wire [17:0] tmp101_FA;
    wire [17:0] tmp102_FA;
    wire [17:0] tmp103_FA;

	assign tmp101_FA = {1'b1, 1'b1, E_MSB[2],sum00_HA[3:2],sum00_FA[15:4],sum00_FA[1]};
    assign tmp102_FA = {sum01_FA[12:11],carry00_HA[3:2],carry00_FA[15:3],carry00_HA[1]};
    assign tmp103_FA = {carry01_FA[11:10],sum01_FA[10:0],sum01_HA[2:1],pp_rad8_3[1],sum01_HA[0],sign_factor[2]};

    genvar i101;
    generate
        for (i101 = 0; i101 < 18; i101 = i101 + 1)
            begin : pp_fad110
            FAd pp_fad(tmp101_FA[i101],tmp102_FA[i101], tmp103_FA[i101], carry10_FA[i101],sum10_FA[i101]);
            end
    endgenerate

    wire [5:0] sum10_HA;
    wire [5:0] carry10_HA;
    
    wire [5:0] tmp101_HA;
    wire [5:0] tmp102_HA;

    assign tmp101_HA ={E_MSB[5],sum01_HA[4:3],sum01_FA[13],sum00_FA[3:2]};
    assign tmp102_HA ={carry01_HA[4:3],carry01_FA[13:12],carry00_FA[2:1]};

    genvar i102;
    generate
        for (i102 = 0; i102 < 6; i102 = i102 + 1)
            begin : pp_fad120
            HAd pp_fad(tmp101_HA[i102],tmp102_HA[i102], carry10_HA[i102],sum10_HA[i102]);
            end
    endgenerate
    // third reduction
    wire [12:0] sum20_FA;
    wire [12:0] carry20_FA;
    
    wire [12:0] tmp201_FA;
    wire [12:0] tmp202_FA;
    wire [12:0] tmp203_FA;

    assign tmp201_FA = {sum10_FA[15:4],sum10_FA[2]};
    assign tmp202_FA = {carry10_FA[14:3],carry10_FA[1]};
    assign tmp203_FA = {carry01_FA[9:0],carry01_HA[1:0]};

    genvar i201;
    generate
        for (i201 = 0; i201 < 13; i201 = i201 + 1)
            begin : pp_fad210
            FAd pp_fad(tmp201_FA[i201],tmp202_FA[i201], tmp203_FA[i201], carry20_FA[i201],sum20_FA[i201]);
            end
    endgenerate

    wire [7:0] sum20_HA;
    wire [7:0] carry20_HA;
    
    wire [7:0] tmp201_HA;
    wire [7:0] tmp202_HA;

    assign tmp201_HA ={1'b1,sum10_HA[5:2],sum10_FA[17:16],sum10_FA[3]};
    assign tmp202_HA ={carry10_HA[5:2],carry10_FA[17:15],carry10_FA[2]};

    genvar i202;
    generate
        for (i202 = 0; i202 < 8; i202 = i202 + 1)
            begin : pp_fad220
            HAd pp_fad(tmp201_HA[i202],tmp202_HA[i202], carry20_HA[i202],sum20_HA[i202]);
            end
    endgenerate

    // Final addition
	// CLA adder 

	wire [31:0] tmp_ADD1;
	wire [31:0] tmp_ADD2;

	assign tmp_ADD1 = {1'b1,sum20_HA[7:1],sum20_FA[12:1],sum20_HA[0],sum20_FA[0],sum10_FA[1],sum10_HA[1:0],sum10_FA[0],sum00_HA[1:0],sum00_FA[0],pp_rad8_0[2:0]};
	assign tmp_ADD2 = {carry20_HA[7:1],carry20_FA[12:1],carry20_HA[0],carry20_FA[0],carry10_FA[1],carry10_HA[1:0],carry10_FA[0],1'b0,carry00_HA[0],carry00_FA[0],3'b0,sign_factor[0]};
	// Final product

	assign p = tmp_ADD1 + tmp_ADD2;
	
endmodule




module pp_tree_hlrbm2_v2(
    input [16:0] pp_rad4_0,
    input [16:0] pp_rad4_1,
    input [17:0] pp_rad8_0,
    input [17:0] pp_rad8_1,
    input [17:0] pp_rad8_2,
    input [17:0] pp_rad8_3,
    input [5:0] sign_factor,
    output [31:0] p);
    
    
    wire [5:0] E_MSB;
    assign E_MSB[0] = ~pp_rad8_0[17];
    assign E_MSB[1] = ~pp_rad8_1[17];
    assign E_MSB[2] = ~pp_rad8_2[17];
    assign E_MSB[3] = ~pp_rad8_3[17];
    assign E_MSB[4] = ~pp_rad4_0[16];
    assign E_MSB[5] = ~pp_rad4_1[16];
    
    wire [1:0] OR_bit;
    assign OR_bit[0] = pp_rad4_0[0] | sign_factor[4];
    assign OR_bit[1] = pp_rad4_0[1] | sign_factor[5];

    // first reduction

    // first group
    wire [15:0] sum00_FA;
    wire [15:0] carry00_FA;
    
    wire [15:0] tmp001_FA;
    wire [15:0] tmp002_FA;
    wire [15:0] tmp003_FA;
    
    assign tmp001_FA = {E_MSB[0],pp_rad8_0[17],pp_rad8_0[17],pp_rad8_0[17],pp_rad8_0[16:6],pp_rad8_0[3]};
    assign tmp002_FA = {E_MSB[1],pp_rad8_1[16:3],pp_rad8_1[0]};
    assign tmp003_FA = {pp_rad8_2[14:0],sign_factor[1]};
    
    
    genvar i001;
    generate
        for (i001 = 0; i001 < 16; i001 = i001 + 1)
            begin : pp_fad010
            FAd pp_fad(tmp001_FA[i001],tmp002_FA[i001], tmp003_FA[i001], carry00_FA[i001],sum00_FA[i001]);
            end
    endgenerate
    
    wire [3:0] sum00_HA;
    wire [3:0] carry00_HA;
    
    wire [3:0] tmp001_HA;
    wire [3:0] tmp002_HA;
    
    assign tmp001_HA = {1'b1,1'b1,pp_rad8_0[5:4]};
    assign tmp002_HA = {pp_rad8_1[16:15],pp_rad8_1[2:1]};
	
	genvar i002;
	generate
		for (i002 = 0; i002 < 4; i002 = i002 + 1)
			begin : pp_had010
			HAd pp_had(tmp001_HA[i002],tmp002_HA[i002],carry00_HA[i002],sum00_HA[i002]);
			end
	endgenerate

    // second group
	wire [13:0] sum01_FA;
    wire [13:0] carry01_FA;
    
    wire [13:0] tmp011_FA;
    wire [13:0] tmp012_FA;
    wire [13:0] tmp013_FA;
	
    assign tmp011_FA = {E_MSB[3],pp_rad8_3[16:4]};
    assign tmp012_FA = {pp_rad4_0[15:2]};
    assign tmp013_FA = {pp_rad4_1[13:1],OR_bit[1]};

    genvar i011;
    generate
        for (i011 = 0; i011 < 14; i011 = i011 + 1)
            begin : pp_fad011
            FAd pp_fad(tmp011_FA[i011],tmp012_FA[i011], tmp013_FA[i011], carry01_FA[i011],sum01_FA[i011]);
            end
    endgenerate

    wire [4:0] sum01_HA;
    wire [4:0] carry01_HA;
    
    wire [4:0] tmp011_HA;
    wire [4:0] tmp012_HA;

    assign tmp011_HA = {1'b1,E_MSB[4],pp_rad8_3[3:2],pp_rad8_3[0]};
    assign tmp012_HA = {pp_rad4_1[15:14],pp_rad4_0[1],OR_bit[0],sign_factor[3]};

    genvar i012;
	generate
		for (i012 = 0; i012 < 5; i012 = i012 + 1)
			begin : pp_had011
			HAd pp_had(tmp011_HA[i012],tmp012_HA[i012],carry01_HA[i012],sum01_HA[i012]);
			end
	endgenerate


    // second reduction
    wire [17:0] sum10_FA;
    wire [17:0] carry10_FA;
    
    wire [17:0] tmp101_FA;
    wire [17:0] tmp102_FA;
    wire [17:0] tmp103_FA;

	assign tmp101_FA = {1'b1, 1'b1, E_MSB[2],sum00_HA[3:2],sum00_FA[15:4],sum00_FA[1]};
    assign tmp102_FA = {sum01_FA[12:11],carry00_HA[3:2],carry00_FA[15:3],carry00_HA[1]};
    assign tmp103_FA = {carry01_FA[11:10],sum01_FA[10:0],sum01_HA[2:1],pp_rad8_3[1],sum01_HA[0],sign_factor[2]};

    genvar i101;
    generate
        for (i101 = 0; i101 < 18; i101 = i101 + 1)
            begin : pp_fad110
            FAd pp_fad(tmp101_FA[i101],tmp102_FA[i101], tmp103_FA[i101], carry10_FA[i101],sum10_FA[i101]);
            end
    endgenerate

    wire [5:0] sum10_HA;
    wire [5:0] carry10_HA;
    
    wire [5:0] tmp101_HA;
    wire [5:0] tmp102_HA;

    assign tmp101_HA ={E_MSB[5],sum01_HA[4:3],sum01_FA[13],sum00_FA[3:2]};
    assign tmp102_HA ={carry01_HA[4:3],carry01_FA[13:12],carry00_FA[2:1]};

    genvar i102;
    generate
        for (i102 = 0; i102 < 6; i102 = i102 + 1)
            begin : pp_fad120
            HAd pp_fad(tmp101_HA[i102],tmp102_HA[i102], carry10_HA[i102],sum10_HA[i102]);
            end
    endgenerate
    // third reduction
    wire [12:0] sum20_FA;
    wire [12:0] carry20_FA;
    
    wire [12:0] tmp201_FA;
    wire [12:0] tmp202_FA;
    wire [12:0] tmp203_FA;

    assign tmp201_FA = {sum10_FA[15:4],sum10_FA[2]};
    assign tmp202_FA = {carry10_FA[14:3],carry10_FA[1]};
    assign tmp203_FA = {carry01_FA[9:0],carry01_HA[1:0]};

    genvar i201;
    generate
        for (i201 = 0; i201 < 13; i201 = i201 + 1)
            begin : pp_fad210
            FAd pp_fad(tmp201_FA[i201],tmp202_FA[i201], tmp203_FA[i201], carry20_FA[i201],sum20_FA[i201]);
            end
    endgenerate

    wire [7:0] sum20_HA;
    wire [7:0] carry20_HA;
    
    wire [7:0] tmp201_HA;
    wire [7:0] tmp202_HA;

    assign tmp201_HA ={1'b1,sum10_HA[5:2],sum10_FA[17:16],sum10_FA[3]};
    assign tmp202_HA ={carry10_HA[5:2],carry10_FA[17:15],carry10_FA[2]};

    genvar i202;
    generate
        for (i202 = 0; i202 < 8; i202 = i202 + 1)
            begin : pp_fad220
            HAd pp_fad(tmp201_HA[i202],tmp202_HA[i202], carry20_HA[i202],sum20_HA[i202]);
            end
    endgenerate

    // Final addition
	// CLA adder 

	wire [31:0] tmp_ADD1;
	wire [31:0] tmp_ADD2;

	assign tmp_ADD1 = {sum20_HA[7],sum20_HA[7:1],sum20_FA[12:1],sum20_HA[0],sum20_FA[0],sum10_FA[1],sum10_HA[1:0],sum10_FA[0],sum00_HA[1:0],sum00_FA[0],pp_rad8_0[2:0]};
	assign tmp_ADD2 = {carry20_HA[7:1],carry20_FA[12:1],carry20_HA[0],carry20_FA[0],carry10_FA[1],carry10_HA[1:0],carry10_FA[0],1'b0,carry00_HA[0],carry00_FA[0],3'b0,sign_factor[0]};
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



