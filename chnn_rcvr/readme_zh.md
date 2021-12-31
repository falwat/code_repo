# 基于多相滤波的数字信道化接收模块设计

## 概述

该设计实现了一个通道数和滤波器系数均可配置的多相滤波数字信道化模块.

- 通道数: 支持2, 4, 8, 16, 32 信道.

### 创建工程

- 使用`git`工具克隆此仓库.

```sh
git clone https://github.com/falwat/code_repo.git
```

- 打开`vivado tcl shell`, 使用`cd`命令切换至`chnn_rcvr`目录
- 运行`source ./create_project.tcl`,创建测试工程
```sh
cd <仓库所在文件夹/code_repo/chnn_rcvr>
source ./create_project.tcl
```

### 文件组成

文件|说明
-|-
[./create_project.tcl](./create_project.tcl) | 用于生成测试工程的tcl脚本.
[./readme_zh.md](./readme_zh.md) | 说明文件(中文)
[./hdl/axi_cmult.v](./hdl/axi_cmult.v) | AXI-Stream总线接口的复数乘法器
[./hdl/exp_mult.v](./hdl/exp_mult.v) | 实现$(-1)^{(K-1)m}$ 的乘法器
[./hdl/chnn_rcvr.v](./hdl/chnn_rcvr.v) | **信道化接收模块顶层**
[./script/fir_coe_gen.py](./script/fir_coe_gen.py) | 用于生成FIR滤波器系数文件的脚本
[./script/rotate_factor_gen.py](./script/rotate_factor_gen.py) | 用于生成旋转因子序列的脚本
[./script/sig_gen.py](./script/sig_gen.py) | 用于生成测试数据文件的脚本
[./script/sim_chnn_rcvr.py](./script/sim_chnn_rcvr.py) | 用于仿真测试的脚本
[./sim/sim_chnn_rcvr.v](./sim/sim_chnn_rcvr.v) | 仿真测试激励文件
[../common/cmult.v](../common/cmult.v) | 复数乘法器
[../common/pipe_delay.v](../common/pipe_delay.v) | 延迟模块
[../fir/fir.v](../fir/fir.v) |  FIR滤波器模块顶层, 参见[fir readme](../fir/readme_zh.md)
[../fir/multadd.v](../fir/multadd.v) |  FIR 滤波器的子模块, 参见[fir readme](../fir/readme_zh.md)
[../pfft/butterfly.v](../pfft/butterfly.v) | 并行FFT模块的子模块,参见[pfft readme](../pfft/readme_zh.md)
[../pfft/butterfly_block.v](../pfft/butterfly_block.v) | 并行FFT模块的子模块,参见[pfft readme](../pfft/readme_zh.md)
[../pfft/pfft.v](../pfft/pfft.v) | 并行FFT模块顶层, 参见[pfft readme](../pfft/readme_zh.md)

## 参数说明

名称|类型|描述
-|-|-
CHN_NUM | integer | 信道个数, 支持2, 4, 8, 16, 32 信道.
DATA_WIDTH | integer | 复数数据位宽. 该参数应为偶数.
C_COEF_FILE | string | 多相FIR滤波器系数文件, 请使用[./script/fir_coe_gen.py](./script/fir_coe_gen.py)脚本生成系数文件.
C_COEF_WIDTH | integer | 多相FIR滤波器系数位宽.
C_NUM_TAPS | integer | FIR原型滤波器系数序列长度, 该参数应为信道个数的整数倍.

## 端口描述

名称|I/O|描述
-|:-:|-
aclk | I | 上升沿触发.
aresetn | I | 同步复位信号. 低电平有效.
s_axis_data_tvalid | I | 输入数据总线的TVALID端口.
s_axis_data_tdata | I | 输入数据总线的TDATA端口. <br>位宽: CHN_NUM * DATA_WIDTH. <br>内容: {X[N-1].imag, X[N-1].real,..., X[1].imag, X[1].real, X[0].imag, X[0]. real}
m_axis_data_tvalid | O | 输出数据总线的TVAILD端口.
m_axis_data_tdata  | O | 输出数据总线的TDATA端口. <br>位宽: CHN_NUM * DATA_WIDTH <br>内容: {Y[N-1].imag, Y[N-1].real,..., Y[1].imag, Y[1].real, Y[0].imag, Y[0]. real}

## 资源消耗

DSP48E在FIR滤波器, 复数乘法器和并行FFT三个子模块中使用. DSP48E 的使用量满足如下公式:
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