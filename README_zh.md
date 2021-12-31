# 个人模块仓库

[点击此处查看英文说明...](./README.md)

## 有限冲激响应滤波器模块(FIR Filter)

该设计实现了一个单速率(single-rate)有限冲激响应(FIR)滤波器模块.

> 请阅读[fir readme](./fir/readme_zh.md), 获取该模块的详细信息.

## 并行快速傅里叶变换模块(PFFT)

PFFT 模块采用时域抽取基-2分解方法来计算N点DFT, N为2的指数幂(2^FFT_ORDER, FFT_ORDER = 1,2,...,6).对于64点(2^6)以上的FFT计算, 需要对代码进行适当修改.

> 请阅读[pfft's readme](./pfft/readme_zh.md), 获取该模块的详细信息.


## 多相滤波数字信道化模块(chnn_rcvr)

该设计实现了一个通道数和滤波器系数均可配置的多相滤波数字信道化模块.

> 请阅读[chn_rcvr readme](./chnn_rcvr/readme_zh.md), 获取详细信息.

