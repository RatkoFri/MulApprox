`timescale 1ns / 1ps

module R4ABM2p16( x,y,p);
// inputs
// y multiplicand
// x multipland 
input [15:0] x,y;
// output
output [31:0] p;
wire [7:0] sign_factor;


// first pp generation 
wire [16:0] p1;
assign sign_factor[0] = y[1] & y[0];
// inexact
genvar i;
generate
	for ( i = 0; i < 16; i = i+1 )
		begin : pp_first 
		booth_R4ABM2 pp_pr(x[i],y[1],p1[i]);
		end
endgenerate

booth last_pp0(x[15],x[15],y[1],y[0],1'b0,p1[16]);


// second
wire [16:0] p2;
assign sign_factor[1] = y[3] & (y[2] ^ y[1]);

// inexact
genvar i1;
generate
	for ( i1 = 0; i1 < 14; i1 = i1+1 )
		begin : pp_second 
		booth_R4ABM2 pp_pr(x[i1],y[3],p2[i1]);
		end
endgenerate

// exact
genvar i10;
generate
	for ( i10 = 14; i10 < 16; i10 = i10+1 )
		begin : pp_second_exact 
		booth pp_pr(x[i10],x[i10-1],y[3],y[2],y[1],p2[i10]);
		end
endgenerate

booth last_pp1(x[15],x[15],y[3],y[2],y[1],p2[16]);


// third
wire [16:0] p3;

assign sign_factor[2] = y[5] & (y[4] ^ y[3]);

// inexact
genvar i2;
generate
	for ( i2 = 0; i2 < 12; i2 = i2+1 )
		begin : pp_third 
		booth_R4ABM2 pp_pr(x[i2],y[5],p3[i2]);
		end
endgenerate

// exact
genvar j21;
generate
	for ( j21 = 12; j21 < 16; j21 = j21+1 )
		begin : pp_third_exact 
		booth pp_pr(x[j21],x[j21-1],y[5],y[4],y[3],p3[j21]);
		end
endgenerate

booth last_pp2(x[15],x[15],y[5],y[4],y[3],p3[16]);





// fourth
wire [16:0] p4;
assign sign_factor[3] = y[7] & (y[6] ^ y[5]);

// inexact
genvar i3;
generate
	for ( i3 = 0; i3 < 10; i3 = i3+1 )
		begin : pp_fourth 
		booth_R4ABM2 pp_pr(x[i3],y[7],p4[i3]);
		end
endgenerate

// exact
genvar j3;
generate
	for ( j3 = 10; j3 < 16; j3 = j3+1 )
		begin : pp_fourth_exact 
		booth pp_pr(x[j3],x[j3-1],y[7],y[6],y[5],p4[j3]);
		end
endgenerate

booth last_pp3(x[15],x[15],y[7],y[6],y[5],p4[16]);


// fifth
wire [16:0] p5;
assign sign_factor[4] = y[9] & (y[8] ^ y[7]);

// inexact
genvar i4;
generate
	for ( i4 = 0; i4 < 8; i4 = i4+1 )
		begin : pp_fifth 
		booth_R4ABM2 pp_pr(x[i4],y[9],p5[i4]);
		end
endgenerate

// exact
genvar j4;
generate
	for ( j4 = 8; j4 < 16; j4 = j4+1 )
		begin : pp_fifth_exact 
		booth pp_pr(x[j4],x[j4-1],y[9],y[8],y[7],p5[j4]);
		end
endgenerate

booth last_pp4(x[15],x[15],y[9],y[8],y[7],p5[16]);

// sixt
wire [16:0] p6;
assign sign_factor[5] = y[11] & (y[10] ^ y[9]);

// inexact
genvar i5;
generate
	for ( i5 = 0; i5 < 6; i5 = i5+1 )
		begin : pp_sixt
		booth_R4ABM2 pp_pr(x[i5],y[11],p6[i5]);
		end
endgenerate

// exact
genvar j5;
generate
	for ( j5 = 6; j5 < 16; j5 = j5+1 )
		begin : pp_sixt_exact 
		booth pp_pr(x[j5],x[j5-1],y[11],y[10],y[9],p6[j5]);
		end
endgenerate

booth last_pp5(x[15],x[15],y[11],y[10],y[9],p6[16]);

// seven
wire [16:0] p7;
assign sign_factor[6] = y[13] & (y[12] ^ y[11]);

// inexact
genvar i6;
generate
	for ( i6 = 0; i6 < 4; i6 = i6+1 )
		begin : pp_seven
		booth_R4ABM2 pp_pr(x[i6],y[13],p7[i6]);
		end
endgenerate

// exact
genvar j6;
generate
	for ( j6 = 4; j6 < 16; j6 = j6+1 )
		begin : pp_seven_exact 
		booth pp_pr(x[j6],x[j6-1],y[13],y[12],y[11],p7[j6]);
		end
endgenerate

booth last_pp6(x[15],x[15],y[13],y[12],y[11],p7[16]);

// eight
wire [16:0] p8;
assign sign_factor[7] = y[15] & (y[14] ^ y[13]);



// inexact
genvar i7;
generate
	for ( i7 = 0; i7 < 2; i7 = i7+1 )
		begin : pp_eight
		booth_R4ABM2 pp_pr(x[i7],y[15],p8[i7]);
		end
endgenerate

// exact
genvar j7;
generate
	for ( j7 = 2; j7 < 16; j7 = j7+1 )
		begin : pp_eight_exact 
		booth pp_pr(x[j7],x[j7-1],y[15],y[14],y[13],p8[j7]);
		end
endgenerate

booth last_pp7(x[15],x[15],y[15],y[14],y[13],p8[16]);



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

assign tmp_ADD1 = {sum30_HA[15:8],sum30_FA[11:1],sum30_HA[7],sum30_FA[0],sum30_HA[6:1],sum20_HA[1],sum30_HA[0],sum20_HA[0],sum10_HA[0],sum00_HA[0]}; 
assign tmp_ADD2 = {carry30_HA[14:8],carry30_FA[11:1],carry30_HA[7],carry30_FA[0],carry30_HA[6:1],1'b0,carry30_HA[0],4'b0}; 


// Product
assign p = tmp_ADD1 + tmp_ADD2;

endmodule


// generation of codes

// calculate correction vector




//generation of inner products

module booth(a1,a0,b2,b1,b0,p);
	input a1,a0,b2,b1,b0;
	output p;
    wire [1:0] k;
    assign k[0] = (b1 ^ b0) & (b2 ^ a1);
    assign k[1] = (~(b1 ^ b0)) & (b2 ^ b1) & (b2 ^ a0);
    assign p = k[0] | k[1];
endmodule

module booth_R4ABM2(a0,b2,p);
	input a0,b2;
	output p;
    assign p = b2 ^ a0;
endmodule

//sign_factor generate




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

module carry_lookahead_adder
  #(parameter WIDTH = 16)
  (
   input [WIDTH-1:0] i_add1,
   input [WIDTH-1:0] i_add2,
   output [WIDTH:0]  o_result
   );
     
  wire [WIDTH:0]     w_C;
  wire [WIDTH-1:0]   w_G, w_P, w_SUM;
 
  // Create the Full Adders
  genvar  ii;
  generate
    for (ii=0; ii<WIDTH; ii=ii+1) 
      begin
        FA full_adder_inst
            ( 
              .a(i_add1[ii]),
              .b(i_add2[ii]),
              .c(w_C[ii]),
              .sm(w_SUM[ii]),
              .cy()
              );
      end
  endgenerate
 
  // Create the Generate (G) Terms:  Gi=Ai*Bi
  // Create the Propagate Terms: Pi=Ai+Bi
  // Create the Carry Terms:
  genvar             jj;
  generate
    for (jj=0; jj<WIDTH; jj=jj+1) 
      begin
        assign w_G[jj]   = i_add1[jj] & i_add2[jj];
        assign w_P[jj]   = i_add1[jj] | i_add2[jj];
        assign w_C[jj+1] = w_G[jj] | (w_P[jj] & w_C[jj]);
      end
  endgenerate
   
  assign w_C[0] = 1'b0; // no carry input on first adder
 
  assign o_result = {w_C[WIDTH], w_SUM};   // Verilog Concatenation
 
endmodule // carry_lookahead_adder
