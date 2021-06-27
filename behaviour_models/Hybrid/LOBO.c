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
	return 31 - clz;
}

// logarithmic product approximation 
int LPPG(int x, int y, char qx, char qy) {

  unsigned short x0_abs, y_abs;
  int  ilm_as, ilm_bs,x00;
  int ilm_s;
  char sgn_x = x >= 0 ? 0 : 1;
  char sgn_y = y >= 0 ? 0 : 1;
  //x0_abs = sgn_x ? -(x)  : x;
  //y_abs = sgn_y ? -(y) : y;
  x0_abs = sgn_x ? -x-1  : x;
  y_abs = sgn_y ? -y-1 : y;
  char k1_tmp = leadingBitPosition(x0_abs);
  char k2_tmp = leadingBitPosition(y_abs);
  unsigned int k1, sk2;
  // quantization
  k1 = k1_tmp >= qx ? k1_tmp : 0;
  sk2 = k2_tmp >= qy ? (1 << (k2_tmp- qy)) : 0;
  // substitution
  x00 = x0_abs - (1 << k1);

  // add these to the simulation
  ilm_bs = ((sgn_x ^ sgn_y) ? (-x00-1)*sk2 : x00*sk2)*((y != 0 ) && x0_abs != 0) ;
  ilm_as = ((sgn_x ^ sgn_y) ? (-y_abs-1)*(1 << k1) : y_abs * (1 << k1))*( x != 0 );


  ilm_s = (ilm_bs << qy) + (ilm_as);
  //printf(" ILM = %d,  ilm_bs = %d, ilm_as = %d \n", ilm_s, ilm_bs, ilm_as);
  //printf("  ILM_product: %d \t", ilm_s);

  return ilm_s;
}

int LOBO(int x, int y, char d, char qx, char qy) {
  if(x == 0 | y == 0) return 0;  
	int sum = 0;
	int x0, x1, x0_signed,sum_lower;
	x1 = x >> d;
	//printf("\n x1 = %d", x1);
 	x0 = x % (1 << d);
	x0_signed = x0;
	int sd = 1 << d;
	if(x0 < -sd/2) x0_signed = x0 + sd;
	if(x0 >  sd/2) x0_signed = x0 - sd;
	// Caclulation of LSB 
	x1 += (x0_signed < 0);

	sum_lower = LPPG(x0_signed,y,qx,qy);

	sum = (y * x1)*(1 << d) + sum_lower*(x0_signed != 0 && y != 0);

	return sum;
}

int main() {
	int  x[] = {-7890,-789,6911,-26438,26438,-27820,-1685};
	int y[] = {-4251,-4,5884,0,26174,16233,-1262};
	int i,p,qx, qy,d;
	qx = 7;
	qy = 8;
	d = 10;
	FILE *log;
	log = fopen("mult_log.txt", "w");
	for (i=0;i<7;i++){
		p = LOBO(x[i],y[i],d,qx,qy);
		printf("x =%d, y=%d, p=%d, exact=%d \n",x[i],y[i],p,x[i]*y[i]);
	}	
	fclose(log);
}