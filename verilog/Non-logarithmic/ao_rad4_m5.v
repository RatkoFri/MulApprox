
module ao_rad4_m5(
    input [15:0] x,
    input [15:0] y,
    output [31:0] p
    );

    wire [2:0] sign_factor;
    wire [16:0] PP_2;
    wire [16:0] PP_1;
    wire [16:0] PP_0;
    wire [2:0] tmp;

    
// Calculates PP_4 
    rad4_BE PP4_gen(
        .x1(y[10:8]),
        .y(x),
        .sign_factor(sign_factor[2]),
        .PP(PP_2)
        );

// Calculates PP_3 
    rad4_BE PP3_gen(
        .x1(y[8:6]),
        .y(x),
        .sign_factor(sign_factor[1]),
        .PP(PP_1)
        );
// Calculates PP_2y[6:4]
    assign tmp = y[6:4];

    rad4_BE PP2_gen(
        .x1(tmp),
        .y(x),
        .sign_factor(sign_factor[0]),
        .PP(PP_0)
        );
//    



// Partial product addition 

    PP_add Final(
        .sign_factor(sign_factor),
        .PP_2(PP_2),
        .PP_1(PP_1),
        .PP_0(PP_0),
        .p(p)
        );
        
endmodule



module rad4_BE(
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

module sgn_gen(one,two,sign,sign_factor);
    input sign,one,two;
    output sign_factor;
    wire k;
    or o1(k,one,two);
    and a1(sign_factor,sign,k);
endmodule


module PP_add(
    input [2:0] sign_factor,
    input [16:0] PP_2,
    input [16:0] PP_1,
    input [16:0] PP_0,
    output [31:0] p
    );
    wire [2:0] E_MSB;
    assign E_MSB[0] = ~PP_0[16];
    assign E_MSB[1] = ~PP_1[16];
    assign E_MSB[2] = ~PP_2[16];

     // First  reduction
    wire [16:0]   sum00_FA;
    wire [16:0] carry00_FA;
  

    wire [16:0] tmp001_FA;
    wire [16:0] tmp002_FA;
    wire [16:0] tmp003_FA;


    wire [1:0] tmp001_HA;
    wire [1:0] tmp002_HA;

    wire [1:0]   sum00_HA;
    wire [1:0] carry00_HA;
  

    assign tmp001_FA = {E_MSB[0],{2{PP_0[16]}},PP_0[16:4],PP_0[2]};
    assign tmp002_FA = {E_MSB[1],PP_1[16:2],PP_1[0]};
    assign tmp003_FA = {PP_2[15:0],sign_factor[1]};

    genvar i001;
    generate
        for (i001 = 0; i001 < 17; i001 = i001 + 1)
            begin : pp_FAd500
            FAd pp_FAd(tmp001_FA[i001],tmp002_FA[i001], tmp003_FA[i001], carry00_FA[i001],sum00_FA[i001]);
            end
    endgenerate

    assign tmp001_HA = {1'b1,PP_0[3]};
    assign tmp002_HA = {PP_2[16],PP_1[1]};
    
    genvar i002;
    generate
        for (i002 = 0; i002 < 2; i002 = i002 + 1)
            begin : pp_HAd100
            HAd pp_HAdx(tmp001_HA[i002],tmp002_HA[i002], carry00_HA[i002],sum00_HA[i002]);
            end
    endgenerate

    // second reduction

    wire [16:0]   sum20_HA;
    wire [16:0] carry20_HA;
  

    wire [16:0] tmp201_HA;
    wire [16:0] tmp202_HA;



    wire  sum20_FA;
    wire  carry20_FA;
  


    FAd pp_FAdxxxx(sum00_FA[1], carry00_HA[0],sign_factor[2],carry20_FA,sum20_FA);


    assign tmp201_HA = {E_MSB[2],sum00_HA[1],sum00_FA[16:2]};
    assign tmp202_HA = {carry00_HA[1],carry00_FA[16:1]};
    
    genvar i007;
    generate
        for (i007 = 0; i007 < 17; i007 = i007 + 1)
            begin : pp_HAd310
            HAd pp_HAdx(tmp201_HA[i007],tmp202_HA[i007], carry20_HA[i007],sum20_HA[i007]);
            end
    endgenerate

    // Final addition

    wire [27:0] tmp_sum;
    wire [27:0] tmp_add1;
    wire [27:0] tmp_add2;

    assign tmp_add1 = {1'b1,sum20_HA,sum20_FA,sum00_HA[0],sum00_FA[0],PP_0[1:0],2'b0,2'b0,1'b0}; // shift one place
    assign tmp_add2 = {carry20_HA,carry20_FA,1'b0,carry00_FA[0],1'b0,1'b0,sign_factor[0],2'b0,2'b0,1'b0}; // shift one place

    assign tmp_sum = tmp_add1 + tmp_add2;

    assign p = {{4{tmp_sum[27]}},tmp_sum};


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
	xor x1(sm,a,b);
	and a1(cy,a,b);
endmodule 

