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
int lut_8[] = {0,1,1,2,2,3,3,4,-4,-3,-3,-2,-2,-1,-1,0};
int R8ABM1[] = {0,1,1,2,2,2,2,4,-4,-2,-2,-2,-2,-1,-1,0};
int R8ABM2[] = {0,1,1,2,2,2,4,4,-4,-4,-2,-2,-2,-1,-1,0};




int HLR_BM1( int x,  int y) {
	int groups[] = {0,0,0,0,0,0};
	int pp[] = {0,0,0,0,0,0,0};
	int i,shift;
	int p=0,x15,x14;

	//rad8
	pp[0] = y * R8ABM1[(x & 7) << 1];
	pp[1] = y * R8ABM1[(x & (15<<2)) >> 2];
	pp[2] = y * R8ABM1[(x & (15<<5)) >> 5];
	//rad4
	pp[3] = y * lut_4[(x & (7<<8)) >> 8];
	pp[4] = y * lut_4[(x & (7<<10)) >> 10];
	pp[5] = y * lut_4[(x & (7<<12)) >> 12];

	x15 = (x & (1<<15)) >> 15;
	x14 = (x & (1<<14)) >> 14;
	pp[6] = y * lut_4[(x15*6 | x14)];
	
	for (i=0;i<3;i++){
		p += pp[i] << (3*i);
	}

	for (i=3;i<7;i++){
		p += pp[i] << (2*i+3);
	}
	return p;
}

int HLR_BM2( int x,  int y) {
	int groups[] = {0,0,0,0,0,0};
	int pp[] = {0,0,0,0,0,0};
	int i,shift;
	int p=0,x15,x14;

	//rad8
	pp[0] = y * R8ABM2[(x & 7) << 1];
	pp[1] = y * R8ABM2[(x & (15<<2)) >> 2];
	pp[2] = y * lut8[(x & (15<<5)) >> 5];
	pp[3] = y * R8ABM2[(x & (15<<8)) >> 8];

	//rad4
	pp[4] = y * lut_4[(x & (7<<11)) >> 11];
	pp[5] = y * lut_4[(x & (7<<13)) >> 13];
	
	for (i=0;i<4;i++){
		p += pp[i] << (3*i);
	}

	for (i=4;i<6;i++){
		p += pp[i] << (2*i+4);
	}
	return p;
}



int main() {

	
	int  x[] = {-7890,-789,6911,-26438,26438,-27820,-1685};
	int y[] = {-4251,-4,5884,0,26174,16233,-1262};
	int i,j,p;
	float sum_ED = 0, MED, NMED;
	
	
	FILE *log;
	log = fopen("mult_log.txt", "w");
	for (i=0;i<7;i++){
		p = HLR_BM2(x[i],y[i]);
		printf("x =%d, y=%d, p=%d, exact=%d \n",x[i],y[i],p,x[i]*y[i]);
	}	
	fclose(log);

}
