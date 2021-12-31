# -*- coding: utf-8 -*-
"""
Copyright (C) 2021 Jackie Wang(falwat@163.com).  All Rights Reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"""
from numpy import arange, exp, real, imag, pi, round

channel_num = 32

# 数据位宽
bits = 24

# 生成旋转因子系数

imax = 2**(bits-2)

k = arange(channel_num, 0, -1) - 1

tf = exp(-1j*pi*k/channel_num)

im = [int(i) if i >= 0 else int(i) + 2**bits for i in imag(tf) * imax]

re= [int(r) if r >=0 else int(r) + 2**bits for r in real(tf) * imax]

# rf = ['{:08x}\n'.format((i << 16) + r) for i,r in zip(im, re)]

# filename = 'rotate_factors_ch{}.coe'.format(channel_num)
# with open(filename, 'w') as f:
#     f.writelines(rf)
    
rf = ['{}\'h{:06x}_{:06x}'.format(bits * 2, i, r) for i,r in zip(im, re)]

for p in rf:
    print(p)
    