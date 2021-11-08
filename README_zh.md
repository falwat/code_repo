# 个人模块仓库

[点击此处查看英文说明...](./README.md)

## PFFT(并行快速傅里叶变换模块)

PFFT 模块采用时域抽取基-2分解方法来计算N点DFT, N为2的指数幂(2^FFT_ORDER, FFT_ORDER = 1,2,...,6).对于64点(2^6)以上的FFT计算, 需要对代码进行适当修改.

> 如果要获取该模块的详细信息,请阅读[pfft's readme](./pfft/readme_zh.md)

