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

Created on Sat Nov 27 14:40:17 2021

@author: falwa
"""

"""
Channelizer class.
"""

__all__ = ['Channelizer']

import numpy
import scipy.signal
import scipy.fft
import matplotlib.pyplot as plt


class Channelizer(object):
    """
    Channelizer object.
    \param filter_coeffs: Filter coefficient array.
    """

    _channel_num: int
    _filter_coeffs: numpy.ndarray

    def __init__(
            self, 
            filter_coeffs: numpy.ndarray,
            channel_num: int = 8):

        assert  isinstance(channel_num, int)

        self._filter_coeffs = numpy.reshape(filter_coeffs, (channel_num, -1), order='F') 
        self._channel_num = channel_num

    def dispatch(
            self, 
            data: numpy.ndarray
            ) -> numpy.ndarray:

        # Make the data length an integer multiple of the number of channels.
        disp_len = int(numpy.ceil(data.size / self._channel_num))
        patch_size = int(disp_len * self._channel_num - data.size)
        patch_data = numpy.concatenate((data, numpy.zeros(patch_size)))

        # Reshape data.
        reshape_data = numpy.reshape(patch_data, (self._channel_num, -1), order='F')
        polyphase_data = numpy.flipud(reshape_data)

        nv = numpy.arange(disp_len)
        prefilt_data = polyphase_data * ((-1) ** nv)

        # Polyphase filter bank
        filt_data = numpy.zeros(prefilt_data.shape, dtype=complex)
        for k in range(self._channel_num):
            # zi = scipy.signal.lfilter_zi(self._filter_coeffs[k], 1)
            filt_data[k] = scipy.signal.lfilter(self._filter_coeffs[k], 1, prefilt_data[k])
    
        postfilt_data = numpy.zeros(prefilt_data.shape, dtype=complex)
        for k in range(self._channel_num):
            postfilt_data[k] = filt_data[k] * numpy.exp(-1j * numpy.pi * k / self._channel_num)
        
        # return postfilt_data
    
        dispatch_data = scipy.fft.fft(numpy.flipud(postfilt_data), axis=0)

        return dispatch_data

    def sweep_freqz(self, N: int = 0) -> numpy.ndarray:
        """
        Compute the frequency response of each channel using sweep signal.

        Parameters:
        ----------

        N : the number of sample point.

        Return:
        -------
            a: Amplitude in dB.
            f: Digital frequence point.

        Example:
        --------
            import scipy
            import matplotlib.pyplot as plt
            from polyphase import Channelizer

            # Design FIR Filter
            channel_num = 8
            cutoff = 1 / channel_num / 2    # Desired cutoff digital frequency
            trans_width = cutoff / 10  # Width of transition from pass band to stop band
            numtaps = 512      # Size of the FIR filter.
            taps = scipy.signal.remez(numtaps, [0, cutoff - trans_width, cutoff + trans_width, 0.5],[1, 0])

            channelizer = Channelizer(taps, channel_num)

            w, a = channelizer.sweep_freqz()

            plt.plot(w,a.T)
            plt.title('Digital channelizer frequency response')
            plt.xlabel('Frequency [*rad/sample]')
            plt.ylabel('Amplitude [dB]')
            plt.show()

        """
        assert isinstance(N, int)

        if N == 0:
            N = self._filter_coeffs.size * 100
        
        w = numpy.linspace(0, 1, N)
        p = 2 * numpy.pi * numpy.cumsum(w)
        s = numpy.exp(1j * p)
        a = 20*numpy.log10(numpy.abs(self.dispatch(s)))
        w = numpy.linspace(0, 1, a.shape[1])
        return w, a
