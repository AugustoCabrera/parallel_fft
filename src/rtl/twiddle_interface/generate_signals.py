import numpy as np
from fxpmath import Fxp

NB_WORD = 10
NB_FRAC = 7
NUM_SAMPLES = 8
FFT_SIZE = 64

FXP_CONFIG = {
    'signed': True,
    'n_word': NB_WORD,
    'n_frac': NB_FRAC,
    'overflow': 'saturate',
    'rounding': 'floor'
}

def to_fxp(value):
    return Fxp(value, **FXP_CONFIG)

def fxp_complex_mult_bit_accurate(a_real, a_imag, b_real, b_imag):
    prod1 = a_real * b_real
    prod2 = a_imag * b_imag
    prod3 = a_real * b_imag
    prod4 = a_imag * b_real
    
    c_real_full = prod1 - prod2
    c_imag_full = prod3 + prod4
    
    return to_fxp(c_real_full), to_fxp(c_imag_full)

def write_mem_file(filename, data):
    with open(filename, "w") as f:
        for real_val, imag_val in data:
            combined_bin = real_val.bin() + imag_val.bin()
            f.write(combined_bin + "\n")

if __name__ == "__main__":
    twiddles = {'w1': [], 'w2': [], 'w3': []}
    for n in range(NUM_SAMPLES):
        w1_complex = np.exp(-2j * np.pi * n / FFT_SIZE)
        w2_complex = np.exp(-2j * np.pi * 2 * n / FFT_SIZE)
        w3_complex = np.exp(-2j * np.pi * 3 * n / FFT_SIZE)
        twiddles['w1'].append((to_fxp(w1_complex.real), to_fxp(w1_complex.imag)))
        twiddles['w2'].append((to_fxp(w2_complex.real), to_fxp(w2_complex.imag)))
        twiddles['w3'].append((to_fxp(w3_complex.real), to_fxp(w3_complex.imag)))

    write_mem_file("twiddle_w1.mem", twiddles['w1'])
    write_mem_file("twiddle_w2.mem", twiddles['w2'])
    write_mem_file("twiddle_w3.mem", twiddles['w3'])

    inputs = {f'signal_{i}': [] for i in range(4)}
    for i in range(4):
        for _ in range(NUM_SAMPLES):
            real, imag = np.random.uniform(-1.0, 1.0, 2)
            inputs[f'signal_{i}'].append((to_fxp(real), to_fxp(imag)))
        write_mem_file(f'input_signal_{i}.txt', inputs[f'signal_{i}'])

    outputs = {f'signal_{i}': [] for i in range(4)}
    for n in range(NUM_SAMPLES):
        outputs['signal_0'].append(inputs['signal_0'][n])
        
        outputs['signal_1'].append(fxp_complex_mult_bit_accurate(*inputs['signal_1'][n], *twiddles['w1'][n]))
        outputs['signal_2'].append(fxp_complex_mult_bit_accurate(*inputs['signal_2'][n], *twiddles['w2'][n]))
        outputs['signal_3'].append(fxp_complex_mult_bit_accurate(*inputs['signal_3'][n], *twiddles['w3'][n]))

    for i in range(4):
        write_mem_file(f'golden_output_{i}.txt', outputs[f'signal_{i}'])

    print("Test vector generation complete!")

