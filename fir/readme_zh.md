# FIR 滤波器模块设计

## 概述

该工程实现了一个单速率(single-rate)有限冲激响应(FIR)滤波器模块的设计. 单速率FIR滤波器完成如下公式所示的卷积运算:

$$
y(k) = \sum_{n=0}^{N-1}h(n)x(k-n)
$$

下图为直接型FIR滤波器的常规结构, 该图便于理解FIR滤波器的处理流程, 但实际在FPGA上的设计实现并不采用此方法 *(截取自[pg149-fir-compiler.pdf](https://www.xilinx.com/support/documentation/ip_documentation/fir_compiler/v7_2/pg149-fir-compiler.pdf))*.

![fir_1.png](./image/fir_1.png)

下图给出直接型FIR滤波器的变换形式, 这里采用此方法完成FIR滤波器的设计. *(截取自[pg149-fir-compiler.pdf](https://www.xilinx.com/support/documentation/ip_documentation/fir_compiler/v7_2/pg149-fir-compiler.pdf))*.
![df_fir.png](./image/df_fir.png)

### 创建工程

- 使用`git`工具克隆此仓库.

```sh
git clone https://github.com/falwat/code_repo.git
```

- 打开`vivado tcl shell`, 使用`cd`命令切换至`fir`目录
- 运行`source ./create_project.tcl`,创建测试工程
```sh
cd <仓库所在文件夹/code_repo/fir>
source ./create_project.tcl
```

### 

文件|说明
-|-
[./create_project.tcl](./create_project.tcl) | 创建工程的tcl脚本.
[./data_gen.py](./data_gen.py) | 生成测试数据的python脚本, 供仿真使用.
[./fir_coe_gen.py](./fir_coe_gen.py) | 生成滤波器系数文件的脚本.
[./fir.v](./fir.v) | **FIR顶层模块**
[./multadd.v](./multadd.v) | FIR中的乘法-加法计算模块
[./readme_zh.md](./readme_zh.md) | 说明文件(中文)
[./sim_fir.py](./sim_fir.py) | FIR模块的测试分析脚本
[./sim_fir.v](./sim_fir.v) | FIR模块的测试激励文件
[../common/pipe_delay.v](../common/pipe_delay.v) | 延迟模块

## 参数说明

名称|类型|描述
-|-|-
C_S_DATA_TDATA_WIDTH | integer | 输入数据总线位宽.
C_M_DATA_TDATA_WIDTH | integer | 输出数据总线位宽.
C_RELOAD_TDATA_WIDTH | integer | 重载滤波器系数总线位宽.
C_COEF_FILE | string | FIR系数文件.
C_NUM_TAPS | integer | 滤波器系数数组长度.

## 端口说明

名称|I/O|描述
-|:-:|-
aclk | I | 上升沿触发.
aresetn | I | 同步复位信号. 低电平有效.
s_axis_reload_tvalid | I | 重载系数总线TVALID端口
s_axis_reload_tlast | I | 重载系数总线TLAST端口
s_axis_reload_tdata | I | 重载系数总线TDATA端口
s_axis_data_tvalid | I | 输入数据总线的TVALID端口
s_axis_data_tdata | I | 输入数据总线的 TDATA 端口
m_axis_data_tvalid | O | 输出数据总线的 TVALID 端口
m_axis_data_tdat | O | 输出数据总线的 TDATA 端口

## 资源消耗

当数据位宽和系数位宽不超过DSP48E的输入数据端口位宽时, 每个乘法-加法运算单元需要一个 DSP48E, 故 DSP48E 的使用量 N 为: N = C_NUM_TAPS

## 时延

输入数据有效(s_axis_data_tvalid==1)到输出数据有效(m_axis_data_tvalid==1)的时延为1 clocks.

## 测试

- 根据需要修改[sim_fir.v](./sim_fir.v)中参数值.
- 修改[data_gen.py](./data_gen.py)中`data_width`变量的值. 该变量的值应与[sim_fir.v](./sim_fir.v)中 `C_S_DATA_TDATA_WIDTH`参数的值一致.
- 运行[data_gen.py](./data_gen.py), 生成测试数据文件`data.dat`, 默认保存路径为`D:/`. 
- 修改[fir_coe_gen.py](./fir_coe_gen.py)中`coe_width`变量的值, 该变量的值应与[sim_fir.v](./sim_fir.v)中`C_RELOAD_TDATA_WIDTH`参数的值一致.
- 运行[fir_coe_gen.py](./fir_coe_gen.py), 生成滤波器系数文件`fir.coe`, 默认保存路径为`D:/`.
- 在`Vivado`中,点击`Flow Navigator`中的`Run Simulation`,或使用菜单`Flow|Run Simulation`
- 点击菜单`Run | Run All(F3)`运行仿真, 运行停止后, 在`D:/`下会生成输出数据文件`output.dat`.
- 修改[sim_fir.py](./sim_fir.py)中`coe_width`变量和`data_width`变量的值.
- 运行[sim_fir.py](./sim_fir.py),查看测试结果. 打印如下内容, 表明测试成功.

  ```
  diff y with y_: 0.0
  ```