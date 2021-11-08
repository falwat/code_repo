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

def splitvalue(v, dw):
    i = v >> dw
    i = i if i < 2**(dw - 1) else (i - 2 ** dw)
    r = v % (2 ** dw)
    r = r if r < 2**(dw - 1) else (r - 2 ** dw)
    return r + i*1j

def butterfly(a0, a1, b, s):

    p0 = [(aa0 + aa1 * bb) / (2**s) for aa0, aa1, bb in zip(a0,a1,b)]
    p1 = [(aa0 - aa1 * bb) / (2**s) for aa0, aa1, bb in zip(a0,a1,b)]
    return p0 + p1

def myfft(x,scale_sch):
    if(len(x) == 2):
        return [(x[0] + x[1]) / 2 ** scale_sch[0], (x[0] - x[1]) / 2 ** scale_sch[0]]
    else:
        x0 = [x[k] for k in range(0, len(x), 2)]
        x1 = [x[k] for k in range(1, len(x), 2)]
        a0 = myfft(x0, scale_sch[1::])
        a1 = myfft(x1, scale_sch[1::])
        # print('a0:', a0, 'a1:',a1)
        k = np.arange(len(x0))
        b = np.exp(-2j * np.pi * k/ len(x))
        return butterfly(a0, a1, b, scale_sch[0])

if __name__ == '__main__':
    skip = 0
    scale_sch = [1,1]
    ys = []
    
    with open('D:/output.dat', 'r') as f:
        lines = f.readlines()
        for line in lines:
            if skip < 1:
                skip += 1
                continue
            data = [int(line[k:k+4], base=16) for k in range(0,len(line)-1,4)]
            data = [d if d < 2**15 else d - 2**16 for d in data]
            y = [data[k]*1j + data[k+1] for k in range(0, len(data), 2)]
            y = y[::-1]
            ys.append(y)
            # print(y)

    with open('D:/numbers.txt','r') as f:
        lines = f.readlines()
        n = 0
        for line in lines:
            data = [int(line[k:k+4], base=16) for k in range(0,len(line)-1,4)]
            data = [d if d < 2**15 else d - 2**16 for d in data]
            x = [data[k]*1j + data[k+1] for k in range(0, len(data), 2)]
            x = x[::-1]
            y = myfft(x, scale_sch)
            y0 = np.fft.fft(x) / (2 ** sum(scale_sch))
            d = [int(abs(y0 - y1)) for y0, y1 in zip(y, ys[n])]
            print('-------------------------------------')
            print('x: ', x, '\nfft: ', y0, '\nvhd:', ys[n] , '\nmyfft: ', y, '\ndiff: ', d)

            n += 1

            


