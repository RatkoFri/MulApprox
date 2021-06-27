#include<stdio.h>
#include <math.h>
#include <stdlib.h> 


typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned long uint32_t;
typedef unsigned long long uint64_t;
#define MAX_NUM (1 << 16)
#define MAX_NUM1 (1 << 15)

uint16_t leadingBitPosition(uint16_t val)
{	
	uint16_t clz;
	// clz function calculates number of leading zeros in integer number
	clz = __builtin_clz(val); 	
	return 31-clz;
}

int LM( int a,  int b, unsigned short w) {
    unsigned short n;
	n = 16;
	if(a == 0 || b == 0) return 0;
	char sgn_a = a > 0 ? 0 : 1;
	char sgn_b = b > 0 ? 0 : 1;
	unsigned int a_abs = sgn_a ? -(a)-1  : a;
	unsigned int b_abs = sgn_b ? -(b)-1 : b;

	// mux 
	unsigned int a_sel = a_abs;
	unsigned int b_sel = b_abs;

	unsigned int k_a, x_a;
	k_a = leadingBitPosition(a_sel);
	x_a = a_sel << (n - 1 - k_a);
    //printf("Xa = %x \n", x_a);
	unsigned int  k_b, x_b;
	k_b = leadingBitPosition(b_sel);
	x_b = b_sel << (n - 1 - k_b);
    //printf("Xb = %x \n", x_b);

    unsigned int tmp, tmp_prim;
    tmp = (1<<(n-1))-1;
    tmp_prim = ((1<<(n-1)) - (1<<(n-w)));

	unsigned int y_a, y_b, tmp_a, tmp_b;
	tmp_a = x_a & tmp;
	y_a = x_a & tmp_prim;
	y_a = y_a | (1 << (n-w-1));
    //printf("Ya = %x \n", y_a);

	tmp_b = x_b & tmp;
	y_b = x_b & tmp_prim;
	y_b = y_b | (1 << (n-w-1));

	//printf("Yb = %x \n", y_b);
	//char tresh = Q;

	// We truncate mantissa 
	unsigned int y_l;

	y_l = (y_a + y_b) & tmp;
	// We set the LSB of k_a and k_b to zero 

	unsigned int k_l;

	k_l = k_a + k_b + (((y_a + y_b) & (tmp+1)) >> (n - 1));

	double m;
	unsigned int p_abs;
	m = (double)y_l / (1 << 15);

	p_abs = (unsigned int)((1 + m)*(1 << k_l));

	int zero = (a == 0) || (b == 0)  ;
	int p;
	p = (sgn_a ^ sgn_b)? -p_abs-1 : p_abs; 
	p = p*(1-zero);
	return p;
}


int ELM(int x, int y, int w) {
	int sum = 0;
	int x0, x1, x0_signed, x0_abs;
	char sign;
	// X = X1*2^14 + X0
	// X1 = -2*x15+x14+x13
	// X0 = -x13*2^13 + sum_(i=0)^(12)(x_i*2^i)
	x1 = x >> 14;
 	x0 = x % (1 << 14);
	x0_signed = x0;
	if(x0 < -8192) x0_signed = x0 + 16384;
	if(x0 >  8192) x0_signed = x0 - 16384;
	// Caclulation of LSB 
	x0_abs = x0_signed;
	x1 += (x0_signed < 0);

	int y0, y1, y0_signed, y0_abs;
	// Y = Y1*2^14 + Y0
	// X1 = -2*y15+y14+y13
	// X0 = -y13*2^13 + sum_(i=0)^(12)(y_i*2^i)
	y1 = y >> 14;
 	y0 = y % (1 << 14);
	y0_signed = y0;
	if(y0 < -8192) y0_signed = y0 + 16384;
	if(y0 >  8192) y0_signed = y0 - 16384;
	// Caclulation of LSB 
	y0_abs = y0_signed;
	y1 += (y0_signed < 0);

	// Calculation of product 
	// PP_3 = X1*Y1

	// PP_2 = X1*Y0, PP_1 = Y1*X0

	int PP_1 = x1*y;
	if(PP_1 < 0){
		PP_1 = (PP_1 - 1) | 1; 
	}
	sum +=  PP_1 <<14;

	//int PP_0 = x0_signed*y0_signed;
	int PP_0 = LM(x0_signed,y,w);
	
	sum += PP_0;

	return sum;

}


double rel_dist(int x, int y, int w) {
	double prod_t, prod_a;
	prod_t = (double)x*y;
	prod_a = (double)ELM(x, y,w);	
	if(x==0 || y==0) return 0;
	return fabs(prod_t - prod_a);
}	


int main() {
	/*
		int x, y, qx, qy,d;
		x = -32577;
		y = 4149;
		qx = 7;
		qy = 8;
		d = 10;
		printf("Rel error = %f", rel_error(x, y, d,qx,qy));
		return 0;
	*/
	
	
	
	volatile int i, j, g,h,f;
	volatile char w[] = {0,4,5,6,7};
    volatile char q[] = {6,7,8} ;
	volatile uint32_t MAXRE_COUNT = 0;
	volatile double RE, MAXRE = 0, SUM_RE = 0,MED,SUM_ED,NMED,ED;
	uint32_t count[] = { 0,0,0,0,0,0 };
        char perc[] = { 2,5,10,15,20,25 };
	FILE *log;
	char p;
    log = fopen("./log_NMED.txt", "a");
    if (log != NULL){
        char str1[80];
        sprintf(str1, "w q NMED \n");
        fputs(str1, log);    
        fclose(log);
    }
	
    	// Iterator for qy
	for (h = 0; h < 1; h++){
        for (g = 0; g < 1;g++){
		// init values with zeros
            MED = 0;
            NMED = 0;
            SUM_ED = 0;
            // Calculating RE for pair in [0,MAX_NUM-1]x[0,MAX_NUM-1]
            for (i = -MAX_NUM/2; i < MAX_NUM/2-1; i++) {
                for (j = -MAX_NUM/2; j < MAX_NUM/2-1; j++) {
                    ED = rel_dist(i, j,w[h]);     
                    SUM_ED += ED;
                }
            }
		    MED = (SUM_ED / (double)MAX_NUM)/(double)MAX_NUM;
		    NMED = (MED / (double)MAX_NUM1)/(double)MAX_NUM1;

            log = fopen("./log_NMED.txt", "a");

            if (log != NULL)
            {	
                char str1[80];
                sprintf(str1, "%d %4.6g \n", w[h],NMED);
                fputs(str1, log);
                fclose(log);
            }
        }
	}
}

