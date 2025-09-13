# 32-Point MDC-8 FFT RTL

This project implements a **32-point FFT** using the **MDC-8 architecture**, optimized for parallel processing with low resource usage.

![Block Diagram](docs/block_diagrams.jpg)

## Architecture

- **Overlap & Save**: Prepares input samples for linear convolution in the frequency domain, allowing block overlap and avoiding discontinuities.  
- **Stride by 8**: Organizes samples into groups of 8 for parallel processing.  
- **Parallel FFT4**: Performs partial transforms with 4-point butterflies, speeding up calculations in parallel.  
- **Twiddle Interface**: Applies the necessary complex rotation factors to combine partial results.  
- **MDC FFT8**: Combines partial results using the **Multi-path Delay Commutator**, processing 8 samples in parallel without a fully parallel FFT.  
- **Serializer**: Converts the four parallel outputs into a sequential data stream ready for other modules.  
- **FSM Controller & Debug Unit**: Manage block operations and facilitate debugging and analysis.

## Advantages

- Efficient parallel processing (FFT4 + FFT8).  
- Reduced usage of registers, adders, and multipliers thanks to the MDC approach.  
- Ready to integrate with other digital modules.
