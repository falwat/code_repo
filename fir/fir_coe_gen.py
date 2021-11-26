import numpy as np
from scipy import signal
import matplotlib.pyplot as plt

# Calculate two complement of a list
def complement2(lst, bit_width):
    return [int(n) if n > 0 else int(n + 2 ** bit_width) for n in lst]

def num2hex(lst, field_width):
    return ['{0:0{1}x}'.format(int(v), field_width) for v in lst]

coe_width = 24
# Design FIR Filter
cutoff = 0.125    # Desired cutoff digital frequency
trans_width = cutoff / 10  # Width of transition from pass band to stop band
numtaps = 63      # Size of the FIR filter.
taps = signal.remez(numtaps, [0, cutoff - trans_width, cutoff + trans_width, 0.5],[1, 0])

# b = signal.firwin(20, 0.125, window=('kaiser', 8))
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

# Generate coefficients for FIR filter
filename = 'D:/fir.coe'
with open(filename, 'w') as f:
    taps = taps * 2 ** (coe_width - 1)
    taps_compl2 = complement2(taps, coe_width)
    field_width = int(np.ceil(coe_width / 4))
    coes = num2hex(taps_compl2, field_width)
    f.write('\n'.join(coes))
    print('INFO: Coefficients File for FIR filter has been created. Filename: ', filename)
            