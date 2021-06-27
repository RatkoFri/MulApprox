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

int Booth_rad4( int x,  int y) {
	int groups[] = {0,0,0,0,0,0,0,0};
	int pp[] = {0,0,0,0,0,0,0,0};
	int i,shift;
	int p;

	groups[0] = (x & 3) << 1;
	pp[0] = y * lut_4[groups[0]];
	p = pp[0];
	for (i=1;i<8;i++){
		shift = (i-1)*2+1;
		groups[i] = (x & (7 << shift))>>shift;
		pp[i] = y * lut_4[groups[i]];
		p += pp[i] << (2*i);
	}
	
	return p;
}


int Booth_rad4a( int x,  int y) {
	int groups[] = {0,0,0,0,0,0,0,0};
	int pp[] = {0,0,0,0,0,0,0,0};
	int i,shift;
	int p = 0;

	pp[0] = y * lut_4[(x & 3) << 1];
	pp[1] = y * lut_4[(x & (7<<1)) >> 1];
	pp[2] = y * lut_4[(x & (7<<3)) >> 3];
	pp[3] = y * lut_4[(x & (7<<5)) >> 5];
	pp[4] = y * lut_4[(x & (7<<7)) >> 7];
	pp[5] = y * lut_4[(x & (7<<9)) >> 9];
	pp[6] = y * lut_4[(x & (7<<11)) >> 11];
	pp[7] = y * lut_4[(x & (7<<13)) >> 13];

	for (i=0;i<8;i++){
		p += pp[i] << (2*i);
	}
	
	return p;
}


int Booth_rad8( int x,  int y) {
	int groups[] = {0,0,0,0,0,0};
	int pp[] = {0,0,0,0,0,0};
	int i,shift;
	int p,x15,x14;

	groups[0] = (x & 7) << 1;
	pp[0] = y * lut_8[groups[0]];
	p = pp[0];
	for (i=1;i<5;i++){
		shift = (i-1)*3+2;
		groups[i] = (x & (15 << shift))>>shift;
		pp[i] = y * lut_8[groups[i]];
		p += pp[i] << (3*i);
	}
	x15 = (x & (1<<15)) >> 15;
	x14 = (x & (1<<14)) >> 14;
	groups[5] = x15*14 | x14;
	pp[5] = y * lut_8[groups[5]];
	p += pp[5] << (3*5);

	return p;
}


int Booth_rad8a( int x,  int y) {
	int groups[] = {0,0,0,0,0,0};
	int pp[] = {0,0,0,0,0,0};
	int i,shift;
	int p=0,x15,x14;

	pp[0] = y * lut_8[(x & 7) << 1];
	pp[1] = y * lut_8[(x & (15<<2)) >> 2];
	pp[2] = y * lut_8[(x & (15<<5)) >> 5];
	pp[3] = y * lut_8[(x & (15<<8)) >> 8];
	pp[4] = y * lut_8[(x & (15<<11)) >> 11];
	
	x15 = (x & (1<<15)) >> 15;
	x14 = (x & (1<<14)) >> 14;
	pp[5] = y * lut_8[(x15*14 | x14)];
	
	for (i=0;i<6;i++){
		p += pp[i] << (3*i);
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
		p = Booth_rad8a(x[i],y[i]);
		printf("x =%d, y=%d, p=%d, exact=%d \n",x[i],y[i],p,x[i]*y[i]);
	}	
	fclose(log);
}