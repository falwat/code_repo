# My Module Repositry

[Click here for readme in Chinese...](./README_zh.md)

## FIR Filter Module

This design implements a single-rate finite impulse response (FIR) filter module.

> For more details, please read [fir readme](./fir/readme_zh.md)

## PFFT(Parallel FFT) Processing Module

The `PFFT` module uses the Radix-2 decimation-in-time(DIT) decomposition method for computing the DFT.

The `PFFT` module computes an N-Point forward DFT where N is 2^FFT_ORDER, 
the value of parameter FFT_ORDER can be 1,2,..,6. For larger N, you need to modify 
the source code appropriately.

The main difference with Xilinx FFT LogiCORE IP is that `PFFT` can perform one FFT operation per clock, but Xilinx FFT LogiCORE IP need N+1 clocks.

> For more details, please read [pfft's readme](./pfft/readme.md)

## Channelized Receiver Module Based on Polyphase Filterbank (CHNN_RCVR)

In this design, channelized receiver module based on polyphase filterbank with configurable channel number and filter coefficient is implemented.

> For more details, please read [chn_rcvr readme](./chnn_rcvr/readme_zh.md).