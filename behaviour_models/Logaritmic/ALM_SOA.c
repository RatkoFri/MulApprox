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

int ALM_SOA( int a,  int b, unsigned short w) {
  if(a == 0 | b == 0) return 0;
  unsigned short n;
	n = 16;
	char sgn_a = a > 0 ? 0 : 1;
	char sgn_b = b > 0 ? 0 : 1;
	unsigned int a_abs = sgn_a ? -(a)-1  : a;
	unsigned int b_abs = sgn_b ? -(b)-1 : b;

	unsigned int k_a, x_a;
	k_a = leadingBitPosition(a_abs);
	x_a = a_abs << (n - 1 - k_a);
    
	unsigned int  k_b, x_b;
	k_b = leadingBitPosition(b_abs);
	x_b = b_abs << (n - 1 - k_b);

    unsigned int tmp, tmp_prim, tmp_sec;
    tmp = (1<<(n-1))-1;
    tmp_prim = (1<<w)-1;
	tmp_sec = (1<<w-1);
	unsigned int y_a, y_b;
	y_a = x_a & tmp;

	y_b = x_b & tmp;
    
	// Truncation 
	unsigned int y_l,y_a_trunc, y_b_trunc;
	y_a_trunc = (tmp - tmp_prim) & y_a;
	y_b_trunc = (tmp - tmp_prim) & y_b;

    unsigned int carry_in =  ((y_a & y_b) & (tmp_sec))*2;
    y_l = (y_a_trunc + y_b_trunc + carry_in)|tmp_prim;
	unsigned int k_l;
	k_l = k_a + k_b + (((y_l) & (tmp+1)) >> (n - 1));
	y_l = y_l & tmp;

	double m;
	unsigned int p_abs;
	m = (double)y_l / (1 << 15);
	p_abs = (unsigned int)((1 + m)*(1 << k_l));
    int p;
    p = (sgn_a ^ sgn_b)? -p_abs-1 : p_abs; 
	return p;
}


int main() {
	int  x[] = {-7890,-789,6911,-26438,26438,-27820,-1685};
	int y[] = {-4251,-4,5884,0,26174,16233,-1262};
	int i,p,w;
	w = 3;
	FILE *log;
	log = fopen("mult_log.txt", "w");
	for (i=0;i<7;i++){
		p = ALM_SOA(x[i],y[i],w);
		printf("x =%d, y=%d, p=%d, exact=%d \n",x[i],y[i],p,x[i]*y[i]);
	}	
	fclose(log);
}