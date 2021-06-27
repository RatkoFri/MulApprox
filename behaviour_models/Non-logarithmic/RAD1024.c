#include <stdio.h>
#include <math.h>
#include <stdlib.h>

typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned long uint32_t;
typedef unsigned long long uint64_t;
#define MAX_NUM (1 << 16)
#define MAX_NUM1 (1 << 15)

int RAD1024(int x, int y) {
    int sum = 0;
    int x0, x1, x0_signed, x0_abs, th1, th2, th3, th4, sum_lower;
    char sign;
  
    x1 = x >> 10;
    //printf("\n x1 = %d", x1);
    x0 = x % (1 << 10);
    x0_signed = x0;
  
    if (x0 < -512) x0_signed = x0 + 1024;
    if (x0 >  512) x0_signed = x0 - 1024;
    // Caclulation of LSB 
    x0_abs = x0_signed;
    x1 += (x0_signed < 0);
    sign = 1;
    if (x0_signed < 0) {
      x0_abs = -x0_signed;
      sign = -1;
    }
  
    th1 = 1 << 5;
    th2 = (1 << 5) + (1 << 6);
    th3 = (1 << 6) + (1 << 7);
    th4 = (1 << 7) + (1 << 8);
    sum_lower = 0;
    if (x0_abs >= th1 && x0_abs < th2) sum_lower = y << 6;
    if (x0_abs >= th2 && x0_abs < th3) sum_lower = y << 7;
    if (x0_abs >= th3 && x0_abs < th4) sum_lower = y << 8;
    if (x0_abs >= th4) sum_lower = y << 9;
  
  
    sum += (y * x1)*(1 << 10) + sign * sum_lower;
  
  
    //sum += ILMqs1(&x0, &y, qx, qy)*(x0 != 0 && y != 0 && x0 != -1 && y != -1);
    return sum;
  }


int main() {
	int  x[] = {-7890,-789,6911,-26438,26438,-27820,-1685};
	int y[] = {-4251,-4,5884,0,26174,16233,-1262};
	int i,p;
	FILE *log;
	log = fopen("mult_log.txt", "w");
	for (i=0;i<7;i++){
		p = RAD1024(x[i],y[i],14);
		printf("x =%d, y=%d, p=%d, exact=%d \n",x[i],y[i],p,x[i]*y[i]);
	}	
	fclose(log);
}