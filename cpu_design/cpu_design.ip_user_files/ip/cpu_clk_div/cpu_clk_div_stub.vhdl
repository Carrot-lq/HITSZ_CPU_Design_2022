-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
-- Date        : Fri Jul 22 15:55:17 2022
-- Host        : luoboLaptopYoga14s running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/Users/12644/Desktop/cpu_design/cpu_design.srcs/sources_1/ip/cpu_clk_div/cpu_clk_div_stub.vhdl
-- Design      : cpu_clk_div
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tfgg484-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cpu_clk_div is
  Port ( 
    clk_out1 : out STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );

end cpu_clk_div;

architecture stub of cpu_clk_div is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_out1,locked,clk_in1";
begin
end;