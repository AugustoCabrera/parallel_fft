##################################################################
# GENERAL
##################################################################
set ::env(DESIGN_NAME) "overlap_save"
set ::env(PDK) "sky130A"
set ::env(VERILOG_FILES) [glob 	~/Documents/Maestria/UNIC-CASS-Aug25/src/rtl/overlap_save/*.v]
set ::env(CLOCK_PERIOD) 10
set ::env(CLOCK_PORT) "i_clk"
#set ::env(CLOCK_NET) "clk"
#set ::env(DESIGN_IS_CORE) 0
set ::env(LEC_ENABLE) 1

set ::env(GPL_CELL_PADDING) 4
set ::env(PL_CELL_PADDING) 4

##################################################################
# LINTING
##################################################################
set ::env(RUN_LINTER) 0
set ::env(QUIT_ON_LINTER_WARNINGS) 0
set ::env(QUIT_ON_LINTER_ERRORS) 0

##################################################################
# SYNSTHESIS
##################################################################
set ::env(SYNTH_CLOCK_UNCERTAINTY) 0.25
set ::env(SYNTH_CLOCK_UNCERTAINTY) 0.15
# DELAY/AREA 0-4/0-3
#set ::env(SYNTH_STRATEGY) "DELAY 3"
set ::env(SYNTH_NO_FLAT) 0
set ::env(SYNTH_SHARE_RESOURCES) 1
# YOSYS/FA/RCA/CSA carry select adder
set ::env(SYNTH_ADDER_TYPE) "YOSYS"
set ::env(BASE_SDC_FILE) [glob $::env(DESIGN_DIR)/overlap_save.sdc]
set ::env(SYNTH_FLAT_TOP) 0
set ::env(SYNTH_USE_PG_PINS_DEFINES) "USE_POWER_PINS"
set ::env(QUIT_ON_TIMING_VIOLATIONS) 1
set ::env(QUIT_ON_SETUP_VIOLATIONS) 1
set ::env(QUIT_ON_HOLD_VIOLATIONS) 1

set ::env(GRT_REPAIR_ANTENNAS) 1
set ::env(DIODE_INSERTION_STRATEGY) 4
set ::env(DIODE_CELL) "sky130_fd_sc_hd__diode_2/DIODE"

set ::env(RUN_PORT_DIODE_INSERTION) 0

##################################################################
# FLOORPLAN
##################################################################
set ::env(RUN_TAP_DECAP_INSERTION) 1
set ::env(FP_CORE_UTIL) 30
set ::env(FP_ASPECT_RATIO) 1
#set ::env(FP_SIZING) "relative"
set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) "0 0 1400 1400"
set ::env(VDD_NETS) "vccd1"
set ::env(GND_NETS) "vssd1"
set ::env(SYNTH_USE_PG_PINS_DEFINES) "USE_POWER_PINS"
set ::env(FP_PIN_ORDER_CFG) [glob ~/Documents/Maestria/UNIC-CASS-Aug25/src/rtl/overlap_save/pin_order.cfg]
set ::env(FP_PDN_CORE_RING) 0
set ::env(FP_PDN_MULTILAYER) 0
set ::env(RT_MAX_LAYER) "met5"
set ::env(FP_PDN_SKIPTRIM) 0
set ::env(FP_PDN_ENABLE_RAILS) 1
#set ::env(FP_PDN_CORE_RING_VWIDTH) 3.1
#set ::env(FP_PDN_CORE_RING_HWIDTH) 3.1
#set ::env(FP_PDN_CORE_RING_VOFFSET) 12.45
#set ::env(FP_PDN_CORE_RING_HOFFSET) 12.45
#set ::env(FP_PDN_CORE_RING_VSPACING) 1.7
#set ::env(FP_PDN_CORE_RING_HSPACING) 1.7
#set ::env(FP_PDN_VWIDTH) 3.1
#set ::env(FP_PDN_HWIDTH) 3.1
#set ::env(FP_PDN_VSPACING) [expr::(5 * $FP_PDN_CORE_RING_VWIDTH)]
#set ::env(FP_PDN_HSPACING) [expr::(5 * $FP_PDN_CORE_RING_HWIDTH)]
#set ::env(FP_PDN_VPITCH) 180
#set ::env(FP_PDN_HPITCH) 180
#set ::env(FP_PDN_VOFFSET) 5
#set ::env(FP_PDN_HOFFSET) 5

##################################################################
# PLACEMENT
##################################################################
set ::env(PL_TARGET_DENSITY) 0.55 
set ::env(PL_BASIC_PLACEMENT) 0
set ::env(PL_RESIZER_BUFFER_INPUT_PORTS) 1
set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) 1
set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 1
set ::env(GLB_RESIZER_DESIGN_OPTIMIZATIONS) 1
set ::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) 1
set ::env(RUN_CTS) 1 
set ::env(RUN_FILL_INSERTION) 1 

##################################################################
# ROUTING
##################################################################
set ::env(ROUTING_CORES) 4  
set ::env(GRT_ALLOW_CONGESTION) 1  
set ::env(DRT_OPT_ITERS) 20  

##################################################################
# SIGNOFF
##################################################################
set ::env(RUN_CVC) 1   
set ::env(RUN_IRDROP_REPORT) 1
