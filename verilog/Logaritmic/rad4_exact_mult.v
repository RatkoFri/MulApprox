`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:18:19 03/28/2018 
// Design Name: 
// Module Name:    exact_Booth_mult 
// Project Name: 
// Target Devices: 

//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module rad4_exact_mult( x,y,p);
// inputs
// y multiplicand
// x multipland 
input [15:0] x,y;
// output
output [31:0] p;

wire [7:0] sign,two,one;

// first partial product

// code generation 

code code0(one[0],two[0],sign[0],y[1],y[0], 1'b0);

genvar j;
generate
	for ( j = 1; j < 8; j = j+1 )
		begin : pp_code
		code code_gen(one[j],two[j],sign[j],y[2*j+1],y[2*j], y[2*j-1]);
		end
endgenerate

wire [16:0] tmp1_pp; 
assign tmp1_pp = {x[15],x}; // This variable is introduced because pp has 17 bits

// first pp generation 
wire [16:0] p1;
wire [17:0] out1;
assign out1[0] = sign[0];

genvar i;
generate
	for ( i = 0; i < 17; i = i+1 )
		begin : pp_first 
		product pp_pr(tmp1_pp[i],out1[i],one[0],two[0],sign[0],p1[i],out1[i+1]);
		end
endgenerate



// second pp generation 
wire[16:0] p2;
wire[17:0] out2;
assign out2[0] = sign[1];


genvar i2;
generate
	for ( i2 = 0; i2 < 17; i2 = i2+1 )
		begin : pp_second 
		product pp_pr(tmp1_pp[i2],out2[i2],one[1],two[1],sign[1],p2[i2],out2[i2+1]);
		end
endgenerate


// third pp generation 
wire [16:0] p3;
wire [17:0] out3;
assign out3[0] = sign[2];

genvar i3;
generate
	for ( i3 = 0; i3 < 17; i3 = i3+1 )
		begin : pp_third 
		product pp_pr(tmp1_pp[i3],out3[i3],one[2],two[2],sign[2],p3[i3],out3[i3+1]);
		end
endgenerate


// fourth pp generation 
wire [16:0] p4;
wire [17:0] out4;
assign out4[0] = sign[3];

genvar i4;
generate
	for ( i4 = 0; i4 < 17; i4 = i4+1 )
		begin : pp_fourth 
		product pp_pr(tmp1_pp[i4],out4[i4],one[3],two[3],sign[3],p4[i4],out4[i4+1]);
		end
endgenerate


// fifth pp generation 
wire [16:0] p5;
wire [17:0] out5;
assign out5[0] = sign[4];

genvar i5;
generate
	for ( i5 = 0; i5 < 17; i5 = i5+1 )
		begin : pp_fifth
		product pp_pr(tmp1_pp[i5],out5[i5],one[4],two[4],sign[4],p5[i5],out5[i5+1]);
		end
endgenerate

// sixth pp generation 
wire [16:0] p6;
wire [17:0] out6;
assign out6[0] = sign[5];

genvar i6;
generate
	for ( i6 = 0; i6 < 17; i6 = i6+1 )
		begin : pp_sixt
		product pp_pr(tmp1_pp[i6],out6[i6],one[5],two[5],sign[5],p6[i6],out6[i6+1]);
		end
endgenerate

// seventh pp generation 
wire [16:0] p7;
wire [17:0] out7;
assign out7[0] = sign[6];

genvar i7;
generate
	for ( i7 = 0; i7 < 17; i7 = i7+1 )
		begin : pp_seventh
		product pp_pr(tmp1_pp[i7],out7[i7],one[6],two[6],sign[6],p7[i7],out7[i7+1]);
		end
endgenerate

// eight pp generation 
wire [16:0] p8;
wire [17:0] out8;
assign out8[0] = sign[7];

genvar i8;
generate
	for ( i8 = 0; i8 < 17; i8 = i8+1 )
		begin : pp_eight
		product pp_pr(tmp1_pp[i8],out8[i8],one[7],two[7],sign[7],p8[i8],out8[i8+1]);
		end
endgenerate

// Invert MSB
wire [7:0] E_MSB;
wire E_MSB0_neg;
/*
xnor xn1(E_MSB[0],p1[16],x[15]);
xnor xn2(E_MSB[1],p2[16],x[15]);
xnor xn3(E_MSB[2],p3[16],x[15]);
xnor xn4(E_MSB[3],p4[16],x[15]);
xnor xn5(E_MSB[4],p5[16],x[15]);
xnor xn6(E_MSB[5],p6[16],x[15]);
xnor xn7(E_MSB[6],p7[16],x[15]);
xnor xn8(E_MSB[7],p8[16],x[15]);
*/
not xn1(E_MSB[0],p1[16]);
not xn2(E_MSB[1],p2[16]);
not xn3(E_MSB[2],p3[16]);
not xn4(E_MSB[3],p4[16]);
not xn5(E_MSB[4],p5[16]);
not xn6(E_MSB[5],p6[16]);
not xn7(E_MSB[6],p7[16]);
not xn8(E_MSB[7],p8[16]);


not n1(E_MSB0_neg,E_MSB[0]);


// Sign_factors generate
wire [7:0] sign_factor;

genvar i_sign;
generate
	for ( i_sign = 0; i_sign < 8; i_sign = i_sign+1 )
		begin : sgn_fac
		sgn_gen sgn_genXX(one[i_sign],two[i_sign],sign[i_sign],sign_factor[i_sign]);
		end
endgenerate


// first reduction 

	// First group

wire [16:0] sum00_FA;
wire [16:0] carry00_FA;
wire [2:0] sum00_HA;
wire [2:0] carry00_HA;

wire [2:0] tmp001_HA;
wire [2:0] tmp002_HA;

assign tmp001_HA = {1'b1,p1[3],p1[0]};
assign tmp002_HA = {p3[16],p2[1],sign_factor[0]};

genvar i000;
generate
	for (i000 = 0; i000 < 3; i000 = i000 + 1)
		begin : pp_had000
		HAd pp_had(tmp001_HA[i000],tmp002_HA[i000],carry00_HA[i000],sum00_HA[i000]);
		end
endgenerate

wire [16:0] tmp001_FA;
wire [16:0] tmp002_FA;
wire [16:0] tmp003_FA;

assign tmp001_FA = {E_MSB[0],E_MSB0_neg,E_MSB0_neg, p1[16:4],p1[2]};
assign tmp002_FA = {E_MSB[1],p2[16:2],p2[0]};
assign tmp003_FA = {p3[16:0],sign_factor[1]};

genvar i001;
generate
	for (i001 = 0; i001 < 17; i001 = i001 + 1)
		begin : pp_fad00
		FAd pp_fad(tmp001_FA[i001],tmp002_FA[i001], tmp003_FA[i001], carry00_FA[i001],sum00_FA[i001]);
		end
endgenerate

// Second group

wire [15:0] sum01_FA;
wire [15:0] carry01_FA;
wire [3:0] sum01_HA;
wire [3:0] carry01_HA;

wire [3:0] tmp011_HA;
wire [3:0] tmp012_HA;

assign tmp011_HA = {1'b1,E_MSB[4],p4[3],p4[0]};
assign tmp012_HA = {p6[16:15],p5[1],sign_factor[3]};

genvar i010;
generate
	for (i010 = 0; i010 < 4; i010 = i010 + 1)
		begin : pp_had01
		HAd pp_had(tmp011_HA[i010],tmp012_HA[i010],carry01_HA[i010],sum01_HA[i010]);
		end
endgenerate

wire [15:0] tmp011_FA;
wire [15:0] tmp012_FA;
wire [15:0] tmp013_FA;

assign tmp011_FA = {1'b1,E_MSB[3],p4[16:4],p4[2]};
assign tmp012_FA = {p5[16:2],p5[0]};
assign tmp013_FA = {p6[14:0],sign_factor[4]};

genvar i011;
generate
	for (i011 = 0; i011 < 16; i011 = i011 + 1)
		begin : pp_fad01
		FAd pp_fad(tmp011_FA[i011],tmp012_FA[i011], tmp013_FA[i011], carry01_FA[i011],sum01_FA[i011]);
		end
endgenerate


	// Third group

wire  sum02_FA;
wire  carry02_FA;
wire [16:0] sum02_HA;
wire [16:0] carry02_HA;



FAd f020(p7[2],p8[0],sign_factor[7],carry02_FA,sum02_FA);

wire [16:0] tmp021_HA;
wire [16:0] tmp022_HA;

assign tmp021_HA = {1'b1,E_MSB[6],p7[16:3],p7[0]};
assign tmp022_HA = {p8[16:1],sign_factor[6]};

genvar i020;
generate
	for (i020 = 0; i020  < 17; i020  = i020  + 1)
		begin : pp_had02
		HAd pp_had(tmp021_HA[i020],tmp022_HA[i020],carry02_HA[i020],sum02_HA[i020]);
		end
endgenerate


// Second reduction 

	//First group 

wire [16:0] sum10_FA;
wire [16:0] carry10_FA;
wire [3:0] sum10_HA;
wire [3:0] carry10_HA;

HAd h100(p1[1],carry00_HA[0],carry10_HA[0],sum10_HA[0]);
HAd h101(sum00_HA[1],carry00_FA[0],carry10_HA[1],sum10_HA[1]);
HAd h102(sum00_FA[2],carry00_FA[1],carry10_HA[2],sum10_HA[2]);
HAd h103(1'b1,sum01_FA[13],carry10_HA[3],sum10_HA[3]);

wire[16:0] tmp100;
wire[16:0] tmp101;
wire[16:0] tmp102;

assign tmp100 = { E_MSB[2],sum00_HA[2],sum00_FA[16:3],sum00_FA[1]};
assign tmp101 = {carry00_HA[2],carry00_FA[16:2],carry00_HA[1]};
assign tmp102 = {sum01_FA[12:1],sum01_HA[1],sum01_FA[0],p4[1],sum01_HA[0],sign_factor[2]};

genvar i11;
generate
	for(i11 = 0; i11 < 17; i11 = i11 +1 )
		begin : pp_fad10
		FAd pp_fad(tmp100[i11],tmp101[i11],tmp102[i11],carry10_FA[i11],sum10_FA[i11]);
		end
endgenerate


   // Second group 

wire [13:0] sum11_FA;
wire [13:0] carry11_FA;
wire [6:0] sum11_HA;
wire [6:0] carry11_HA;   

wire[6:0] tmp100_HA;
wire[6:0] tmp101_HA;

assign tmp100_HA = {E_MSB[7],sum02_HA[16:14],carry01_FA[4],carry01_FA[2],carry01_HA[1]};
assign tmp101_HA = {carry02_HA[16:13],sum02_FA,sum02_HA[0],sign_factor[5]};

genvar i12;
generate
	for(i12 = 0; i12 < 7; i12 = i12 +1 )
		begin : pp_had11
		HAd pp_had(tmp100_HA[i12],tmp101_HA[i12],carry11_HA[i12],sum11_HA[i12]);
		end
endgenerate

wire[13:0] tmp110_FA;
wire[13:0] tmp111_FA;
wire[13:0] tmp112_FA;

assign tmp110_FA = {carry01_HA[3:2],carry01_FA[15:5],carry01_FA[3]};
assign tmp111_FA = {sum02_HA[13:1],p7[1]};
assign tmp112_FA = {carry02_HA[12:1],carry02_FA,carry02_HA[0]};

genvar i13;
generate
	for(i13 = 0; i13 < 14; i13 = i13 +1 )
		begin : pp_fad12
		FAd pp_fad(tmp110_FA[i13],tmp111_FA[i13],tmp112_FA[i13],carry11_FA[i13],sum11_FA[i13]);
		end
endgenerate

// Third reduction 

wire [20:0] sum20_FA;
wire [20:0] carry20_FA;
wire [7:0] sum20_HA;
wire [7:0] carry20_HA; 

wire[7:0] tmp200_HA;
wire[7:0] tmp201_HA;

assign tmp200_HA = {sum11_HA[6:4],sum10_FA[3],sum10_FA[1],sum10_HA[2],sum10_FA[0],sum00_FA[0]};
assign tmp201_HA = {carry11_HA[5:3],carry10_FA[2],carry10_HA[2],carry10_FA[0],carry10_HA[1],carry10_HA[0]};

genvar i20;
generate
	for(i20 = 0; i20 < 8; i20 = i20 +1 )
		begin : pp_had20 
		HAd pp_had(tmp200_HA[i20],tmp201_HA[i20],carry20_HA[i20],sum20_HA[i20]);
		end
endgenerate

wire[20:0] tmp200_FA;
wire[20:0] tmp201_FA;
wire[20:0] tmp202_FA;

assign tmp200_FA = {1'b1,E_MSB[5],sum01_HA[3:2],sum01_FA[15:14],sum10_HA[3],sum10_FA[16:4],sum10_FA[2]};
assign tmp201_FA = {sum11_HA[3],sum11_FA[13:10],carry10_HA[3],carry10_FA[16:3],carry10_FA[1]};
assign tmp202_FA = {carry11_FA[13:9],sum11_FA[9:1],sum11_HA[2],sum11_FA[0],sum11_HA[1],carry01_FA[1],sum11_HA[0],carry01_FA[0],carry01_HA[0]};

genvar i21;
generate
	for(i21 = 0; i21 < 21; i21 = i21 +1 )
		begin : pp_fad20
		FAd pp_fad(tmp200_FA[i21],tmp201_FA[i21],tmp202_FA[i21],carry20_FA[i21],sum20_FA[i21]);
		end
endgenerate




// Fourth reduction

wire [11:0] sum30_FA;
wire [11:0] carry30_FA;
wire [16:0] sum30_HA;
wire [16:0] carry30_HA; 

wire[16:0] tmp300_HA;
wire[16:0] tmp301_HA;

assign tmp300_HA = {carry11_HA[6],sum20_HA[7:5] ,sum20_FA[20:16],sum20_FA[4],sum20_FA[2:1],sum20_HA[4],sum20_FA[0],sum20_HA[3:2],sum10_HA[1]};
assign tmp301_HA = {carry20_HA[7:5],carry20_FA[20:15],carry20_FA[3],carry20_FA[1],carry20_HA[4],carry20_FA[0],carry20_HA[3:0]};

genvar i30;
generate
	for(i30 = 0; i30 < 17; i30 = i30 +1 )
		begin : pp_had30
		HAd pp_had(tmp300_HA[i30],tmp301_HA[i30],carry30_HA[i30],sum30_HA[i30]);
		end
endgenerate

wire[11:0] tmp300_FA;
wire[11:0] tmp301_FA;
wire[11:0] tmp302_FA;

assign tmp300_FA = {sum20_FA[15:5],sum20_FA[3]};
assign tmp301_FA = {carry20_FA[14:4],carry20_FA[2]};
assign tmp302_FA = {carry11_FA[8:1],carry11_HA[2],carry11_FA[0],carry11_HA[1:0]};


genvar i31;
generate
	for(i31 = 0; i31 < 12; i31 = i31 +1 )
		begin : pp_fad31
		FAd pp_fad(tmp300_FA[i31],tmp301_FA[i31], tmp302_FA[i31], carry30_FA[i31],sum30_FA[i31]);
		end
endgenerate

// Final CLA

wire [31:0] tmp_ADD1;
wire [31:0] tmp_ADD2;
//wire [31:0] tmp_SUM;
//wire [30:0] tmp_2;

assign tmp_ADD1 = {sum30_HA[15:8],sum30_FA[11:1],sum30_HA[7],sum30_FA[0],sum30_HA[6:1],sum20_HA[1],sum30_HA[0],sum20_HA[0],sum10_HA[0],sum00_HA[0]}; 
assign tmp_ADD2 = {carry30_HA[14:8],carry30_FA[11:1],carry30_HA[7],carry30_FA[0],carry30_HA[6:1],1'b0,carry30_HA[0],4'b0}; 



// Product
assign p = tmp_ADD1 + tmp_ADD2;

endmodule


// generation of codes

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

// calculate correction vector




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



module FA(a,b,c,cy,sm);
	input a,b,c;
	output cy,sm;
	wire x,y,z;
	xor x1(x,a,b);
	xor x2(sm,x,c);
	and a1(y,a,b);
	and a2(z,x,c);
	or o1(cy,y,z);
endmodule


