
// Flip-flop.

module smul_flipflop (
    input  wire clk,
    input  wire clken,
    input  wire d,
    output reg  q );

always @(posedge clk)
begin
    if (clken)
        q <= d;
end

endmodule


// Inverter.

module smul_inverter (
    input  wire d,
    output wire q );

assign q = ~d;

endmodule


// Half-adder.

module smul_half_add (
    input  wire x,
    input  wire y,
    output wire d,
    output wire c );

assign d = x ^ y;
assign c = x & y;

endmodule


// Full-adder.

module smul_full_add (
    input  wire x,
    input  wire y,
    input  wire z,
    output wire d,
    output wire c );

assign d = x ^ y ^ z;
assign c = (x & y) | (y & z) | (x & z);

endmodule


// Booth negative flag.

module smul_booth_neg (
    input  wire p0,
    input  wire p1,
    input  wire p2,
    output wire f );

assign f = p2 & ((~p1) | (~p0));

endmodule


// Booth partial product generator.

module smul_booth_prod (
    input  wire p0,
    input  wire p1,
    input  wire p2,
    input  wire u0,
    input  wire u1,
    output reg  y );

always @ (*)
begin
    case ({p2, p1, p0})
        3'b000  : y = 1'b0;
        3'b001  : y = u1;
        3'b010  : y = u1;
        3'b011  : y = u0;
        3'b100  : y = ~u0;
        3'b101  : y = ~u1;
        3'b110  : y = ~u1;
        default : y = 1'b0;
    endcase
end

endmodule


// Deterimine carry generate and carry propagate.

module smul_carry_prop (
    input  wire a,
    input  wire b,
    output wire g,
    output wire p );

assign g = a & b;
assign p = a ^ b;

endmodule


// Merge two carry propagation trees.

module smul_carry_merge (
    input  wire g0,
    input  wire p0,
    input  wire g1,
    input  wire p1,
    output wire g,
    output wire p );

assign g = g1 | (g0 & p1);
assign p = p0 & p1;

endmodule


// Calculate carry-out through a carry propagation tree.

module smul_carry_eval (
    input  wire g,
    input  wire p,
    input  wire cin,
    output wire cout );

assign cout = g | (p & cin);

endmodule


/*
 * 16 x 16 bit signed multiplier
 *
 * 0 cycles pipeline delay
 */

module rad4_16bit (
    input  wire [15:0] x,
    input  wire [15:0] y,
    output wire [31:0] p );

wire wadd0d;
wire wadd0c;
wire wboothprod2;
wire wboothneg3;
wire wadd4d;
wire wadd4c;
wire wboothprod6;
wire wcarry7;
wire wcarry8g;
wire wcarry8p;
wire wadd10d;
wire wadd10c;
wire wadd12d;
wire wadd12c;
wire wboothprod14;
wire wboothprod15;
wire wboothneg16;
wire wcarry17;
wire wcarry18g;
wire wcarry18p;
wire wcarry20g;
wire wcarry20p;
wire wadd22d;
wire wadd22c;
wire wadd24d;
wire wadd24c;
wire wboothprod26;
wire wboothprod27;
wire wcarry28;
wire wcarry29g;
wire wcarry29p;
wire wadd31d;
wire wadd31c;
wire wadd33d;
wire wadd33c;
wire wadd35d;
wire wadd35c;
wire wboothprod37;
wire wboothprod38;
wire wboothprod39;
wire wboothneg40;
wire wcarry41;
wire wcarry42g;
wire wcarry42p;
wire wcarry44g;
wire wcarry44p;
wire wcarry46g;
wire wcarry46p;
wire wadd48d;
wire wadd48c;
wire wadd50d;
wire wadd50c;
wire wadd52d;
wire wadd52c;
wire wboothprod54;
wire wboothprod55;
wire wboothprod56;
wire wcarry57;
wire wcarry58g;
wire wcarry58p;
wire wadd60d;
wire wadd60c;
wire wadd62d;
wire wadd62c;
wire wadd64d;
wire wadd64c;
wire wboothprod66;
wire wboothprod67;
wire wboothprod68;
wire wadd69d;
wire wadd69c;
wire wboothprod71;
wire wboothneg72;
wire wcarry73;
wire wcarry74g;
wire wcarry74p;
wire wcarry76g;
wire wcarry76p;
wire wadd78d;
wire wadd78c;
wire wadd80d;
wire wadd80c;
wire wadd82d;
wire wadd82c;
wire wadd84d;
wire wadd84c;
wire wboothprod86;
wire wboothprod87;
wire wboothprod88;
wire wboothprod89;
wire wcarry90;
wire wcarry91g;
wire wcarry91p;
wire wadd93d;
wire wadd93c;
wire wadd95d;
wire wadd95c;
wire wadd97d;
wire wadd97c;
wire wadd99d;
wire wadd99c;
wire wboothprod101;
wire wboothprod102;
wire wboothprod103;
wire wadd104d;
wire wadd104c;
wire wboothprod106;
wire wboothprod107;
wire wboothneg108;
wire wcarry109;
wire wcarry110g;
wire wcarry110p;
wire wcarry112g;
wire wcarry112p;
wire wcarry114g;
wire wcarry114p;
wire wcarry116g;
wire wcarry116p;
wire wadd118d;
wire wadd118c;
wire wadd120d;
wire wadd120c;
wire wadd122d;
wire wadd122c;
wire wadd124d;
wire wadd124c;
wire wboothprod126;
wire wboothprod127;
wire wboothprod128;
wire wadd129d;
wire wadd129c;
wire wboothprod131;
wire wboothprod132;
wire wcarry133;
wire wcarry134g;
wire wcarry134p;
wire wadd136d;
wire wadd136c;
wire wadd138d;
wire wadd138c;
wire wadd140d;
wire wadd140c;
wire wadd142d;
wire wadd142c;
wire wadd144d;
wire wadd144c;
wire wboothprod146;
wire wboothprod147;
wire wboothprod148;
wire wadd149d;
wire wadd149c;
wire wboothprod151;
wire wboothprod152;
wire wboothprod153;
wire wboothneg154;
wire wcarry155;
wire wcarry156g;
wire wcarry156p;
wire wcarry158g;
wire wcarry158p;
wire wadd160d;
wire wadd160c;
wire wadd162d;
wire wadd162c;
wire wadd164d;
wire wadd164c;
wire wadd166d;
wire wadd166c;
wire wadd168d;
wire wadd168c;
wire wboothprod170;
wire wboothprod171;
wire wboothprod172;
wire wadd173d;
wire wadd173c;
wire wboothprod175;
wire wboothprod176;
wire wboothprod177;
wire wcarry178;
wire wcarry179g;
wire wcarry179p;
wire wadd181d;
wire wadd181c;
wire wadd183d;
wire wadd183c;
wire wadd185d;
wire wadd185c;
wire wadd187d;
wire wadd187c;
wire wadd189d;
wire wadd189c;
wire wboothprod191;
wire wboothprod192;
wire wboothprod193;
wire wadd194d;
wire wadd194c;
wire wadd196d;
wire wadd196c;
wire wboothprod198;
wire wboothprod199;
wire wboothprod200;
wire wboothprod201;
wire wboothneg202;
wire wcarry203;
wire wcarry204g;
wire wcarry204p;
wire wcarry206g;
wire wcarry206p;
wire wcarry208g;
wire wcarry208p;
wire wadd210d;
wire wadd210c;
wire wadd212d;
wire wadd212c;
wire wadd214d;
wire wadd214c;
wire wadd216d;
wire wadd216c;
wire wadd218d;
wire wadd218c;
wire wboothprod220;
wire wboothprod221;
wire wboothprod222;
wire wadd223d;
wire wadd223c;
wire wadd225d;
wire wadd225c;
wire wboothprod227;
wire wboothprod228;
wire wboothprod229;
wire wboothprod230;
wire wcarry231;
wire wcarry232g;
wire wcarry232p;
wire wadd234d;
wire wadd234c;
wire wadd236d;
wire wadd236c;
wire wadd238d;
wire wadd238c;
wire wadd240d;
wire wadd240c;
wire wadd242d;
wire wadd242c;
wire wboothprod244;
wire wboothprod245;
wire wboothprod246;
wire wadd247d;
wire wadd247c;
wire wadd249d;
wire wadd249c;
wire wboothprod251;
wire wboothprod252;
wire wboothprod253;
wire wadd254d;
wire wadd254c;
wire wboothprod256;
wire wboothprod257;
wire wboothneg258;
wire wcarry259;
wire wcarry260g;
wire wcarry260p;
wire wcarry262g;
wire wcarry262p;
wire wadd264d;
wire wadd264c;
wire wadd266d;
wire wadd266c;
wire wadd268d;
wire wadd268c;
wire wadd270d;
wire wadd270c;
wire wadd272d;
wire wadd272c;
wire wadd274d;
wire wadd274c;
wire wboothprod276;
wire wboothprod277;
wire wboothprod278;
wire wadd279d;
wire wadd279c;
wire wboothprod281;
wire wboothprod282;
wire wboothprod283;
wire wadd284d;
wire wadd284c;
wire wboothprod286;
wire wboothprod287;
wire wcarry288;
wire wcarry289g;
wire wcarry289p;
wire wadd291d;
wire wadd291c;
wire wadd293d;
wire wadd293c;
wire wadd295d;
wire wadd295c;
wire wadd297d;
wire wadd297c;
wire wadd299d;
wire wadd299c;
wire wadd301d;
wire wadd301c;
wire wboothprod303;
wire wboothprod304;
wire wboothprod305;
wire wadd306d;
wire wadd306c;
wire wboothprod308;
wire wboothprod309;
wire wboothprod310;
wire wadd311d;
wire wadd311c;
wire wboothprod313;
wire wboothprod314;
wire wcarry315;
wire wcarry316g;
wire wcarry316p;
wire wcarry318g;
wire wcarry318p;
wire wcarry320g;
wire wcarry320p;
wire wcarry322g;
wire wcarry322p;
wire wcarry324g;
wire wcarry324p;
wire wadd326d;
wire wadd326c;
wire wadd328d;
wire wadd328c;
wire wadd330d;
wire wadd330c;
wire wadd332d;
wire wadd332c;
wire wadd334d;
wire wadd334c;
wire wadd336d;
wire wadd336c;
wire wboothprod338;
wire wboothprod339;
wire wadd340d;
wire wadd340c;
wire wboothprod342;
wire wboothprod343;
wire wboothprod344;
wire wadd345d;
wire wadd345c;
wire wboothprod347;
wire wboothprod348;
wire wcarry349;
wire wcarry350g;
wire wcarry350p;
wire wadd352d;
wire wadd352c;
wire wadd354d;
wire wadd354c;
wire wadd356d;
wire wadd356c;
wire wadd358d;
wire wadd358c;
wire wadd360d;
wire wadd360c;
wire wadd362d;
wire wadd362c;
wire winv364;
wire winv365;
wire wboothprod366;
wire wboothprod367;
wire wadd368d;
wire wadd368c;
wire wboothprod370;
wire wboothprod371;
wire wboothprod372;
wire wadd373d;
wire wadd373c;
wire wboothprod375;
wire wboothprod376;
wire wcarry377;
wire wcarry378g;
wire wcarry378p;
wire wcarry380g;
wire wcarry380p;
wire wadd382d;
wire wadd382c;
wire wadd384d;
wire wadd384c;
wire wadd386d;
wire wadd386c;
wire wadd388d;
wire wadd388c;
wire wadd390d;
wire wadd390c;
wire wadd392d;
wire wadd392c;
wire wboothprod394;
wire wboothprod395;
wire wadd396d;
wire wadd396c;
wire wboothprod398;
wire wboothprod399;
wire wboothprod400;
wire wboothprod401;
wire wcarry402;
wire wcarry403g;
wire wcarry403p;
wire wadd405d;
wire wadd405c;
wire wadd407d;
wire wadd407c;
wire wadd409d;
wire wadd409c;
wire wadd411d;
wire wadd411c;
wire wadd413d;
wire wadd413c;
wire winv415;
wire wboothprod416;
wire wboothprod417;
wire wboothprod418;
wire wadd419d;
wire wadd419c;
wire wboothprod421;
wire wboothprod422;
wire wboothprod423;
wire wcarry424;
wire wcarry425g;
wire wcarry425p;
wire wcarry427g;
wire wcarry427p;
wire wcarry429g;
wire wcarry429p;
wire wadd431d;
wire wadd431c;
wire wadd433d;
wire wadd433c;
wire wadd435d;
wire wadd435c;
wire wadd437d;
wire wadd437c;
wire wadd439d;
wire wadd439c;
wire wboothprod441;
wire wboothprod442;
wire wadd443d;
wire wadd443c;
wire wboothprod445;
wire wboothprod446;
wire wboothprod447;
wire wcarry448;
wire wcarry449g;
wire wcarry449p;
wire wadd451d;
wire wadd451c;
wire wadd453d;
wire wadd453c;
wire wadd455d;
wire wadd455c;
wire wadd457d;
wire wadd457c;
wire wadd459d;
wire wadd459c;
wire winv461;
wire wboothprod462;
wire wboothprod463;
wire wboothprod464;
wire wadd465d;
wire wadd465c;
wire wboothprod467;
wire wboothprod468;
wire wcarry469;
wire wcarry470g;
wire wcarry470p;
wire wcarry472g;
wire wcarry472p;
wire wadd474d;
wire wadd474c;
wire wadd476d;
wire wadd476c;
wire wadd478d;
wire wadd478c;
wire wadd480d;
wire wadd480c;
wire wadd482d;
wire wadd482c;
wire wboothprod484;
wire wboothprod485;
wire wadd486d;
wire wadd486c;
wire wboothprod488;
wire wboothprod489;
wire wcarry490;
wire wcarry491g;
wire wcarry491p;
wire wadd493d;
wire wadd493c;
wire wadd495d;
wire wadd495c;
wire wadd497d;
wire wadd497c;
wire wadd499d;
wire wadd499c;
wire wadd501d;
wire wadd501c;
wire winv503;
wire wboothprod504;
wire wboothprod505;
wire wboothprod506;
wire wboothprod507;
wire wcarry508;
wire wcarry509g;
wire wcarry509p;
wire wcarry511g;
wire wcarry511p;
wire wcarry513g;
wire wcarry513p;
wire wcarry515g;
wire wcarry515p;
wire wadd517d;
wire wadd517c;
wire wadd519d;
wire wadd519c;
wire wadd521d;
wire wadd521c;
wire wadd523d;
wire wadd523c;
wire wboothprod525;
wire wboothprod526;
wire wboothprod527;
wire wcarry528;
wire wcarry529g;
wire wcarry529p;
wire wadd531d;
wire wadd531c;
wire wadd533d;
wire wadd533c;
wire wadd535d;
wire wadd535c;
wire winv537;
wire wboothprod538;
wire wboothprod539;
wire wboothprod540;
wire wcarry541;
wire wcarry542g;
wire wcarry542p;
wire wcarry544g;
wire wcarry544p;
wire wadd546d;
wire wadd546c;
wire wadd548d;
wire wadd548c;
wire wadd550d;
wire wadd550c;
wire wboothprod552;
wire wboothprod553;
wire wcarry554;
wire wcarry555g;
wire wcarry555p;
wire wadd557d;
wire wadd557c;
wire wadd559d;
wire wadd559c;
wire winv561;
wire wboothprod562;
wire wboothprod563;
wire wcarry564;
wire wcarry565g;
wire wcarry565p;
wire wcarry567g;
wire wcarry567p;
wire wcarry569g;
wire wcarry569p;
wire wadd571d;
wire wadd571c;
wire wadd573d;
wire wadd573c;
wire wboothprod575;
wire wcarry576;
wire wcarry577g;
wire wcarry577p;
wire wadd579d;
wire wadd579c;
wire winv581;
wire wboothprod582;
wire wcarry583;
wire wcarry584g;
wire wcarry584p;
wire wcarry586g;
wire wcarry586p;
wire wadd588d;
wire wadd588c;
wire wcarry590;
wire wcarry591g;
wire wcarry591p;
smul_booth_prod u0 ( 1'b0, x[0], x[1], 1'b0, y[0], wboothprod2 );
smul_booth_neg u1 ( 1'b0, x[0], x[1], wboothneg3 );
smul_full_add u2 ( wboothprod2, wboothneg3, 1'b0, wadd0d, wadd0c );
smul_booth_prod u3 ( 1'b0, x[0], x[1], y[0], y[1], wboothprod6 );
smul_carry_prop u4 ( wboothprod2, wboothneg3, wcarry8g, wcarry8p );
smul_carry_eval u5 ( wcarry8g, wcarry8p, 1'b0, wcarry7 );
smul_full_add u6 ( wboothprod6, 1'b0, wcarry7, wadd4d, wadd4c );
smul_booth_prod u7 ( 1'b0, x[0], x[1], y[1], y[2], wboothprod14 );
smul_booth_prod u8 ( x[1], x[2], x[3], 1'b0, y[0], wboothprod15 );
smul_booth_neg u9 ( x[1], x[2], x[3], wboothneg16 );
smul_full_add u10 ( wboothprod14, wboothprod15, wboothneg16, wadd12d, wadd12c );
smul_carry_prop u11 ( wboothprod6, 1'b0, wcarry20g, wcarry20p );
smul_carry_merge u12 ( wcarry8g, wcarry8p, wcarry20g, wcarry20p, wcarry18g, wcarry18p );
smul_carry_eval u13 ( wcarry18g, wcarry18p, 1'b0, wcarry17 );
smul_full_add u14 ( wadd12d, 1'b0, wcarry17, wadd10d, wadd10c );
smul_booth_prod u15 ( 1'b0, x[0], x[1], y[2], y[3], wboothprod26 );
smul_booth_prod u16 ( x[1], x[2], x[3], y[0], y[1], wboothprod27 );
smul_full_add u17 ( wadd12c, wboothprod26, wboothprod27, wadd24d, wadd24c );
smul_carry_prop u18 ( wadd12d, 1'b0, wcarry29g, wcarry29p );
smul_carry_eval u19 ( wcarry29g, wcarry29p, wcarry17, wcarry28 );
smul_full_add u20 ( wadd24d, 1'b0, wcarry28, wadd22d, wadd22c );
smul_booth_prod u21 ( 1'b0, x[0], x[1], y[3], y[4], wboothprod37 );
smul_booth_prod u22 ( x[1], x[2], x[3], y[1], y[2], wboothprod38 );
smul_booth_prod u23 ( x[3], x[4], x[5], 1'b0, y[0], wboothprod39 );
smul_full_add u24 ( wboothprod37, wboothprod38, wboothprod39, wadd35d, wadd35c );
smul_booth_neg u25 ( x[3], x[4], x[5], wboothneg40 );
smul_full_add u26 ( wadd24c, wadd35d, wboothneg40, wadd33d, wadd33c );
smul_carry_prop u27 ( wadd24d, 1'b0, wcarry46g, wcarry46p );
smul_carry_merge u28 ( wcarry29g, wcarry29p, wcarry46g, wcarry46p, wcarry44g, wcarry44p );
smul_carry_merge u29 ( wcarry18g, wcarry18p, wcarry44g, wcarry44p, wcarry42g, wcarry42p );
smul_carry_eval u30 ( wcarry42g, wcarry42p, 1'b0, wcarry41 );
smul_full_add u31 ( wadd33d, 1'b0, wcarry41, wadd31d, wadd31c );
smul_booth_prod u32 ( 1'b0, x[0], x[1], y[4], y[5], wboothprod54 );
smul_booth_prod u33 ( x[1], x[2], x[3], y[2], y[3], wboothprod55 );
smul_booth_prod u34 ( x[3], x[4], x[5], y[0], y[1], wboothprod56 );
smul_full_add u35 ( wboothprod54, wboothprod55, wboothprod56, wadd52d, wadd52c );
smul_full_add u36 ( wadd33c, wadd35c, wadd52d, wadd50d, wadd50c );
smul_carry_prop u37 ( wadd33d, 1'b0, wcarry58g, wcarry58p );
smul_carry_eval u38 ( wcarry58g, wcarry58p, wcarry41, wcarry57 );
smul_full_add u39 ( wadd50d, 1'b0, wcarry57, wadd48d, wadd48c );
smul_booth_prod u40 ( 1'b0, x[0], x[1], y[5], y[6], wboothprod66 );
smul_booth_prod u41 ( x[1], x[2], x[3], y[3], y[4], wboothprod67 );
smul_booth_prod u42 ( x[3], x[4], x[5], y[1], y[2], wboothprod68 );
smul_full_add u43 ( wboothprod66, wboothprod67, wboothprod68, wadd64d, wadd64c );
smul_booth_prod u44 ( x[5], x[6], x[7], 1'b0, y[0], wboothprod71 );
smul_booth_neg u45 ( x[5], x[6], x[7], wboothneg72 );
smul_half_add u46 ( wboothprod71, wboothneg72, wadd69d, wadd69c );
smul_full_add u47 ( wadd52c, wadd64d, wadd69d, wadd62d, wadd62c );
smul_carry_prop u48 ( wadd50d, 1'b0, wcarry76g, wcarry76p );
smul_carry_merge u49 ( wcarry58g, wcarry58p, wcarry76g, wcarry76p, wcarry74g, wcarry74p );
smul_carry_eval u50 ( wcarry74g, wcarry74p, wcarry41, wcarry73 );
smul_full_add u51 ( wadd50c, wadd62d, wcarry73, wadd60d, wadd60c );
smul_booth_prod u52 ( 1'b0, x[0], x[1], y[6], y[7], wboothprod86 );
smul_booth_prod u53 ( x[1], x[2], x[3], y[4], y[5], wboothprod87 );
smul_booth_prod u54 ( x[3], x[4], x[5], y[2], y[3], wboothprod88 );
smul_full_add u55 ( wboothprod86, wboothprod87, wboothprod88, wadd84d, wadd84c );
smul_full_add u56 ( wadd64c, wadd69c, wadd84d, wadd82d, wadd82c );
smul_booth_prod u57 ( x[5], x[6], x[7], y[0], y[1], wboothprod89 );
smul_full_add u58 ( wadd62c, wadd82d, wboothprod89, wadd80d, wadd80c );
smul_carry_prop u59 ( wadd50c, wadd62d, wcarry91g, wcarry91p );
smul_carry_eval u60 ( wcarry91g, wcarry91p, wcarry73, wcarry90 );
smul_full_add u61 ( wadd80d, 1'b0, wcarry90, wadd78d, wadd78c );
smul_booth_prod u62 ( 1'b0, x[0], x[1], y[7], y[8], wboothprod101 );
smul_booth_prod u63 ( x[1], x[2], x[3], y[5], y[6], wboothprod102 );
smul_booth_prod u64 ( x[3], x[4], x[5], y[3], y[4], wboothprod103 );
smul_full_add u65 ( wboothprod101, wboothprod102, wboothprod103, wadd99d, wadd99c );
smul_booth_prod u66 ( x[5], x[6], x[7], y[1], y[2], wboothprod106 );
smul_booth_prod u67 ( x[7], x[8], x[9], 1'b0, y[0], wboothprod107 );
smul_booth_neg u68 ( x[7], x[8], x[9], wboothneg108 );
smul_full_add u69 ( wboothprod106, wboothprod107, wboothneg108, wadd104d, wadd104c );
smul_full_add u70 ( wadd84c, wadd99d, wadd104d, wadd97d, wadd97c );
smul_full_add u71 ( wadd80c, wadd82c, wadd97d, wadd95d, wadd95c );
smul_carry_prop u72 ( wadd80d, 1'b0, wcarry116g, wcarry116p );
smul_carry_merge u73 ( wcarry91g, wcarry91p, wcarry116g, wcarry116p, wcarry114g, wcarry114p );
smul_carry_merge u74 ( wcarry74g, wcarry74p, wcarry114g, wcarry114p, wcarry112g, wcarry112p );
smul_carry_merge u75 ( wcarry42g, wcarry42p, wcarry112g, wcarry112p, wcarry110g, wcarry110p );
smul_carry_eval u76 ( wcarry110g, wcarry110p, 1'b0, wcarry109 );
smul_full_add u77 ( wadd95d, 1'b0, wcarry109, wadd93d, wadd93c );
smul_booth_prod u78 ( 1'b0, x[0], x[1], y[8], y[9], wboothprod126 );
smul_booth_prod u79 ( x[1], x[2], x[3], y[6], y[7], wboothprod127 );
smul_booth_prod u80 ( x[3], x[4], x[5], y[4], y[5], wboothprod128 );
smul_full_add u81 ( wboothprod126, wboothprod127, wboothprod128, wadd124d, wadd124c );
smul_full_add u82 ( wadd99c, wadd104c, wadd124d, wadd122d, wadd122c );
smul_booth_prod u83 ( x[5], x[6], x[7], y[2], y[3], wboothprod131 );
smul_booth_prod u84 ( x[7], x[8], x[9], y[0], y[1], wboothprod132 );
smul_half_add u85 ( wboothprod131, wboothprod132, wadd129d, wadd129c );
smul_full_add u86 ( wadd97c, wadd122d, wadd129d, wadd120d, wadd120c );
smul_carry_prop u87 ( wadd95d, 1'b0, wcarry134g, wcarry134p );
smul_carry_eval u88 ( wcarry134g, wcarry134p, wcarry109, wcarry133 );
smul_full_add u89 ( wadd95c, wadd120d, wcarry133, wadd118d, wadd118c );
smul_booth_prod u90 ( 1'b0, x[0], x[1], y[9], y[10], wboothprod146 );
smul_booth_prod u91 ( x[1], x[2], x[3], y[7], y[8], wboothprod147 );
smul_booth_prod u92 ( x[3], x[4], x[5], y[5], y[6], wboothprod148 );
smul_full_add u93 ( wboothprod146, wboothprod147, wboothprod148, wadd144d, wadd144c );
smul_booth_prod u94 ( x[5], x[6], x[7], y[3], y[4], wboothprod151 );
smul_booth_prod u95 ( x[7], x[8], x[9], y[1], y[2], wboothprod152 );
smul_booth_prod u96 ( x[9], x[10], x[11], 1'b0, y[0], wboothprod153 );
smul_full_add u97 ( wboothprod151, wboothprod152, wboothprod153, wadd149d, wadd149c );
smul_full_add u98 ( wadd124c, wadd144d, wadd149d, wadd142d, wadd142c );
smul_full_add u99 ( wadd122c, wadd129c, wadd142d, wadd140d, wadd140c );
smul_booth_neg u100 ( x[9], x[10], x[11], wboothneg154 );
smul_full_add u101 ( wadd120c, wadd140d, wboothneg154, wadd138d, wadd138c );
smul_carry_prop u102 ( wadd95c, wadd120d, wcarry158g, wcarry158p );
smul_carry_merge u103 ( wcarry134g, wcarry134p, wcarry158g, wcarry158p, wcarry156g, wcarry156p );
smul_carry_eval u104 ( wcarry156g, wcarry156p, wcarry109, wcarry155 );
smul_full_add u105 ( wadd138d, 1'b0, wcarry155, wadd136d, wadd136c );
smul_booth_prod u106 ( 1'b0, x[0], x[1], y[10], y[11], wboothprod170 );
smul_booth_prod u107 ( x[1], x[2], x[3], y[8], y[9], wboothprod171 );
smul_booth_prod u108 ( x[3], x[4], x[5], y[6], y[7], wboothprod172 );
smul_full_add u109 ( wboothprod170, wboothprod171, wboothprod172, wadd168d, wadd168c );
smul_full_add u110 ( wadd144c, wadd149c, wadd168d, wadd166d, wadd166c );
smul_booth_prod u111 ( x[5], x[6], x[7], y[4], y[5], wboothprod175 );
smul_booth_prod u112 ( x[7], x[8], x[9], y[2], y[3], wboothprod176 );
smul_booth_prod u113 ( x[9], x[10], x[11], y[0], y[1], wboothprod177 );
smul_full_add u114 ( wboothprod175, wboothprod176, wboothprod177, wadd173d, wadd173c );
smul_full_add u115 ( wadd142c, wadd166d, wadd173d, wadd164d, wadd164c );
smul_half_add u116 ( wadd140c, wadd164d, wadd162d, wadd162c );
smul_carry_prop u117 ( wadd138d, 1'b0, wcarry179g, wcarry179p );
smul_carry_eval u118 ( wcarry179g, wcarry179p, wcarry155, wcarry178 );
smul_full_add u119 ( wadd138c, wadd162d, wcarry178, wadd160d, wadd160c );
smul_booth_prod u120 ( 1'b0, x[0], x[1], y[11], y[12], wboothprod191 );
smul_booth_prod u121 ( x[1], x[2], x[3], y[9], y[10], wboothprod192 );
smul_booth_prod u122 ( x[3], x[4], x[5], y[7], y[8], wboothprod193 );
smul_full_add u123 ( wboothprod191, wboothprod192, wboothprod193, wadd189d, wadd189c );
smul_full_add u124 ( wadd168c, wadd173c, wadd189d, wadd187d, wadd187c );
smul_booth_prod u125 ( x[5], x[6], x[7], y[5], y[6], wboothprod198 );
smul_booth_prod u126 ( x[7], x[8], x[9], y[3], y[4], wboothprod199 );
smul_booth_prod u127 ( x[9], x[10], x[11], y[1], y[2], wboothprod200 );
smul_full_add u128 ( wboothprod198, wboothprod199, wboothprod200, wadd196d, wadd196c );
smul_booth_prod u129 ( x[11], x[12], x[13], 1'b0, y[0], wboothprod201 );
smul_booth_neg u130 ( x[11], x[12], x[13], wboothneg202 );
smul_full_add u131 ( wadd196d, wboothprod201, wboothneg202, wadd194d, wadd194c );
smul_full_add u132 ( wadd166c, wadd187d, wadd194d, wadd185d, wadd185c );
smul_half_add u133 ( wadd164c, wadd185d, wadd183d, wadd183c );
smul_carry_prop u134 ( wadd138c, wadd162d, wcarry208g, wcarry208p );
smul_carry_merge u135 ( wcarry179g, wcarry179p, wcarry208g, wcarry208p, wcarry206g, wcarry206p );
smul_carry_merge u136 ( wcarry156g, wcarry156p, wcarry206g, wcarry206p, wcarry204g, wcarry204p );
smul_carry_eval u137 ( wcarry204g, wcarry204p, wcarry109, wcarry203 );
smul_full_add u138 ( wadd162c, wadd183d, wcarry203, wadd181d, wadd181c );
smul_booth_prod u139 ( 1'b0, x[0], x[1], y[12], y[13], wboothprod220 );
smul_booth_prod u140 ( x[1], x[2], x[3], y[10], y[11], wboothprod221 );
smul_booth_prod u141 ( x[3], x[4], x[5], y[8], y[9], wboothprod222 );
smul_full_add u142 ( wboothprod220, wboothprod221, wboothprod222, wadd218d, wadd218c );
smul_full_add u143 ( wadd189c, wadd196c, wadd218d, wadd216d, wadd216c );
smul_full_add u144 ( wadd187c, wadd194c, wadd216d, wadd214d, wadd214c );
smul_booth_prod u145 ( x[5], x[6], x[7], y[6], y[7], wboothprod227 );
smul_booth_prod u146 ( x[7], x[8], x[9], y[4], y[5], wboothprod228 );
smul_booth_prod u147 ( x[9], x[10], x[11], y[2], y[3], wboothprod229 );
smul_full_add u148 ( wboothprod227, wboothprod228, wboothprod229, wadd225d, wadd225c );
smul_booth_prod u149 ( x[11], x[12], x[13], y[0], y[1], wboothprod230 );
smul_half_add u150 ( wadd225d, wboothprod230, wadd223d, wadd223c );
smul_full_add u151 ( wadd185c, wadd214d, wadd223d, wadd212d, wadd212c );
smul_carry_prop u152 ( wadd162c, wadd183d, wcarry232g, wcarry232p );
smul_carry_eval u153 ( wcarry232g, wcarry232p, wcarry203, wcarry231 );
smul_full_add u154 ( wadd183c, wadd212d, wcarry231, wadd210d, wadd210c );
smul_booth_prod u155 ( 1'b0, x[0], x[1], y[13], y[14], wboothprod244 );
smul_booth_prod u156 ( x[1], x[2], x[3], y[11], y[12], wboothprod245 );
smul_booth_prod u157 ( x[3], x[4], x[5], y[9], y[10], wboothprod246 );
smul_full_add u158 ( wboothprod244, wboothprod245, wboothprod246, wadd242d, wadd242c );
smul_full_add u159 ( wadd218c, wadd225c, wadd242d, wadd240d, wadd240c );
smul_booth_prod u160 ( x[5], x[6], x[7], y[7], y[8], wboothprod251 );
smul_booth_prod u161 ( x[7], x[8], x[9], y[5], y[6], wboothprod252 );
smul_booth_prod u162 ( x[9], x[10], x[11], y[3], y[4], wboothprod253 );
smul_full_add u163 ( wboothprod251, wboothprod252, wboothprod253, wadd249d, wadd249c );
smul_booth_prod u164 ( x[11], x[12], x[13], y[1], y[2], wboothprod256 );
smul_booth_prod u165 ( x[13], x[14], x[15], 1'b0, y[0], wboothprod257 );
smul_booth_neg u166 ( x[13], x[14], x[15], wboothneg258 );
smul_full_add u167 ( wboothprod256, wboothprod257, wboothneg258, wadd254d, wadd254c );
smul_half_add u168 ( wadd249d, wadd254d, wadd247d, wadd247c );
smul_full_add u169 ( wadd216c, wadd240d, wadd247d, wadd238d, wadd238c );
smul_full_add u170 ( wadd214c, wadd223c, wadd238d, wadd236d, wadd236c );
smul_carry_prop u171 ( wadd183c, wadd212d, wcarry262g, wcarry262p );
smul_carry_merge u172 ( wcarry232g, wcarry232p, wcarry262g, wcarry262p, wcarry260g, wcarry260p );
smul_carry_eval u173 ( wcarry260g, wcarry260p, wcarry203, wcarry259 );
smul_full_add u174 ( wadd212c, wadd236d, wcarry259, wadd234d, wadd234c );
smul_full_add u175 ( wadd242c, wadd249c, wadd254c, wadd270d, wadd270c );
smul_full_add u176 ( wadd240c, wadd247c, wadd270d, wadd268d, wadd268c );
smul_booth_prod u177 ( 1'b0, x[0], x[1], y[14], y[15], wboothprod276 );
smul_booth_prod u178 ( x[1], x[2], x[3], y[12], y[13], wboothprod277 );
smul_booth_prod u179 ( x[3], x[4], x[5], y[10], y[11], wboothprod278 );
smul_full_add u180 ( wboothprod276, wboothprod277, wboothprod278, wadd274d, wadd274c );
smul_booth_prod u181 ( x[5], x[6], x[7], y[8], y[9], wboothprod281 );
smul_booth_prod u182 ( x[7], x[8], x[9], y[6], y[7], wboothprod282 );
smul_booth_prod u183 ( x[9], x[10], x[11], y[4], y[5], wboothprod283 );
smul_full_add u184 ( wboothprod281, wboothprod282, wboothprod283, wadd279d, wadd279c );
smul_booth_prod u185 ( x[11], x[12], x[13], y[2], y[3], wboothprod286 );
smul_booth_prod u186 ( x[13], x[14], x[15], y[0], y[1], wboothprod287 );
smul_half_add u187 ( wboothprod286, wboothprod287, wadd284d, wadd284c );
smul_full_add u188 ( wadd274d, wadd279d, wadd284d, wadd272d, wadd272c );
smul_full_add u189 ( wadd238c, wadd268d, wadd272d, wadd266d, wadd266c );
smul_carry_prop u190 ( wadd212c, wadd236d, wcarry289g, wcarry289p );
smul_carry_eval u191 ( wcarry289g, wcarry289p, wcarry259, wcarry288 );
smul_full_add u192 ( wadd236c, wadd266d, wcarry288, wadd264d, wadd264c );
smul_full_add u193 ( wadd274c, wadd279c, wadd284c, wadd297d, wadd297c );
smul_full_add u194 ( wadd270c, wadd272c, wadd297d, wadd295d, wadd295c );
smul_booth_prod u195 ( 1'b0, x[0], x[1], y[15], y[15], wboothprod303 );
smul_booth_prod u196 ( x[1], x[2], x[3], y[13], y[14], wboothprod304 );
smul_booth_prod u197 ( x[3], x[4], x[5], y[11], y[12], wboothprod305 );
smul_full_add u198 ( wboothprod303, wboothprod304, wboothprod305, wadd301d, wadd301c );
smul_booth_prod u199 ( x[5], x[6], x[7], y[9], y[10], wboothprod308 );
smul_booth_prod u200 ( x[7], x[8], x[9], y[7], y[8], wboothprod309 );
smul_booth_prod u201 ( x[9], x[10], x[11], y[5], y[6], wboothprod310 );
smul_full_add u202 ( wboothprod308, wboothprod309, wboothprod310, wadd306d, wadd306c );
smul_booth_prod u203 ( x[11], x[12], x[13], y[3], y[4], wboothprod313 );
smul_booth_prod u204 ( x[13], x[14], x[15], y[1], y[2], wboothprod314 );
smul_half_add u205 ( wboothprod313, wboothprod314, wadd311d, wadd311c );
smul_full_add u206 ( wadd301d, wadd306d, wadd311d, wadd299d, wadd299c );
smul_full_add u207 ( wadd268c, wadd295d, wadd299d, wadd293d, wadd293c );
smul_carry_prop u208 ( wadd236c, wadd266d, wcarry324g, wcarry324p );
smul_carry_merge u209 ( wcarry289g, wcarry289p, wcarry324g, wcarry324p, wcarry322g, wcarry322p );
smul_carry_merge u210 ( wcarry260g, wcarry260p, wcarry322g, wcarry322p, wcarry320g, wcarry320p );
smul_carry_merge u211 ( wcarry204g, wcarry204p, wcarry320g, wcarry320p, wcarry318g, wcarry318p );
smul_carry_merge u212 ( wcarry110g, wcarry110p, wcarry318g, wcarry318p, wcarry316g, wcarry316p );
smul_carry_eval u213 ( wcarry316g, wcarry316p, 1'b0, wcarry315 );
smul_full_add u214 ( wadd266c, wadd293d, wcarry315, wadd291d, wadd291c );
smul_full_add u215 ( wadd301c, wadd306c, wadd311c, wadd332d, wadd332c );
smul_full_add u216 ( wadd297c, wadd299c, wadd332d, wadd330d, wadd330c );
smul_booth_prod u217 ( x[1], x[2], x[3], y[14], y[15], wboothprod338 );
smul_booth_prod u218 ( x[3], x[4], x[5], y[12], y[13], wboothprod339 );
smul_full_add u219 ( wboothprod303, wboothprod338, wboothprod339, wadd336d, wadd336c );
smul_booth_prod u220 ( x[5], x[6], x[7], y[10], y[11], wboothprod342 );
smul_booth_prod u221 ( x[7], x[8], x[9], y[8], y[9], wboothprod343 );
smul_booth_prod u222 ( x[9], x[10], x[11], y[6], y[7], wboothprod344 );
smul_full_add u223 ( wboothprod342, wboothprod343, wboothprod344, wadd340d, wadd340c );
smul_booth_prod u224 ( x[11], x[12], x[13], y[4], y[5], wboothprod347 );
smul_booth_prod u225 ( x[13], x[14], x[15], y[2], y[3], wboothprod348 );
smul_half_add u226 ( wboothprod347, wboothprod348, wadd345d, wadd345c );
smul_full_add u227 ( wadd336d, wadd340d, wadd345d, wadd334d, wadd334c );
smul_full_add u228 ( wadd295c, wadd330d, wadd334d, wadd328d, wadd328c );
smul_carry_prop u229 ( wadd266c, wadd293d, wcarry350g, wcarry350p );
smul_carry_eval u230 ( wcarry350g, wcarry350p, wcarry315, wcarry349 );
smul_full_add u231 ( wadd293c, wadd328d, wcarry349, wadd326d, wadd326c );
smul_full_add u232 ( wadd336c, wadd340c, wadd345c, wadd358d, wadd358c );
smul_full_add u233 ( wadd332c, wadd334c, wadd358d, wadd356d, wadd356c );
smul_inverter u234 ( wboothprod303, winv364 );
smul_booth_prod u235 ( x[1], x[2], x[3], y[15], y[15], wboothprod366 );
smul_inverter u236 ( wboothprod366, winv365 );
smul_booth_prod u237 ( x[3], x[4], x[5], y[13], y[14], wboothprod367 );
smul_full_add u238 ( winv364, winv365, wboothprod367, wadd362d, wadd362c );
smul_booth_prod u239 ( x[5], x[6], x[7], y[11], y[12], wboothprod370 );
smul_booth_prod u240 ( x[7], x[8], x[9], y[9], y[10], wboothprod371 );
smul_booth_prod u241 ( x[9], x[10], x[11], y[7], y[8], wboothprod372 );
smul_full_add u242 ( wboothprod370, wboothprod371, wboothprod372, wadd368d, wadd368c );
smul_booth_prod u243 ( x[11], x[12], x[13], y[5], y[6], wboothprod375 );
smul_booth_prod u244 ( x[13], x[14], x[15], y[3], y[4], wboothprod376 );
smul_half_add u245 ( wboothprod375, wboothprod376, wadd373d, wadd373c );
smul_full_add u246 ( wadd362d, wadd368d, wadd373d, wadd360d, wadd360c );
smul_full_add u247 ( wadd330c, wadd356d, wadd360d, wadd354d, wadd354c );
smul_carry_prop u248 ( wadd293c, wadd328d, wcarry380g, wcarry380p );
smul_carry_merge u249 ( wcarry350g, wcarry350p, wcarry380g, wcarry380p, wcarry378g, wcarry378p );
smul_carry_eval u250 ( wcarry378g, wcarry378p, wcarry315, wcarry377 );
smul_full_add u251 ( wadd328c, wadd354d, wcarry377, wadd352d, wadd352c );
smul_full_add u252 ( wadd362c, wadd368c, wadd373c, wadd388d, wadd388c );
smul_full_add u253 ( wadd358c, wadd360c, wadd388d, wadd386d, wadd386c );
smul_booth_prod u254 ( x[3], x[4], x[5], y[14], y[15], wboothprod394 );
smul_booth_prod u255 ( x[5], x[6], x[7], y[12], y[13], wboothprod395 );
smul_full_add u256 ( 1'b1, wboothprod394, wboothprod395, wadd392d, wadd392c );
smul_booth_prod u257 ( x[7], x[8], x[9], y[10], y[11], wboothprod398 );
smul_booth_prod u258 ( x[9], x[10], x[11], y[8], y[9], wboothprod399 );
smul_booth_prod u259 ( x[11], x[12], x[13], y[6], y[7], wboothprod400 );
smul_full_add u260 ( wboothprod398, wboothprod399, wboothprod400, wadd396d, wadd396c );
smul_booth_prod u261 ( x[13], x[14], x[15], y[4], y[5], wboothprod401 );
smul_full_add u262 ( wadd392d, wadd396d, wboothprod401, wadd390d, wadd390c );
smul_full_add u263 ( wadd356c, wadd386d, wadd390d, wadd384d, wadd384c );
smul_carry_prop u264 ( wadd328c, wadd354d, wcarry403g, wcarry403p );
smul_carry_eval u265 ( wcarry403g, wcarry403p, wcarry377, wcarry402 );
smul_full_add u266 ( wadd354c, wadd384d, wcarry402, wadd382d, wadd382c );
smul_booth_prod u267 ( x[3], x[4], x[5], y[15], y[15], wboothprod416 );
smul_inverter u268 ( wboothprod416, winv415 );
smul_booth_prod u269 ( x[5], x[6], x[7], y[13], y[14], wboothprod417 );
smul_booth_prod u270 ( x[7], x[8], x[9], y[11], y[12], wboothprod418 );
smul_full_add u271 ( winv415, wboothprod417, wboothprod418, wadd413d, wadd413c );
smul_full_add u272 ( wadd392c, wadd396c, wadd413d, wadd411d, wadd411c );
smul_full_add u273 ( wadd388c, wadd390c, wadd411d, wadd409d, wadd409c );
smul_booth_prod u274 ( x[9], x[10], x[11], y[9], y[10], wboothprod421 );
smul_booth_prod u275 ( x[11], x[12], x[13], y[7], y[8], wboothprod422 );
smul_booth_prod u276 ( x[13], x[14], x[15], y[5], y[6], wboothprod423 );
smul_full_add u277 ( wboothprod421, wboothprod422, wboothprod423, wadd419d, wadd419c );
smul_full_add u278 ( wadd386c, wadd409d, wadd419d, wadd407d, wadd407c );
smul_carry_prop u279 ( wadd354c, wadd384d, wcarry429g, wcarry429p );
smul_carry_merge u280 ( wcarry403g, wcarry403p, wcarry429g, wcarry429p, wcarry427g, wcarry427p );
smul_carry_merge u281 ( wcarry378g, wcarry378p, wcarry427g, wcarry427p, wcarry425g, wcarry425p );
smul_carry_eval u282 ( wcarry425g, wcarry425p, wcarry315, wcarry424 );
smul_full_add u283 ( wadd384c, wadd407d, wcarry424, wadd405d, wadd405c );
smul_booth_prod u284 ( x[5], x[6], x[7], y[14], y[15], wboothprod441 );
smul_booth_prod u285 ( x[7], x[8], x[9], y[12], y[13], wboothprod442 );
smul_full_add u286 ( 1'b1, wboothprod441, wboothprod442, wadd439d, wadd439c );
smul_full_add u287 ( wadd413c, wadd419c, wadd439d, wadd437d, wadd437c );
smul_booth_prod u288 ( x[9], x[10], x[11], y[10], y[11], wboothprod445 );
smul_booth_prod u289 ( x[11], x[12], x[13], y[8], y[9], wboothprod446 );
smul_booth_prod u290 ( x[13], x[14], x[15], y[6], y[7], wboothprod447 );
smul_full_add u291 ( wboothprod445, wboothprod446, wboothprod447, wadd443d, wadd443c );
smul_full_add u292 ( wadd411c, wadd437d, wadd443d, wadd435d, wadd435c );
smul_half_add u293 ( wadd409c, wadd435d, wadd433d, wadd433c );
smul_carry_prop u294 ( wadd384c, wadd407d, wcarry449g, wcarry449p );
smul_carry_eval u295 ( wcarry449g, wcarry449p, wcarry424, wcarry448 );
smul_full_add u296 ( wadd407c, wadd433d, wcarry448, wadd431d, wadd431c );
smul_booth_prod u297 ( x[5], x[6], x[7], y[15], y[15], wboothprod462 );
smul_inverter u298 ( wboothprod462, winv461 );
smul_booth_prod u299 ( x[7], x[8], x[9], y[13], y[14], wboothprod463 );
smul_booth_prod u300 ( x[9], x[10], x[11], y[11], y[12], wboothprod464 );
smul_full_add u301 ( winv461, wboothprod463, wboothprod464, wadd459d, wadd459c );
smul_full_add u302 ( wadd439c, wadd443c, wadd459d, wadd457d, wadd457c );
smul_booth_prod u303 ( x[11], x[12], x[13], y[9], y[10], wboothprod467 );
smul_booth_prod u304 ( x[13], x[14], x[15], y[7], y[8], wboothprod468 );
smul_half_add u305 ( wboothprod467, wboothprod468, wadd465d, wadd465c );
smul_full_add u306 ( wadd437c, wadd457d, wadd465d, wadd455d, wadd455c );
smul_half_add u307 ( wadd435c, wadd455d, wadd453d, wadd453c );
smul_carry_prop u308 ( wadd407c, wadd433d, wcarry472g, wcarry472p );
smul_carry_merge u309 ( wcarry449g, wcarry449p, wcarry472g, wcarry472p, wcarry470g, wcarry470p );
smul_carry_eval u310 ( wcarry470g, wcarry470p, wcarry424, wcarry469 );
smul_full_add u311 ( wadd433c, wadd453d, wcarry469, wadd451d, wadd451c );
smul_booth_prod u312 ( x[7], x[8], x[9], y[14], y[15], wboothprod484 );
smul_booth_prod u313 ( x[9], x[10], x[11], y[12], y[13], wboothprod485 );
smul_full_add u314 ( 1'b1, wboothprod484, wboothprod485, wadd482d, wadd482c );
smul_booth_prod u315 ( x[11], x[12], x[13], y[10], y[11], wboothprod488 );
smul_booth_prod u316 ( x[13], x[14], x[15], y[8], y[9], wboothprod489 );
smul_half_add u317 ( wboothprod488, wboothprod489, wadd486d, wadd486c );
smul_full_add u318 ( wadd459c, wadd482d, wadd486d, wadd480d, wadd480c );
smul_full_add u319 ( wadd457c, wadd465c, wadd480d, wadd478d, wadd478c );
smul_half_add u320 ( wadd455c, wadd478d, wadd476d, wadd476c );
smul_carry_prop u321 ( wadd433c, wadd453d, wcarry491g, wcarry491p );
smul_carry_eval u322 ( wcarry491g, wcarry491p, wcarry469, wcarry490 );
smul_full_add u323 ( wadd453c, wadd476d, wcarry490, wadd474d, wadd474c );
smul_booth_prod u324 ( x[7], x[8], x[9], y[15], y[15], wboothprod504 );
smul_inverter u325 ( wboothprod504, winv503 );
smul_booth_prod u326 ( x[9], x[10], x[11], y[13], y[14], wboothprod505 );
smul_booth_prod u327 ( x[11], x[12], x[13], y[11], y[12], wboothprod506 );
smul_full_add u328 ( winv503, wboothprod505, wboothprod506, wadd501d, wadd501c );
smul_full_add u329 ( wadd482c, wadd486c, wadd501d, wadd499d, wadd499c );
smul_booth_prod u330 ( x[13], x[14], x[15], y[9], y[10], wboothprod507 );
smul_full_add u331 ( wadd480c, wadd499d, wboothprod507, wadd497d, wadd497c );
smul_half_add u332 ( wadd478c, wadd497d, wadd495d, wadd495c );
smul_carry_prop u333 ( wadd453c, wadd476d, wcarry515g, wcarry515p );
smul_carry_merge u334 ( wcarry491g, wcarry491p, wcarry515g, wcarry515p, wcarry513g, wcarry513p );
smul_carry_merge u335 ( wcarry470g, wcarry470p, wcarry513g, wcarry513p, wcarry511g, wcarry511p );
smul_carry_merge u336 ( wcarry425g, wcarry425p, wcarry511g, wcarry511p, wcarry509g, wcarry509p );
smul_carry_eval u337 ( wcarry509g, wcarry509p, wcarry315, wcarry508 );
smul_full_add u338 ( wadd476c, wadd495d, wcarry508, wadd493d, wadd493c );
smul_booth_prod u339 ( x[9], x[10], x[11], y[14], y[15], wboothprod525 );
smul_booth_prod u340 ( x[11], x[12], x[13], y[12], y[13], wboothprod526 );
smul_full_add u341 ( 1'b1, wboothprod525, wboothprod526, wadd523d, wadd523c );
smul_booth_prod u342 ( x[13], x[14], x[15], y[10], y[11], wboothprod527 );
smul_full_add u343 ( wadd501c, wadd523d, wboothprod527, wadd521d, wadd521c );
smul_full_add u344 ( wadd497c, wadd499c, wadd521d, wadd519d, wadd519c );
smul_carry_prop u345 ( wadd476c, wadd495d, wcarry529g, wcarry529p );
smul_carry_eval u346 ( wcarry529g, wcarry529p, wcarry508, wcarry528 );
smul_full_add u347 ( wadd495c, wadd519d, wcarry528, wadd517d, wadd517c );
smul_booth_prod u348 ( x[9], x[10], x[11], y[15], y[15], wboothprod538 );
smul_inverter u349 ( wboothprod538, winv537 );
smul_booth_prod u350 ( x[11], x[12], x[13], y[13], y[14], wboothprod539 );
smul_booth_prod u351 ( x[13], x[14], x[15], y[11], y[12], wboothprod540 );
smul_full_add u352 ( winv537, wboothprod539, wboothprod540, wadd535d, wadd535c );
smul_full_add u353 ( wadd521c, wadd523c, wadd535d, wadd533d, wadd533c );
smul_carry_prop u354 ( wadd495c, wadd519d, wcarry544g, wcarry544p );
smul_carry_merge u355 ( wcarry529g, wcarry529p, wcarry544g, wcarry544p, wcarry542g, wcarry542p );
smul_carry_eval u356 ( wcarry542g, wcarry542p, wcarry508, wcarry541 );
smul_full_add u357 ( wadd519c, wadd533d, wcarry541, wadd531d, wadd531c );
smul_booth_prod u358 ( x[11], x[12], x[13], y[14], y[15], wboothprod552 );
smul_booth_prod u359 ( x[13], x[14], x[15], y[12], y[13], wboothprod553 );
smul_full_add u360 ( 1'b1, wboothprod552, wboothprod553, wadd550d, wadd550c );
smul_full_add u361 ( wadd533c, wadd535c, wadd550d, wadd548d, wadd548c );
smul_carry_prop u362 ( wadd519c, wadd533d, wcarry555g, wcarry555p );
smul_carry_eval u363 ( wcarry555g, wcarry555p, wcarry541, wcarry554 );
smul_full_add u364 ( wadd548d, 1'b0, wcarry554, wadd546d, wadd546c );
smul_booth_prod u365 ( x[11], x[12], x[13], y[15], y[15], wboothprod562 );
smul_inverter u366 ( wboothprod562, winv561 );
smul_booth_prod u367 ( x[13], x[14], x[15], y[13], y[14], wboothprod563 );
smul_full_add u368 ( wadd550c, winv561, wboothprod563, wadd559d, wadd559c );
smul_carry_prop u369 ( wadd548d, 1'b0, wcarry569g, wcarry569p );
smul_carry_merge u370 ( wcarry555g, wcarry555p, wcarry569g, wcarry569p, wcarry567g, wcarry567p );
smul_carry_merge u371 ( wcarry542g, wcarry542p, wcarry567g, wcarry567p, wcarry565g, wcarry565p );
smul_carry_eval u372 ( wcarry565g, wcarry565p, wcarry508, wcarry564 );
smul_full_add u373 ( wadd548c, wadd559d, wcarry564, wadd557d, wadd557c );
smul_booth_prod u374 ( x[13], x[14], x[15], y[14], y[15], wboothprod575 );
smul_full_add u375 ( wadd559c, 1'b1, wboothprod575, wadd573d, wadd573c );
smul_carry_prop u376 ( wadd548c, wadd559d, wcarry577g, wcarry577p );
smul_carry_eval u377 ( wcarry577g, wcarry577p, wcarry564, wcarry576 );
smul_full_add u378 ( wadd573d, 1'b0, wcarry576, wadd571d, wadd571c );
smul_booth_prod u379 ( x[13], x[14], x[15], y[15], y[15], wboothprod582 );
smul_inverter u380 ( wboothprod582, winv581 );
smul_carry_prop u381 ( wadd573d, 1'b0, wcarry586g, wcarry586p );
smul_carry_merge u382 ( wcarry577g, wcarry577p, wcarry586g, wcarry586p, wcarry584g, wcarry584p );
smul_carry_eval u383 ( wcarry584g, wcarry584p, wcarry564, wcarry583 );
smul_full_add u384 ( wadd573c, winv581, wcarry583, wadd579d, wadd579c );
smul_carry_prop u385 ( wadd573c, winv581, wcarry591g, wcarry591p );
smul_carry_eval u386 ( wcarry591g, wcarry591p, wcarry583, wcarry590 );
smul_full_add u387 ( 1'b1, 1'b0, wcarry590, wadd588d, wadd588c );

assign p[0] = wadd0d;
assign p[1] = wadd4d;
assign p[2] = wadd10d;
assign p[3] = wadd22d;
assign p[4] = wadd31d;
assign p[5] = wadd48d;
assign p[6] = wadd60d;
assign p[7] = wadd78d;
assign p[8] = wadd93d;
assign p[9] = wadd118d;
assign p[10] = wadd136d;
assign p[11] = wadd160d;
assign p[12] = wadd181d;
assign p[13] = wadd210d;
assign p[14] = wadd234d;
assign p[15] = wadd264d;
assign p[16] = wadd291d;
assign p[17] = wadd326d;
assign p[18] = wadd352d;
assign p[19] = wadd382d;
assign p[20] = wadd405d;
assign p[21] = wadd431d;
assign p[22] = wadd451d;
assign p[23] = wadd474d;
assign p[24] = wadd493d;
assign p[25] = wadd517d;
assign p[26] = wadd531d;
assign p[27] = wadd546d;
assign p[28] = wadd557d;
assign p[29] = wadd571d;
assign p[30] = wadd579d;
assign p[31] = wadd588d;

endmodule
