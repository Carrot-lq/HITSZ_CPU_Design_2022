set_property SRC_FILE_INFO {cfile:c:/Users/12644/Desktop/cpu_design/cpu_design.srcs/sources_1/ip/cpu_clk_div/cpu_clk_div.xdc rfile:../../../cpu_design.srcs/sources_1/ip/cpu_clk_div/cpu_clk_div.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
current_instance inst
set_property src_info {type:SCOPED_XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in1]] 0.1
