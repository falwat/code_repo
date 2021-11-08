# PFFT(并行快速傅里叶变换模块)

- [PFFT(并行快速傅里叶变换模块)](#pfft并行快速傅里叶变换模块)
  - [概述](#概述)
    - [创建工程](#创建工程)
    - [文件组成](#文件组成)
  - [参数说明](#参数说明)
  - [端口描述](#端口描述)
  - [资源消耗](#资源消耗)
  - [时延](#时延)
  - [测试](#测试)

## 概述

PFFT 模块采用时域抽取基-2分解方法来计算N点DFT, N为2的指数幂(2^FFT_ORDER, FFT_ORDER = 1,2,...,6).对于64点(2^6)以上的FFT计算, 需要对代码进行适当修改.

### 创建工程

- 使用`git`工具克隆此仓库.

```sh
git clone https://github.com/falwat/code_repo.git
```

- 打开`vivado tcl shell`, 使用`cd`命令切换至pfft目录
- 运行`source ./create_project.tcl`,创建测试工程
```sh
cd <仓库所在文件夹/code_repo/pfft>
source ./create_project.tcl
```

### 文件组成

文件|说明
-|-
[./pfft.v](./pfft.v) | 并行FFT模块.
[./butterfly_block.v](./butterfly_block.v) | DIT-FFT 的一次分解模块. 在`pfft`模块和自己内部实例化<br>由两个子一级的`butterfly_block `和 一层蝶形运算模块`butterfly`构成.
[./butterfly.v](./butterfly.v) | 蝶形运算模块
[../common/cmult.v](../common/cmult.v) | 复数乘法器. 在`butterfly`模块中实例化.
[./sim_butterfly.v](./sim_butterfly.v) | `butterfly`模块的测试激励文件
[./sim_pfft.v](./sim_pfft.v) | `pfft`模块的测试激励文件
[./sim_pfft.py](./sim_pfft.py) | `pfft`模块测试分析脚本
[./sim_data_gen.py](./sim_data_gen.py) | 为`pfft`模块测试激励文件生成测试数据.
[./create_project.tcl](./create_project.tcl) | 用于生成测试工程的tcl脚本.
[./readme.md](./readme.md) | 说明文件(英文)
[./readme_zh.md](./readme_zh.md) | 说明文件(中文)

## 参数说明

名称|类型|描述
-|-|-
FFT_ORDER | integer | FFT的阶数. `FFT_ORDER = log2(N), N = 2,4,8,16,32,64.`
COMPLEX_DWIDTH | integer | 数据位宽. 

## 端口描述

名称|I/O|描述
-|:-:|-
aclk | I | 上升沿触发.
aresetn | I | 同步复位信号. 低电平有效.
scale_sch | I | 缩放控制. 每个位控制一级蝶形运算模块. <br>0: 不对蝶形运算的输出进行缩放;<br>1: 对蝶形运算的输出缩小到1/2.
s_axis_tvalid | I | 数据输入通道的TVALID端口. 1表示输入数据有效.
s_axis_tdata | I | 数据输入通道的TDATA端口. 位宽由参数`FFT_ORDER` 和 `COMPLEX_DWIDTH` 决定, 通过如下公式进行计算: `2 ** FFT_ORDER * COMPLEX_DWIDTH`. <br>输入数据`x`在端口的映射为: `{x[N-1].imag, x[N-1].real, ..., x[1].imag, x[1].real, x[0].imag, x[0].real}`
m_axis_tvalid | O | 数据输出通道的TVALID端口. 1表示输出数据有效.
m_axis_tdata | O | 数据输出通道的TDATA端口. 位宽由参数`FFT_ORDER` 和 `COMPLEX_DWIDTH` 决定, 通过如下公式进行计算: `2 ** FFT_ORDER * COMPLEX_DWIDTH`. <br>输出数据`X`在端口的映射为: `{X[N-1].imag, X[N-1].real, ..., X[1].imag, X[1].real, X[0].imag, X[0].real}`

## 资源消耗

DSP48E 的使用量满足如下公式:
$$
    3 * 2^{N-1}  * (\log_2(N) - 1)
$$
对于16点的PFFT, 需要的DSP48E的数量为: 3 * 8 * 3 = 72

实际综合后的资源消耗如下表所示:
N-点FFT | Slice LUTs | Slice Registers | DSPs
:-:|-:|-:|-:
8 | 1667 | 2372 | 24
16 | 4611 | 6560 | 72
32 | 11779 | 16754 | 192
64 | 28678 | 40751 | 480 

## 时延

数据输入到N点FFT计算结果输出所需的时延满足如下计算公式:
$$
    Latency(N) = (\log_2(N)-1) * 8 + 2
$$

N点FFT的时延如下表:
N点FFT|时延(clks)
:-:|-:
2 | 2
4 | 10
8 | 18
16 | 26
32 | 34
64 | 42


## 测试

- 根据需要修改[./pfft.v](./pfft.v)中参数`FFT_ORDER`的值.
- 修改[./sim_data_gen.py](./sim_data_gen.py)中`fft_len`参数的值. `fft_len`表示计算FFT的点数.
- 运行[./sim_data_gen.py](./sim_data_gen.py), 生成测试数据文件`numbers.txt`, 默认保存路径为`D:\`.
- 在`Vivado`中,点击`Flow Navigator`中的`Run Simulation`,或使用菜单`Flow|Run Simulation`
- 运行仿真后, 在`D:\`下会生成输出数据文件`output.dat`.
- 运行[./sim_pfft.py](./sim_pfft.py),查看测试结果. 打印信息中,`x`代表输入数据的值, `vhd`表示pfft模块输出的计算结果, `myfft`为python实现的基-2 DIT-FFT函数的输出结果, `fft` 为numpy.fft.fft函数输出的计算结果,`diff`为PFFT模块输出结果与python函数`myfft`计算结果的偏差.
