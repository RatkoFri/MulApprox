

#include <vector>

#include "caffe/filler.hpp"
#include "caffe/layers/inner_product_layer_approx.hpp"
#include "caffe/util/math_functions.hpp"

#define P 8 

#define P 8
#define MAX 1<<(15-P)

namespace caffe{

__device__   int leadingBitPosition_fc(int val)
  {
    unsigned n = 0, x;
    x = val;
    if (x <= 0x0000ffff) n += 16, x <<= 16;
    if (x <= 0x00ffffff) n += 8, x <<= 8;
    if (x <= 0x0fffffff) n += 4, x <<= 4;
    if (x <= 0x3fffffff) n += 2, x <<= 2;
    if (x <= 0x7fffffff) n++;
    return 31 - n;
  }

__device__ int ROBA_fc(int x, int y){
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

	kx = leadingBitPosition_fc(x_abs);
	x_round = (x_abs >= 3*(1 << (kx-1))) ? 1 << (kx+1) : 1 << kx;
	x_round = (x_abs == 3) ? 3 : x_round;

	ky = leadingBitPosition_fc(y_abs);
	y_round = (y_abs >= 3*(1 << (ky-1))) ? 1 << (ky+1) : 1 << ky;
	y_round = (y_abs == 3) ? 2 : y_round;


	p_abs =  (x_round * y_abs) +  (y_round * x_abs) - (y_round * x_round);

	p = sgn_x ^ sgn_y ? -p_abs : p_abs;

	return p*zero;
	

}


template <typename Dtype>
__device__ Dtype mult_fixed_fc(const Dtype *a, const Dtype *b)
{
  int x, y;
  int z;
  // Cutting off in quantization
  x = (short)(*a * (1 << P));
  y = (short)(*b * (1 << P));
  x = *a >= MAX ? (1<<15)-1 : x;
  x = *a <= -MAX ? -(1<<15) : x;
  y = *b >= MAX ? (1<<15)-1 : y;
  y = *b <= -MAX ? -(1<<15) : y;
	z = ROBA(x,y); 
  return ((Dtype)z / (1 << 2 * P));
 //return *a * *b;
}

  template <typename Dtype>
__global__ void FCCForward(const int nthreads,
		const Dtype* bottom_data, const Dtype*  weight,
    Dtype* top_data, int M, int N, int K, const Dtype* bias,
    const int bias_term_, const Dtype* const bias_multiplier) {
	CUDA_KERNEL_LOOP(index, nthreads) {

		const int pw = index % N;
    const int ph = index / N;

    Dtype aveval = 0;
    
//		if (index==1) {
//			printf("pw%d ph%d c%d n%d \n",pw,ph,c,n);
//			printf("hstart%d wstart%d hend%d wend%d \n",hstart,wstart,hend,wend);
//		}


   
  
    for(int pk = 0; pk < K; pk++){

      // aveval += bottom_data[ph*K + pk]*weight[pk + pw*K];
      // aveval += mult_fixed((double)bottom_data[ph*K + pk],(double)weight[pk + pw*K]);
      aveval += mult_fixed_fc(bottom_data+ph*K + pk,weight + pk + pw*K);
    }

     // Bias multiplier needs to be checked, I have a bad feeling that  something isn't working like it should. Still, we managed to 
     // create inner product. At the end filter were in shape of N*K not K*N
		 if(bias_term_) {  
		 	aveval+=bias[pw]*bias_multiplier[ph];
	  }
		top_data[index] = aveval;
	}
}

  

template <typename Dtype>
void InnerProductApproxLayer<Dtype>::Forward_gpu(const vector<Blob<Dtype>*>& bottom,
    const vector<Blob<Dtype>*>& top) {
  const Dtype* bottom_data = bottom[0]->gpu_data();
  Dtype* top_data = top[0]->mutable_gpu_data();
  const Dtype* weight = this->blobs_[0]->gpu_data();
  const int count = top[0]->count();

  if (bias_term_) {
    const Dtype* const bias = this->blobs_[1]->gpu_data();
    FCCForward<Dtype><<<CAFFE_GET_BLOCKS(count), CAFFE_CUDA_NUM_THREADS>>>(
        count,bottom_data, weight, top_data, M_, N_, K_,bias,bias_term_,bias_multiplier_.gpu_data());
  } else {
    FCCForward<Dtype><<<CAFFE_GET_BLOCKS(count), CAFFE_CUDA_NUM_THREADS>>>(
        count,bottom_data, weight, top_data, M_, N_, K_,0,bias_term_,bias_multiplier_.gpu_data());
  }
  //  printf("Print %d \n", bottom.size());

  // for (int i = 0; i < bottom.size(); ++i) {
  //   const Dtype* bottom_data = bottom[i]->gpu_data();
	// 	Dtype* top_data = top[i]->mutable_gpu_data();
	// 	const int count = top[i]->count();
  //   if (bias_term_) {
  //       const Dtype* const bias = this->blobs_[1]->gpu_data();
  //       FCCForward<Dtype><<<CAFFE_GET_BLOCKS(count), CAFFE_CUDA_NUM_THREADS>>>(
  //           count,bottom_data, weight, top_data, M_, N_, K_,bias,bias_term_);
  //     } else {
  //       FCCForward<Dtype><<<CAFFE_GET_BLOCKS(count), CAFFE_CUDA_NUM_THREADS>>>(
  //           count,bottom_data, weight, top_data, M_, N_, K_,0,bias_term_);
  //     }
  // }


}

template <typename Dtype>
void InnerProductApproxLayer<Dtype>::Backward_gpu(const vector<Blob<Dtype>*>& top,
    const vector<bool>& propagate_down,
    const vector<Blob<Dtype>*>& bottom) {
  if (this->param_propagate_down_[0]) {
    const Dtype* top_diff = top[0]->gpu_diff();
    const Dtype* bottom_data = bottom[0]->gpu_data();
    // Gradient with respect to weight
    if (transpose_) {
      caffe_gpu_gemm<Dtype>(CblasTrans, CblasNoTrans,
          K_, N_, M_,
          (Dtype)1., bottom_data, top_diff,
          (Dtype)1., this->blobs_[0]->mutable_gpu_diff());
    } else {
      caffe_gpu_gemm<Dtype>(CblasTrans, CblasNoTrans,
          N_, K_, M_,
          (Dtype)1., top_diff, bottom_data,
          (Dtype)1., this->blobs_[0]->mutable_gpu_diff());
    }
  }
  if (bias_term_ && this->param_propagate_down_[1]) {
    const Dtype* top_diff = top[0]->gpu_diff();
    // Gradient with respect to bias
    caffe_gpu_gemv<Dtype>(CblasTrans, M_, N_, (Dtype)1., top_diff,
        bias_multiplier_.gpu_data(), (Dtype)1.,
        this->blobs_[1]->mutable_gpu_diff());
  }
  if (propagate_down[0]) {
    const Dtype* top_diff = top[0]->gpu_diff();
    // Gradient with respect to bottom data
    if (transpose_) {
      caffe_gpu_gemm<Dtype>(CblasNoTrans, CblasTrans,
          M_, K_, N_,
          (Dtype)1., top_diff, this->blobs_[0]->gpu_data(),
          (Dtype)0., bottom[0]->mutable_gpu_diff());
    } else {
      caffe_gpu_gemm<Dtype>(CblasNoTrans, CblasNoTrans,
          M_, K_, N_,
         (Dtype)1., top_diff, this->blobs_[0]->gpu_data(),
         (Dtype)0., bottom[0]->mutable_gpu_diff());
    }
  }
}

INSTANTIATE_LAYER_GPU_FUNCS(InnerProductApproxLayer);

}  // namespace caffe
