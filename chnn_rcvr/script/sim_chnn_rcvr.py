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
import scipy.signal as signal
import numpy as np
import matplotlib.pyplot as plt
from polyphase import Channelizer


coe_filename = r'D:/fir.coe'
data_filename = r'D:/data.dat'
dout_filename = r'D:/output.dat'
coe_width = 24
data_width = 16


def read_fir_coes(filename, bit_width):
    field_width = int(bit_width / 4)
    with open(filename, 'r') as f:
        lines = f.readlines()
        coes = []
        for d in lines:
            coe_row = [int(d[k:k+field_width],base=16) for k in range(0, len(d)-1, field_width)]
            coe_row_compl2 = [c if c < 2**(bit_width-1) else (c - 2**bit_width) for c in coe_row]
            coes.append(coe_row_compl2)
        return coes

def read_data(filename, bit_width):
    field_width = int(bit_width / 4)
    with open(filename, 'r') as f:
        lines = f.readlines()
        data = []
        for d in lines:
            data_row = [int(d[k:k+4],base=16) for k in range(0, len(d)-1, field_width)]
            data_row_compl2 = [c if c < 2**(bit_width-1) else (c - 2**bit_width) for c in data_row]
            data.append(data_row_compl2)
        return data


taps = read_fir_coes(coe_filename, coe_width)
taps = np.array(taps)
channel_num = taps.shape[1]
taps = np.reshape(taps, (1,-1))[0,:]
taps = taps / (2**(coe_width-1))
# Plot Digital filter frequency response
w, h = signal.freqz(taps)
plt.figure()
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


x = np.array(read_data(data_filename, data_width)).T
xr = np.flipud(x[1::2])
xi = np.flipud(x[::2])
s = xi * 1j + xr
sigs = np.reshape(s.T, (1,-1))[0]

numtaps = len(taps)


channelizer = Channelizer(taps, channel_num)

# w, a = channelizer.sweep_freqz()

# plt.plot(w,a.T)
# plt.title('Digital channelizer frequency response')
# plt.xlabel('Frequency [*rad/sample]')
# plt.ylabel('Amplitude [dB]')
# plt.show()


ss = channelizer.dispatch(sigs) / channel_num
plt.figure()
plt.subplot(311)
plt.plot(np.real(ss.T))
plt.subplot(312)
plt.plot(np.imag(ss.T))
plt.subplot(313)
h = np.abs(np.fft.fft(ss))
plt.plot(h.T)
plt.show()


y = np.array(read_data(dout_filename, data_width)).T

yr = np.flipud(y[1::2])
yi = np.flipud(y[::2])
data = yi * 1j + yr

plt.figure()
plt.subplot(311)
plt.plot(np.real(data.T))
plt.subplot(312)
plt.plot(np.imag(data.T))
plt.subplot(313)
h = np.abs(np.fft.fft(data))
plt.plot(h.T)
plt.show()

# ss = np.flipud(ss)
dff = np.abs(data - ss)**2 / (np.abs(data) * np.abs(ss))

print(np.max(dff))






