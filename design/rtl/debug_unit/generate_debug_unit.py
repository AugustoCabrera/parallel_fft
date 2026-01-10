import sys

NB_ADDR = 7
NB_DATA = 8

# Format: ("signal_name", address_integer)
PROBE_LIST = [
    ("monitor_status", 0x00),
    ("fifo_level",     0x01),
    ("tap_0",          0x02),
    ("tap_1",          0x03)
]

# Format: ("signal_name", address_integer)
CONTROL_LIST = [
    ("sw_reset", 0x10),
    ("mode",     0x11)
]

OUTPUT_FILE = "debug_unit.v"

def generate_rtl():
    verilog = []
    verilog.append(f"module debug_unit #(")
    verilog.append(f"  parameter integer NB_ADDR = {NB_ADDR},")
    verilog.append(f"  parameter integer NB_DATA = {NB_DATA}")
    verilog.append(f")(")
    verilog.append(f"  input  wire                 clk,")
    verilog.append(f"  input  wire                 rst_n,")
    verilog.append(f"  // SPI Slave Interface")
    verilog.append(f"  input  wire [NB_ADDR-1:0]   spi_addr,")
    verilog.append(f"  input  wire [NB_DATA-1:0]   spi_wdata,")
    verilog.append(f"  input  wire                 spi_wr_en,")
    verilog.append(f"  output reg  [NB_DATA-1:0]   spi_rdata,")
    # Dynamic Ports
    ports = []
    verilog.append(f"  // Probe Inputs")
    for name, _ in PROBE_LIST:
        ports.append(f"  input  wire [NB_DATA-1:0]   {name}")
    verilog.append("\n".join([p + "," for p in ports]))
    ctrl_ports = []
    verilog.append(f"  // Control Outputs")
    for name, _ in CONTROL_LIST:
        ctrl_ports.append(f"  output reg  [NB_DATA-1:0]   {name}")
    # Join control ports, careful with last comma
    if ctrl_ports:
        verilog.append("\n".join([p + "," for p in ctrl_ports[:-1]]))
        verilog.append(ctrl_ports[-1]) # No comma on last port
    else:
        # If no controls, remove last comma from probes
        if verilog[-3].endswith(","):
            verilog[-3] = verilog[-3][:-1]
    verilog.append(f");")
    verilog.append(f"")

    # Address Map
    verilog.append(f"// Address Map")
    for name, addr in PROBE_LIST:
        verilog.append(f"localparam [NB_ADDR-1:0] ADDR_{name.upper()} = 'h{addr:02X};")
    for name, addr in CONTROL_LIST:
        verilog.append(f"localparam [NB_ADDR-1:0] ADDR_{name.upper()} = 'h{addr:02X};")
    verilog.append(f"")

    # Write Logic
    verilog.append(f"always @(posedge clk or negedge rst_n) begin")
    verilog.append(f"  if (!rst_n) begin")
    for name, _ in CONTROL_LIST:
        verilog.append(f"    {name} <= {{NB_DATA{{1'b0}}}};")
    verilog.append(f"  end")
    verilog.append(f"  else begin")
    verilog.append(f"    if (spi_wr_en) begin")
    verilog.append(f"      case (spi_addr)")
    for name, _ in CONTROL_LIST:
        verilog.append(f"        ADDR_{name.upper()}: {name} <= spi_wdata;")
    verilog.append(f"      endcase")
    verilog.append(f"    end")
    verilog.append(f"  end")
    verilog.append(f"end")
    verilog.append(f"")
    # Read Logic
    verilog.append(f"always @(*) begin")
    verilog.append(f"  case (spi_addr)")
    verilog.append(f"    // Probes")
    for name, _ in PROBE_LIST:
        verilog.append(f"    ADDR_{name.upper()}: spi_rdata = {name};")
    verilog.append(f"    // Controls (Readback)")
    for name, _ in CONTROL_LIST:
        verilog.append(f"    ADDR_{name.upper()}: spi_rdata = {name};")
    verilog.append(f"    default:      spi_rdata = {{NB_DATA{{1'b0}}}};")
    verilog.append(f"  endcase")
    verilog.append(f"end")
    verilog.append(f"")
    verilog.append(f"endmodule")

    # Write to file
    with open(OUTPUT_FILE, "w") as f:
        f.write("\n".join(verilog))
    
    print(f"[SUCCESS] Generated {OUTPUT_FILE}")

if __name__ == "__main__":
    generate_rtl()
    
    print("-" * 40)
    print("USER GUIDE:")
    print("1. Modify PROBE_LIST array for inputs.")
    print("2. Modify CONTROL_LIST array for outputs.")
    print("3. Ensure addresses (hex) do not collide.")
    print("4. Run: python3 gen_debug_unit.py")
    print(f"5. Result: {OUTPUT_FILE} is ready.")
    print("-" * 40)


# Instructions:
# 1. Modify PROBE_LIST for inputs.
# 2. Modify CONTROL_LIST for outputs.
# 3. Ensure addresses (hex) dont collide.
# 4. Run the script.
# 5. A file called OUTPUT_FILE is saved.