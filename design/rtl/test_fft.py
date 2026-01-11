import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock

def safe_int(signal):
    try:
        return signal.value.to_signed()
    except:
        return "X"

@cocotb.test()
async def test_shift_r4_ramp(dut):

    clock = Clock(dut.i_clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    dut.i_rst.value = 1
    dut.i_clk_en.value = 1
    dut.i_valid.value = 0
    dut.i_data_re.value = 0
    dut.i_data_im.value = 0

    await Timer(50, unit="ns")
    dut.i_rst.value = 0
    await RisingEdge(dut.i_clk)
    await Timer(1, unit="ps")

    cocotb.log.info("--- Verificando el correcto ordenamiento de las muestras ---")

    for i in range(60):
        if i < 32:
            dut.i_data_re.value = i
            dut.i_data_im.value = i
            dut.i_valid.value = 1 if i == 0 else 0
        else:
            dut.i_data_re.value = 0
            dut.i_data_im.value = 0
            dut.i_valid.value = 0
        
        await RisingEdge(dut.i_clk)
        await Timer(1, unit="ps") 

        d3 = safe_int(dut.u_shift_r4.o_data3_re)
        d2 = safe_int(dut.u_shift_r4.o_data2_re)
        d1 = safe_int(dut.u_shift_r4.o_data1_re)
        d0 = safe_int(dut.u_shift_r4.o_data0_re)
        v_out = dut.u_shift_r4.o_valid.value

        fft0_out0 = safe_int(dut.o_ff0_data0_re)
        fft0_out1 = safe_int(dut.o_ff0_data1_re)
        fft1_out0 = safe_int(dut.o_ff1_data0_re)
        fft1_out1 = safe_int(dut.o_ff1_data1_re)
        fft2_out0 = safe_int(dut.o_ff2_data0_re)
        fft2_out1 = safe_int(dut.o_ff2_data1_re)
        fft3_out0 = safe_int(dut.o_ff3_data0_re)
        fft3_out1 = safe_int(dut.o_ff3_data1_re)
        o_valid = dut.shift_r2_ffx_valid.value

        cocotb.log.info(f"Ciclo {i:2d} | In={i:2d} | D3={d3} | D2={d2} | D1={d1} | D0={d0} | V={v_out} ")
        # cocotb.log.info(f"C {i:2d}|In={i:2d}|V={o_valid}| FF0_d0={fft0_out0},FF0_d1={fft0_out1} | FF1_d0={fft1_out0},FF1_d1={fft1_out1} | FF2_d0={fft2_out0},FF2_d1={fft2_out1} | FF3_d0={fft3_out0},FF3_d1={fft3_out1}")

    cocotb.log.info("Simulación finalizada")