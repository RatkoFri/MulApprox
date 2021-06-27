#include <stdio.h>
#include <math.h>
#include <stdlib.h>

typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned long uint32_t;
typedef unsigned long long uint64_t;
#define MAX_NUM (1 << 16)
#define MAX_NUM1 (1 << 15)

int lut_4[] = {0,1,1,2,-2,-1,-1,0};
int lut_4a[] = {0,1,1,0,0,-1,-1,0};
int lut_4b[] = {0,0,-1,-1,0,0,-1,-1};
int sign[] = {0,0,0,0,1,1,1,1};



int R4ABM1( int x,  int y, int c) {
	int groups[] = {0,0,0,0,0,0,0,0};
	int pp[] = {0,0,0,0,0,0,0,0};
	int pp_a[] = {0,0,0,0,0,0,0,0};
	int mask[] = {0,0,0,0,0,0,0,0};

	int i,shift;
	int p = 0;
	 // c is number of columns, parameter p in RABM multiplier
	int tmp = 0;
	for(i=0;i<8;i++){ //16 bit multiplier have 8bit 
		mask[i] = (-1) <<(c-2*i);
		//printf("%x \n",mask[i]);
	} 

	pp[0] = y * lut_4[(x & 3) << 1];
	pp[1] = y * lut_4[(x & (7<<1)) >> 1];
	pp[2] = y * lut_4[(x & (7<<3)) >> 3];
	pp[3] = y * lut_4[(x & (7<<5)) >> 5];
	pp[4] = y * lut_4[(x & (7<<7)) >> 7];
	pp[5] = y * lut_4[(x & (7<<9)) >> 9];
	pp[6] = y * lut_4[(x & (7<<11)) >> 11];
	pp[7] = y * lut_4[(x & (7<<13)) >> 13];

	pp_a[0] = y * lut_4a[(x & 3) << 1];
	pp_a[1] = y * lut_4a[(x & (7<<1)) >> 1];
	pp_a[2] = y * lut_4a[(x & (7<<3)) >> 3];
	pp_a[3] = y * lut_4a[(x & (7<<5)) >> 5];
	pp_a[4] = y * lut_4a[(x & (7<<7)) >> 7];
	pp_a[5] = y * lut_4a[(x & (7<<9)) >> 9];
	pp_a[6] = y * lut_4a[(x & (7<<11)) >> 11];
	pp_a[7] = y * lut_4a[(x & (7<<13)) >> 13];

	for (i=0;i<8;i++){
		tmp = (pp[i] & mask[i]) |  (pp_a[i] & ~mask[i]);
		p +=   tmp << (2*i);
	}
	
	return p;
}


int R4ABM2( int x,  int y, int c) {
	int groups[] = {0,0,0,0,0,0,0,0};
	int pp[] = {0,0,0,0,0,0,0,0};
	int pp_a[] = {0,0,0,0,0,0,0,0};
	int mask[] = {0,0,0,0,0,0,0,0};

	int i,shift;
	int p = 0;
	 // c is number of columns, parameter p in RABM multiplier
	int tmp = 0;
	for(i=0;i<8;i++){ //16 bit multiplier have 8bit 
		mask[i] = (-1) <<(c-2*i);
		//printf("%x \n",mask[i]);
	} 

	pp[0] = y * lut_4[(x & 3) << 1];
	pp[1] = y * lut_4[(x & (7<<1)) >> 1];
	pp[2] = y * lut_4[(x & (7<<3)) >> 3];
	pp[3] = y * lut_4[(x & (7<<5)) >> 5];
	pp[4] = y * lut_4[(x & (7<<7)) >> 7];
	pp[5] = y * lut_4[(x & (7<<9)) >> 9];
	pp[6] = y * lut_4[(x & (7<<11)) >> 11];
	pp[7] = y * lut_4[(x & (7<<13)) >> 13];

	pp_a[0] = (y ^ lut_4b[(x & 3) << 1]) + sign[(x & 3) << 1];
	pp_a[1] = (y ^ lut_4b[(x & (7<<1)) >> 1]) + sign[(x & (7<<1)) >> 1];
	pp_a[2] = (y ^ lut_4b[(x & (7<<3)) >> 3]) + sign[(x & (7<<3)) >> 3];
	pp_a[3] = (y ^ lut_4b[(x & (7<<5)) >> 5]) + sign[(x & (7<<5)) >> 5];
	pp_a[4] = (y ^ lut_4b[(x & (7<<7)) >> 7]) + sign[(x & (7<<7)) >> 7];
	pp_a[5] = (y ^ lut_4b[(x & (7<<9)) >> 9]) + sign[(x & (7<<9)) >> 9];
	pp_a[6] = (y ^ lut_4b[(x & (7<<11)) >> 11]) + sign[(x & (7<<11)) >> 11];
	pp_a[7] = (y ^ lut_4b[(x & (7<<13)) >> 13]) + sign[(x & (7<<13)) >> 13];

	
	for (i=0;i<8;i++){
		tmp = (pp[i] & mask[i]) |  (pp_a[i] & ~mask[i]);
		p +=   tmp << (2*i);
	}
	
	return p;
}


int main() {
	int  x[] = {-7890,-789,6911,-26438,26438,-27820,-1685};
	int y[] = {-4251,-4,5884,0,26174,16233,-1262};
	int i,p;
	FILE *log;
	log = fopen("mult_log.txt", "w");
	for (i=0;i<7;i++){
		p = R4ABM2(x[i],y[i],14);
		printf("x =%d, y=%d, p=%d, exact=%d \n",x[i],y[i],p,x[i]*y[i]);
	}	
	fclose(log);
}