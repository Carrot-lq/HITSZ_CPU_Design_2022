onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+cpu_clk_div -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.cpu_clk_div xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {cpu_clk_div.udo}

run -all

endsim

quit -force
