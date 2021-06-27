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

int ROBA_conv(int x, int y){
	unsigned short x_abs, y_abs;
	int p;
	unsigned int p_abs;
	char sgn_x = x > 0 ? 0 : 1;
	char sgn_y = y > 0 ? 0 : 1;
	char kx, ky;
	x_abs = sgn_x ? -(x)  : x;
	y_abs = sgn_y ? -(y) : y;

	uint16_t x_round, y_round;
	char zero = x_abs != 0 & y_abs != 0; 

	kx = leadingBitPosition(x_abs);
	x_round = (x_abs >= 3*(1 << (kx-1))) ? 1 << (kx+1) : 1 << kx;
	x_round = (x_abs == 3) ? 3 : x_round;

	ky = leadingBitPosition(y_abs);
	y_round = (y_abs >= 3*(1 << (ky-1))) ? 1 << (ky+1) : 1 << ky;
	y_round = (y_abs == 3) ? 2 : y_round;


	p_abs =  (x_round * y_abs) +  (y_round * x_abs) - (y_round * x_round);

	p = sgn_x ^ sgn_y ? -p_abs : p_abs;

	return p*zero;
}

int main() {
	int  x[] = {-7890,-789,6911,-26438,26438,-27820,-1685};
	int y[] = {-4251,-4,5884,0,26174,16233,-1262};
	int i,p,w;
	w = 3;
	FILE *log;
	log = fopen("mult_log.txt", "w");
	for (i=0;i<7;i++){
		p = ROBA(x[i],y[i]);
		printf("x =%d, y=%d, p=%d, exact=%d \n",x[i],y[i],p,x[i]*y[i]);
	}	
	fclose(log);
}