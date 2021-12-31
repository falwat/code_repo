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
import numpy as np

chn_num = 4
w = 0.04
N = chn_num * 256
amp = 0.5

n = np.arange(N)
s = np.exp(2j*np.pi*w*n) * amp

sir = np.array((np.imag(s), np.real(s)))

sir_int = np.int16(sir * 2 **15)

s1 = np.fliplr(np.reshape(sir_int.T, (-1,chn_num * 2)))

filename = 'D:/data.dat'
with open(filename, 'w') as f:
    for a in s1:
        h = ['{:04x}'.format(v) for v in a.astype(np.uint16)]
        f.write(''.join(h) + '\n')
        
    print('INFO: The data file has been created. Filename: ', filename)

