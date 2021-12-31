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
import scipy
from scipy import signal
import matplotlib.pyplot as plt
from polyphase import Channelizer
from numpy import reshape
import numpy as np

# Calculate two complement of a list
def complement2(lst, bit_width):
    return [int(n) if n > 0 else int(n + 2 ** bit_width) for n in lst]

def num2hex(lst, field_width):
    return ['{0:0{1}x}'.format(int(v), field_width) for v in lst]

channel_num = 4
coe_width = 24

# Design FIR Filter
cutoff = 1 / channel_num / 2    # Desired cutoff digital frequency
trans_width = cutoff / 10  # Width of transition from pass band to stop band
numtaps = 32      # Size of the FIR filter.
taps = signal.remez(numtaps, [0, cutoff - trans_width, cutoff + trans_width, 0.5],[1, 0])

w, h = signal.freqz(taps)
ax1 = plt.subplot(211)
ax1.set_title('Digital filter frequency response')
ax1.plot(w, 20 * np.log10(abs(h)), 'b')
ax1.set_ylabel('Amplitude [dB]', color='b')
ax1.set_xlabel('Frequency [rad/sample]')
ax2 = ax1.twinx()
angles = np.unwrap(np.angle(h))
ax2.plot(w, angles, 'g')
ax2.set_ylabel('Angle (radians)', color='g')
ax2.grid()
ax2.axis('tight')
ax3 = plt.subplot(212)
ax3.plot(taps)
plt.show()

channelizer = Channelizer(taps, channel_num)

w, a = channelizer.sweep_freqz()

plt.figure()
plt.plot(w,a.T)
plt.title('Digital channelizer frequency response')
plt.xlabel('Frequency [*rad/sample]')
plt.ylabel('Amplitude [dB]')
plt.show()

# Generate coefficients for FIR filter with multi-sets.
taps = reshape(taps, (-1, channel_num)) * channel_num
filename = 'D:/fir.coe'
with open(filename, 'w') as f:
    for t in taps:
        t = t * 2 ** (coe_width - 1)
        taps_compl2 = complement2(t, coe_width)
        field_width = int(np.ceil(coe_width / 4))
        coes = num2hex(taps_compl2, field_width)
        f.write(''.join(coes) + '\n')
    print('INFO: Coefficients File for FIR filter has been created. Filename: ', filename)
    
            