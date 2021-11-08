# PFFT(Parallel Fast Fourier Transform) Module

The `PFFT` module uses the Radix-2 decimation-in-time(DIT) decomposition method for computing the DFT.

The `PFFT` module computes an N-Point forward DFT where N is 2^FFT_ORDER, 
the value of parameter FFT_ORDER can be 1,2,..,6. For larger N, you need to modify 
the source code appropriately.

The main difference with Xilinx FFT LogiCORE IP is that `PFFT` can perform one FFT operation per clock, but Xilinx FFT LogiCORE IP need N+1 clocks.

