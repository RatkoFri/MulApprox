module TL16_6_4(
    input [15:0] x,
    input [15:0] y,
    output [31:0] p
);


    // First complement 
    wire [15:0] x_abs;
    assign x_abs = x ^ {16{x[15]}};

    // is upper n-Q bits zero
    wire not_zeroUpX;
    assign not_zeroUpX = |(x_abs[15:6]);
   
    wire [9:0] x_up;
    assign x_up = {x_abs[14:6],1'b1};

    wire [9:0] xTMP;
    assign xTMP = not_zeroUpX ? x_up : x_abs[9:0];


    // First complement 
    wire [15:0] y_abs;
    assign y_abs = y ^ {16{y[15]}};

    // is upper n-Q bits zero
    wire not_zeroUpY;
    assign not_zeroUpY = |(y_abs[15:6]);


    wire [9:0] y_up;
    assign y_up = {y_abs[14:6],1'b1};

    wire [9:0] yTMP;
    assign yTMP = not_zeroUpY ? y_up : y_abs[9:0];


    wire [19:0] pTMP;
    wire zeroTMP;
    ADAPT_10bit Nested(xTMP,yTMP,zeroTMP,pTMP);

    wire [1:0] ctrl_sig;
    assign ctrl_sig[1] = not_zeroUpX & not_zeroUpY;
    assign ctrl_sig[0] = not_zeroUpX ^ not_zeroUpY;

    wire [31:0] p_abs;

    fixedShift FinalShift(pTMP,ctrl_sig,p_abs);

    wire [31:0] p_tmp;

    wire p_sgn;
    assign p_sgn = x[15] ^ y[15];

    assign p_tmp = {32{p_sgn}} ^ p_abs;

    assign p = zeroTMP ? 32'b0 : p_tmp;

endmodule


module fixedShift(
    input [19:0] data_i,
    input [1:0] shift_i,
    output reg [31:0] data_o);
    always @*
        case (shift_i)
            2'b01: data_o = data_i << 5;
            2'b10: data_o = data_i << 10;
            default:  data_o = data_i;
        endcase
endmodule

module ADAPT_10bit(
    input [9:0] x,
    input [9:0] y,
    output zeroTMP,
    output [19:0] p
);

    // First complement 
    wire [9:0] x_abs;
    assign x_abs = x;

    // LOD + Priority Encoder
    wire [9:0] k_x0;
    wire zero_x0,one_x0;
    wire [3:0] k_x0_enc;

    LOD10 lod_x0(
        .data_i(x_abs),
        .zero_o(zero_x0),
        .data_o(k_x0),
        .data_enc(k_x0_enc));

    // LBarrel 
    wire [3:0] x_shift;

    LBarrel Lshift_x0(
            .data_i(x_abs),
            .shift_i(k_x0),
            .data_o(x_shift));

    // First complement 
    wire [9:0] y_abs;
    assign y_abs = y;

    // LOD + Priority Encoder
    wire [9:0] k_y0;
    wire zero_y0,one_y0;
    wire [3:0] k_y0_enc;

    LOD10 lod_y0(
        .data_i(y_abs),
        .zero_o(zero_y0),
        .data_o(k_y0),
        .data_enc(k_y0_enc));

    // LBarrel 
    wire [3:0] y_shift;

    LBarrel Lshift_y0(
            .data_i(y_abs),
            .shift_i(k_y0),
            .data_o(y_shift));


    // Addition 
    wire [8:0] x_log;
    wire [8:0] y_log;
    wire [8:0] p_log;

    assign x_log = {1'b0,k_x0_enc,x_shift};
    assign y_log = {1'b0,k_y0_enc,y_shift};


    assign p_log = x_log + y_log;

    //

    // Antilogarithm stage
    wire [19:0] PP_abs; //2*(n-q)
    wire [4:0] l1_input;
    wire p_sign;
    wire [19:0] PP_tmp; 
    
    assign l1_input = {1'b1,p_log[3:0]};
   
    L1Barrel L1shift_plog(
        .data_i(l1_input),
        .shift_i(p_log[8:4]),
        .data_o(p));

    assign zeroTMP = (zero_x0 | zero_y0);


endmodule


module LOD10(
    input [9:0] data_i,
    output zero_o,
    output [9:0] data_o,
    output [3:0] data_enc
    );
	
    wire [9:0] z;
    wire [2:0] zdet;
    wire [2:0] select;
    wire zero_h;
    wire zero_l;
    //*****************************************
    // Zero and one detection logic:
    //*****************************************
    assign zdet[2] = |(data_i[9:8]);
    assign zdet[1] = |(data_i[7:4]) ;
    assign zdet[0] = |(data_i[3:0]) ;
    assign zero_o  = ~( zdet[2]  | zdet[1] | zdet[0]  );


    //*****************************************
    // LODs:
    //*****************************************
    assign z[9] = data_i[9];
    assign z[8] = ~data_i[9] & data_i[8];

    LOD4 lod4_2 (
        .data_i(data_i[7:4]), 
        .data_o(z[7:4])
    );

    LOD4 lod4_1 (
        .data_i(data_i[3:0]), 
        .data_o(z[3:0])
    );
    
    //*****************************************
    // Select signals
    //*****************************************    
    LOD3 Middle(
        .data_i(zdet), 
        .data_o(select)       
    );

	 //*****************************************
	 // Multiplexers :
	 //*****************************************
	wire [9:0] tmp_out;

    assign tmp_out[9] = z[9];
    assign tmp_out[8] = z[8];

    Muxes2in1Array4 Inst_MUX214_3 (
        .data_i(z[7:4]), 
        .select_i(select[1]), 
        .data_o(tmp_out[7:4])
    );


	Muxes2in1Array4 Inst_MUX214_2 (
        .data_i(z[3:0]), 
        .select_i(select[0]), 
        .data_o(tmp_out[3:0])
    );


    // Enconding
    wire [2:0] low_enc; 
    assign low_enc = tmp_out[3:1] | tmp_out[7:5];


    assign data_enc[3] = select[2];
    assign data_enc[2] = select[1];
    assign data_enc[1] = low_enc[2] | low_enc[1];
    assign data_enc[0] = low_enc[2] | low_enc[0] | tmp_out[9];


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

module LOD3(
    input [2:0] data_i,
    output [2:0] data_o
    );
	 
	 
	 //gates and IO assignments:
	 assign data_o[2] = data_i[2];
	 assign data_o[1] =(~data_i[2] & data_i[1]);
	 assign data_o[0] =(~data_i[2] & ~data_i[1] & data_i[0]);


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

module LBarrel(
    input [9:0] data_i,
    input [9:0] shift_i,
    output [3:0] data_o);
    
    assign data_o[3] = |(data_i[8:0] & shift_i[9:1]);

    assign data_o[2] = |(data_i[7:0] & shift_i[9:2]);

    assign data_o[1] = |(data_i[6:0] & shift_i[9:3]);
    
    assign data_o[0] = 1'b1;
        
endmodule

module L1Barrel(
    input [4:0] data_i,
    input [4:0] shift_i,
    output [19:0] data_o);
    reg [23:0] tmp; //2n+w-2q
    always @*
        case (shift_i)
           5'b00000: tmp = data_i;
           5'b00001: tmp = data_i << 1;
           5'b00010: tmp = data_i << 2;
           5'b00011: tmp = data_i << 3;
           5'b00100: tmp = data_i << 4;
           5'b00101: tmp = data_i << 5;
           5'b00110: tmp = data_i << 6;
           5'b00111: tmp = data_i << 7;
           5'b01000: tmp = data_i << 8;
           5'b01001: tmp = data_i << 9;
           5'b01010: tmp = data_i << 10;
           5'b01011: tmp = data_i << 11;
           5'b01100: tmp = data_i << 12;
           5'b01101: tmp = data_i << 13;
           5'b01110: tmp = data_i << 14;
           5'b01111: tmp = data_i << 15;
           5'b10000: tmp = data_i << 16;
           5'b10001: tmp = data_i << 17;
           5'b10010: tmp = data_i << 18;
           default:  tmp = data_i << 19;
        endcase
        assign data_o = tmp[23:4];
endmodule


