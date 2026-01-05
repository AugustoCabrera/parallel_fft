import numpy as np
from fxpmath import Fxp

def generate_complex_signal(n_samples):
    real_part = np.random.uniform(low=-1.0, high=1.0, size=n_samples)
    imag_part = np.random.uniform(low=-1.0, high=1.0, size=n_samples)
    return real_part + 1j * imag_part

if __name__ == "__main__":
    N_SAMPLES = 4
    
    FXP_FORMAT_INPUT = 'fxp-s8/7'
    FXP_FORMAT_OUTPUT = 'fxp-s10/7'

    signal_float = generate_complex_signal(N_SAMPLES)
    
    signal_fxp_real = Fxp(np.real(signal_float), dtype=FXP_FORMAT_INPUT)
    signal_fxp_imag = Fxp(np.imag(signal_float), dtype=FXP_FORMAT_INPUT)

    quantized_input_for_fft = signal_fxp_real.get_val() + 1j * signal_fxp_imag.get_val()
    fft_reference_float = np.fft.fft(quantized_input_for_fft)
    
    fft_ref_fxp_real = Fxp(np.real(fft_reference_float), dtype=FXP_FORMAT_OUTPUT, overflow='saturate', rounding='trunc')
    fft_ref_fxp_imag = Fxp(np.imag(fft_reference_float), dtype=FXP_FORMAT_OUTPUT, overflow='saturate', rounding='trunc')

    with open("input_vectors.txt", "w") as f_in, open("output_vectors.txt", "w") as f_out:
        print("--- Input Vectors (Real | Imag) ---")
        for i in range(N_SAMPLES):
            input_vector_str = signal_fxp_real[i].bin() + signal_fxp_imag[i].bin()
            f_in.write(input_vector_str + "\n")
            print(input_vector_str)

        print("\n--- Output Vectors (Real | Imag) ---")
        for i in range(N_SAMPLES):
            output_vector_str = fft_ref_fxp_real[i].bin() + fft_ref_fxp_imag[i].bin()
            f_out.write(output_vector_str + "\n")
            print(output_vector_str)

