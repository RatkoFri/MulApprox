#include <stdio.h>
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

int TL( int a,  int b, unsigned short w, int Q) {
    unsigned short n;
	n = 16;
	if(a == 0 || b == 0) return 0;
	char sgn_a = a > 0 ? 0 : 1;
	char sgn_b = b > 0 ? 0 : 1;
	unsigned int a_abs = sgn_a ? -(a)-1  : a;
	unsigned int b_abs = sgn_b ? -(b)-1 : b;

	// select signals
	char upSegX = a_abs >=  (1<<Q);
	char upSegY = b_abs >=  (1<<Q);
	char Abit = 1 ;
	char Bbit = 1 ;

	// mux 
	unsigned int a_sel = upSegX ? (a_abs >> (Q-1)) | Abit : a_abs;
	unsigned int b_sel = upSegY ? (b_abs >> (Q-1)) | Bbit : b_abs;


    // ** ADAPT ** begin 
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
	m = (double)y_l / (1 << (n-1));

	p_abs = (unsigned int)((1 + m)*(1 << k_l));

	// ** ADAPT ** end

    // Shift the product 
	p_abs = upSegX ^ upSegY ? p_abs <<    Q-1 : p_abs;
	p_abs = upSegX & upSegY ? p_abs << 2*(Q-1) : p_abs;


	int zero = (a == 0) || (b == 0)  ;
	int p;
	p = (sgn_a ^ sgn_b)? -p_abs-1 : p_abs; 
	p = p*(1-zero);
	return p;
}


int main() {
	int  x[] = {-7890,-789,6911,-26438,26438,-27820,-1685};
	int y[] = {-4251,-4,5884,0,26174,16233,-1262};
	int i,p,w,Q;
	w = 4;
	Q = 8;
	FILE *log;
	log = fopen("mult_log.txt", "w");
	for (i=0;i<7;i++){
		p = TL(x[i],y[i],w,Q);
		printf("x =%d, y=%d, p=%d, exact=%d \n",x[i],y[i],p,x[i]*y[i]);
	}	
	fclose(log);
}