#include<stdio.h>
#include <math.h>
#include <stdlib.h> 


typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned long uint32_t;
typedef unsigned long long uint64_t;
#define MAX_NUM (1 << 16)

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

double rel_error(int x, int y, int w) {
	double prod_t, prod_a;
	prod_t = (double)x*y;
	prod_a = (double)ELM(x, y, w);	
	if(x==0 || y==0) return 0;
	return fabs(prod_t - prod_a)/fabs(prod_t)*100.0;
}	

void PRE(double RE, uint32_t *count){
	// Calculates that probabilities are smaller than X
	// In this function we analyze probabilites that 
	// RE is smaller than 2, 5, 10, 15, 20, 25 %
	*count += (RE < 2);
	*(count+1) += (RE < 5);
	*(count+2) += (RE < 10);
	*(count+3) += (RE < 15);
	*(count+4) += (RE < 20);
	*(count+5) += (RE < 25);
	*(count+6) += (RE < 11);

}


void PRE11(double RE, uint32_t count){
	// Calculates that probabilities are smaller than X
	// In this function we analyze probabilites that 
	// RE is smaller than 2, 5, 10, 15, 20, 25 %
	count += (RE < 11);
}


int main() {

	volatile int i, j, g,h,f;
	volatile char w[] = {1,3,4,5,6,7};
    volatile char q[] = {1,6,7} ;
	volatile uint32_t MAXRE_COUNT = 0;
	volatile double RE, MAXRE = 0, SUM_RE = 0;
	uint32_t count[] = { 0,0,0,0,0,0,0 };
    char perc[] = { 2,5,10,15,20,25,11 };
	FILE *log;
	char p;
	
	log = fopen("./log_MRE.txt", "a");
    if (log != NULL){
        char str1[80];
        sprintf(str1, "w q MRE MAXRE MAXRE_PROB 2 5 10 15 20 25 11\n");
        fputs(str1, log);    
        fclose(log);
    }
	// Iterator for qy
	for (h = 0; h < 1; h++){
		// init values with zeros
            SUM_RE = 0;
            int xx = 0;
            MAXRE_COUNT = 0;
            MAXRE = 0;
            for ( xx = 0; xx < 7; xx++) {
                count[xx] = 0;
            }
            // Calculating RE for pair in [0,MAX_NUM-1]x[0,MAX_NUM-1]
            for (i = -MAX_NUM/2; i < MAX_NUM/2-1; i++) {
                for (j = -MAX_NUM/2; j < MAX_NUM/2-1; j++) {
                    RE = rel_error(i, j,w[h]);
                    PRE(RE, count);
                    SUM_RE += RE;
                    MAXRE = MAXRE > RE ? MAXRE : RE;
                    MAXRE_COUNT = MAXRE > RE ? MAXRE_COUNT++ : 1;

                }
            }


            log = fopen("./log_MRE.txt", "a");

            if (log != NULL)
            {	
                
                char str0[] = "--------------------------------- \n \n";
                char str1[80];

                sprintf(str1, "%d %d ", w[h],q[g]);
                fputs(str1, log);

                sprintf(str1, " %2.4g ", (SUM_RE / (double)MAX_NUM)/(double)MAX_NUM);
                fputs(str1, log);

                sprintf(str1, " %2.4g ", MAXRE);
                fputs(str1, log);
                sprintf(str1, " %e ", ((double)MAXRE_COUNT/(double)MAX_NUM)/(double)MAX_NUM);
                fputs(str1, log);

                for (p = 0; p < 7; p++) {
                    sprintf(str1," %02.4g ", ((double)count[p]/ MAX_NUM)/MAX_NUM);
                    fputs(str1, log);
                }

				sprintf(str1, " \n ");
                fputs(str1, log);
                fclose(log);

            }
        
	}
		
	
	return 0;

}
