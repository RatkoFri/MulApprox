#include <vector>

#include "caffe/layers/conv_layer_approx.hpp"
//#include "caffe/util/approx_mult.hpp"




#define P 8 
#define MAX 1<<(15-P)

namespace caffe{

__device__   int leadingBitPosition_conv(int val)
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


__device__ int ROBA_conv(int x, int y){
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

	kx = leadingBitPosition_conv(x_abs);
	x_round = (x_abs >= 3*(1 << (kx-1))) ? 1 << (kx+1) : 1 << kx;
	x_round = (x_abs == 3) ? 3 : x_round;

	ky = leadingBitPosition_conv(y_abs);
	y_round = (y_abs >= 3*(1 << (ky-1))) ? 1 << (ky+1) : 1 << ky;
	y_round = (y_abs == 3) ? 2 : y_round;


	p_abs =  (x_round * y_abs) +  (y_round * x_abs) - (y_round * x_round);

	p = sgn_x ^ sgn_y ? -p_abs : p_abs;

	return p*zero;
	

}


template <typename Dtype>
__device__ Dtype mult_fixed_conv(const Dtype *a, const Dtype *b)
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
  z = ROBA_conv(x,y); 
  return ((Dtype)z / (1 << 2 * P));
 //return *a * *b;
}


  template <typename Dtype>
__global__ void ConvForward(const int nthreads,
		const Dtype* const bottom_data, const int num, const int channels,
		const int height, const int width,const int conved_height,
		const int conved_width,const int kernel_h, const int kernel_w, const int kernel_n,
		const int stride_h, const int stride_w, const int pad_h, const int pad_w,
		Dtype* const top_data,const Dtype* const weight,const Dtype* const bias,const bool bias_term_) {
	CUDA_KERNEL_LOOP(index, nthreads) {

		const int pw = index % conved_width;
    const int ph = (index / conved_width) % conved_height;
    // kernel_n denotes the number of filters which is equal to the number of channels 
    const int c = (index / conved_width / conved_height) % kernel_n;
		const int n = index / conved_width / conved_height / kernel_n;
    
    int hstart = ph * stride_h - pad_h;
		int wstart = pw * stride_w - pad_w;
		int hend = min(hstart + kernel_h, height + pad_h);
		int wend = min(wstart + kernel_w, width + pad_w);
//		const int pool_size = (hend - hstart) * (wend - wstart);
		hstart = max(hstart, 0);
		wstart = max(wstart, 0);
		hend = min(hend, height);
		wend = min(wend, width);
    Dtype aveval = 0;
    
//		if (index==1) {
//			printf("pw%d ph%d c%d n%d \n",pw,ph,c,n);
//			printf("hstart%d wstart%d hend%d wend%d \n",hstart,wstart,hend,wend);
//		}
    for(int ch = 0; ch < channels; ++ch){
      int khstart=hend<kernel_h?kernel_h-hend:0;
      int kwstart=wend<kernel_w?kernel_w-wend:0;
      const Dtype*  bottom_slice = bottom_data + (n * channels + ch) * height * width;
      const Dtype*  weight_slice = weight + (c * channels + ch) * kernel_h * kernel_w;
      for (int h = hstart; h < hend; ++h) {
        for (int w = wstart; w < wend; ++w) {

          //aveval += bottom_slice[h * width + w]*weight_slice[(khstart+h-hstart) * kernel_w + (kwstart+w-wstart)];
          aveval += mult_fixed_conv(&bottom_slice[h * width + w],&weight_slice[(khstart+h-hstart) * kernel_w + (kwstart+w-wstart)]);

        }
      }
    }
		if(bias_term_) {  
			aveval+=bias[c];
		}
		top_data[index] = aveval;
	}
}




  // This code needs to be modified 
template <typename Dtype>
void ConvolutionApproxLayer<Dtype>::Forward_gpu(const vector<Blob<Dtype>*>& bottom,
      const vector<Blob<Dtype>*>& top) {
    //	std::cout << "fp" << std::endl;
	const Dtype* weight = this->blobs_[0]->gpu_data();
	int* kernel_shape_data = this->kernel_shape_.mutable_cpu_data();
	int* stride_data = this->stride_.mutable_cpu_data();
	int* pad_data = this->pad_.mutable_cpu_data();

	for (int i = 0; i < bottom.size(); ++i) {
		const Dtype* bottom_data = bottom[i]->gpu_data();
		Dtype* top_data = top[i]->mutable_gpu_data();
		const int count = top[i]->count();
		vector<int> shape_ = bottom[i]->shape();
		const int channels_ = shape_[1];
		const int height_ = shape_[2];
		const int width_ = shape_[3];

    
    // number_of_outputs 
    vector<int> weight_shape_ = top[i]->shape();
    const int kernel_n_ = weight_shape_[1];


    const int kernel_h_ = kernel_shape_data[0];
		const int kernel_w_ = kernel_shape_data[1];
		const int stride_h_ = stride_data[0];
		const int stride_w_ = stride_data[1];
		const int pad_h_ = pad_data[0];
		const int pad_w_ = pad_data[1];

		const int conved_height = this->output_shape_[0];
		const int conved_weight = this->output_shape_[1];
    
		const bool bias_term_ = this->bias_term_;

		if (bias_term_) {
			const Dtype* const bias = this->blobs_[1]->gpu_data();
			ConvForward<Dtype><<<CAFFE_GET_BLOCKS(count), CAFFE_CUDA_NUM_THREADS>>>(
					count, bottom_data, bottom[i]->num(), channels_,
					height_, width_,conved_height,conved_weight,kernel_h_,
					kernel_w_, kernel_n_, stride_h_, stride_w_, pad_h_, pad_w_, top_data,weight,bias,bias_term_);
		} else {
			ConvForward<Dtype><<<CAFFE_GET_BLOCKS(count), CAFFE_CUDA_NUM_THREADS>>>(
					count, bottom_data, bottom[i]->num(), channels_,
					height_, width_,conved_height,conved_weight,kernel_h_,
					kernel_w_, kernel_n_, stride_h_, stride_w_, pad_h_, pad_w_, top_data,weight,0,bias_term_);
		}
	}
}

template <typename Dtype>
void ConvolutionApproxLayer<Dtype>::Backward_gpu(const vector<Blob<Dtype>*>& top,
      const vector<bool>& propagate_down, const vector<Blob<Dtype>*>& bottom) {
  const Dtype* weight = this->blobs_[0]->gpu_data();
  Dtype* weight_diff = this->blobs_[0]->mutable_gpu_diff();
  for (int i = 0; i < top.size(); ++i) {
    const Dtype* top_diff = top[i]->gpu_diff();
    // Bias gradient, if necessary.
    if (this->bias_term_ && this->param_propagate_down_[1]) {
      Dtype* bias_diff = this->blobs_[1]->mutable_gpu_diff();
      for (int n = 0; n < this->num_; ++n) {
        this->backward_gpu_bias(bias_diff, top_diff + n * this->top_dim_);
      }
    }
    if (this->param_propagate_down_[0] || propagate_down[i]) {
      const Dtype* bottom_data = bottom[i]->gpu_data();
      Dtype* bottom_diff = bottom[i]->mutable_gpu_diff();
      for (int n = 0; n < this->num_; ++n) {
        // gradient w.r.t. weight. Note that we will accumulate diffs.
        if (this->param_propagate_down_[0]) {
          this->weight_gpu_gemm(bottom_data + n * this->bottom_dim_,
              top_diff + n * this->top_dim_, weight_diff);
        }
        // gradient w.r.t. bottom data, if necessary.
        if (propagate_down[i]) {
          this->backward_gpu_gemm(top_diff + n * this->top_dim_, weight,
              bottom_diff + n * this->bottom_dim_);
        }
      }
    }
  }
}

INSTANTIATE_LAYER_GPU_FUNCS(ConvolutionApproxLayer);

}  // namespace caffe
