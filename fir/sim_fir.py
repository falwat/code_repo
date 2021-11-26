import matplotlib.pyplot as plt
import scipy.signal as signal
import numpy as np
import numpy.fft as fft


coe_filename = r'D:/fir.coe'
data_filename = r'D:/data.dat'
dout_filename = r'D:/output.dat'
coe_width = 24
data_width = 16

def read_fir_coes(filename, bit_width):
    with open(filename, 'r') as f:
        lines = f.readlines()
        coes = [int(e, base=16) for e in lines]
        b = [coe if coe < (2**(bit_width-1)) else (coe - 2**bit_width) for coe in coes]
        return [bb / (2**(bit_width-1)) for bb in b ]

def read_data(filename, bit_width):
    with open(filename, 'r') as f:
        lines = f.readlines()
        data = [int(n, base=16) for n in lines]
        data = [d if d < (2 ** (bit_width - 1)) else (d - 2**bit_width) for d in data]
        return data

b = read_fir_coes(coe_filename, coe_width)
x = read_data(data_filename, data_width)
y_ = np.array(read_data(dout_filename, data_width))

w, h = signal.freqz(b)
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
ax3.plot(b)
plt.show()

y = signal.lfilter(b, 1, x)
y = np.floor(y)
plt.figure()
ax1 = plt.subplot(221)
ax1.plot(y_)
ax2 = plt.subplot(222)
ax2.plot(abs(fft.fft(y_)))
ax3 = plt.subplot(223)
ax3.plot(y)
ax4 = plt.subplot(224)
ax4.plot(abs(fft.fft(y)))
plt.show()

print('diff y with y_:', sum(abs(y - y_)))






