import cocotb
import random
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

# --- SPI Master Transaction ---
async def spi_master_tx(dut, rw_bit, addr, data_write=0):
    """
    SPI Mode 0 Master. 16-bit frame: [RW, 7b Addr, 8b Data]
    Returns: Read byte (8 bits)
    """
    frame = 0
    if rw_bit: frame |= (1 << 15)
    frame |= ((addr & 0x7F) << 8)
    frame |= (data_write & 0xFF)

    dut.ss_n.value = 0
    await Timer(100, unit='ns')

    read_byte = 0

    # 16 clocks (MSB first)
    for i in range(15, -1, -1):
        # MOSI Setup (Falling Edge)
        dut.mosi.value = (frame >> i) & 1
        await Timer(50, unit='ns') 
        
        # MISO Sample (Rising Edge)
        dut.sclk.value = 1
        await Timer(1, unit='ns') 
        if dut.miso.value.is_resolvable and dut.miso.value:
             read_byte |= (1 << i)
        await Timer(49, unit='ns')
        dut.sclk.value = 0

    await Timer(100, unit='ns')
    dut.ss_n.value = 1
    await Timer(100, unit='ns')
    
    return read_byte & 0xFF

# --- Main Test ---
@cocotb.test()
async def test_full_functionality(dut):
    """
    Verifies all Probes and Controls defined in the Python generator.
    Uses random data.
    """
    
    # 1. Setup
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    dut.rst_n.value = 0
    dut.ss_n.value  = 1
    dut.sclk.value  = 0
    dut.mosi.value  = 0
    
    # Init inputs
    dut.monitor_status.value = 0
    dut.fifo_level.value     = 0
    dut.tap_0.value          = 0
    dut.tap_1.value          = 0

    await Timer(50, unit='ns')
    dut.rst_n.value = 1
    await Timer(50, unit='ns')

    dut._log.info("--- STARTING 100% COVERAGE TEST ---")

    # -------------------------------------------------------
    # 2. Verify PROBES (Read-Only)
    # -------------------------------------------------------
    # Map: Name -> (Signal Handle, Address)
    probes = [
        ("monitor_status", dut.monitor_status, 0x00),
        ("fifo_level",     dut.fifo_level,     0x01),
        ("tap_0",          dut.tap_0,          0x02),
        ("tap_1",          dut.tap_1,          0x03)
    ]

    for name, signal, addr in probes:
        test_val = random.randint(0, 255)
        signal.value = test_val
        await Timer(10, unit='ns') # Propagate
        
        dut._log.info(f"Checking Probe '{name}' @ 0x{addr:02X} with val 0x{test_val:02X}")
        read_val = await spi_master_tx(dut, rw_bit=1, addr=addr)
        
        assert read_val == test_val, \
            f"Probe {name} failed! Exp 0x{test_val:02X}, Got 0x{read_val:02X}"

    # -------------------------------------------------------
    # 3. Verify CONTROLS (Write & Readback)
    # -------------------------------------------------------
    # Map: Name -> (Signal Handle, Address)
    controls = [
        ("sw_reset", dut.sw_reset, 0x10),
        ("mode",     dut.mode,     0x11)
    ]

    for name, signal, addr in controls:
        test_val = random.randint(0, 255)
        
        # A. WRITE
        dut._log.info(f"Writing Control '{name}' @ 0x{addr:02X} with val 0x{test_val:02X}")
        await spi_master_tx(dut, rw_bit=0, addr=addr, data_write=test_val)
        await RisingEdge(dut.clk) # Wait for register update
        
        # Check HW Output
        assert signal.value == test_val, \
            f"HW Output {name} failed! Exp 0x{test_val:02X}, Got 0x{signal.value:02X}"

        # B. READBACK
        dut._log.info(f"Reading back '{name}' via SPI...")
        read_val = await spi_master_tx(dut, rw_bit=1, addr=addr)
        
        assert read_val == test_val, \
            f"Readback {name} failed! Exp 0x{test_val:02X}, Got 0x{read_val:02X}"

    dut._log.info("--- ALL REGISTERS VERIFIED SUCCESSFULLY ---")