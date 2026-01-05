import random

def generate_random_binary_string(length):
    return ''.join(random.choice('01') for _ in range(length))

if __name__ == "__main__":
    N_SAMPLES = 32
    STRIDE_SIZE = 8
    BIT_WIDTH = 16
    N_OUTPUT_CYCLES = 8

    input_vectors = [generate_random_binary_string(BIT_WIDTH) for _ in range(N_SAMPLES)]

    with open("input_vectors.txt", "w") as f_in:
        for vec in input_vectors:
            f_in.write(vec + "\n")

    output_files = [
        open("output_0.txt", "w"),
        open("output_1.txt", "w"),
        open("output_2.txt", "w"),
        open("output_3.txt", "w")
    ]

    for i in range(N_OUTPUT_CYCLES):
        output_files[0].write(input_vectors[i] + "\n")
        output_files[1].write(input_vectors[i + STRIDE_SIZE] + "\n")
        output_files[2].write(input_vectors[i + (2 * STRIDE_SIZE)] + "\n")
        output_files[3].write(input_vectors[i + (3 * STRIDE_SIZE)] + "\n")

    for f in output_files:
        f.close()

