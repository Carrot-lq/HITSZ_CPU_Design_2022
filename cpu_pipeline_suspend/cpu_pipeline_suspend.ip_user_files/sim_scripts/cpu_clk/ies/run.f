-makelib ies_lib/xil_defaultlib -sv \
  "C:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
-endlib
-makelib ies_lib/xpm \
  "C:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../cpu_pipeline_suspend.srcs/sources_1/ip/cpu_clk/cpu_clk_clk_wiz.v" \
  "../../../../cpu_pipeline_suspend.srcs/sources_1/ip/cpu_clk/cpu_clk.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

