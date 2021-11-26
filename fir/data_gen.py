import numpy as np
import numpy.random as random
import matplotlib.pyplot as plt

# Calculate two complement of a list
def complement2(lst, bit_width):
    return [int(n) if n > 0 else int(n + 2 ** bit_width) for n in lst]

def num2hex(lst, field_width):
    return ['{0:0{1}x}'.format(int(v), field_width) for v in lst]

data_width = 16
n = 1000
s = random.randn(n)
s = s / max(np.abs(s))
s = s * (2 ** (data_width - 1) - 1)

s = complement2(s, data_width)
plt.figure()
plt.hist(s,64)
# plt.plot(h)
plt.show()

# Generate coefficients for FIR filter
filename = 'D:/data.dat'
with open(filename, 'w') as f:
    field_width = int(np.ceil(data_width / 4))
    data = num2hex(s, field_width)
    f.write('\n'.join(data))
    print('INFO: the data file for test has been created. Filename: ', filename)

