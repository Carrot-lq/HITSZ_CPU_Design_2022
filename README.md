# HITSZ_CPU_Design_2022

## TIPS

仅供参考，若发现不严谨之处请自行改善。

请注意新指导书与2022夏是否存在差异。

.asm文件和.hex为实验一汇编计算器代码，四个文件夹分别为CPU设计的四个vivado工程。

用于trace测试的代码与下板代码略有不同，测试所需信号已注释标明。

.v代码位于工程目录/.srcs/sources_1/new目录下

数据通路图与实验报告暂不提供，希望读者在研究代码的过程中自行总结。

## 工程结构

### single_trace

- top
  - cpu_clk_div（暂时不用）
  - miniRV
    - CTRL
    - IF
      - PC
      - NPC
      - prgrom（暂时不用）
    - ID
      - RF
      - SEXT
    - EX
      - ALU
        - arithmetic_unit
        - compare_unit
        - logic_unit
        - shift_unit
        - branch_unit
    - MEM
      - dram（暂时不用）
  - imem
  - dmem

### single

- top
  - cpu_clk_div
  - miniRV
    - CTRL
    - IF
      - PC
      - NPC
      - prgrom
    - ID
      - RF
      - SEXT
    - EX
      - ALU
        - arithmetic_unit
        - compare_unit
        - logic_unit
        - shift_unit
        - branch_unit
  - IO_Bus
    - led_driver
      - led_clk_div
    - mem
      - dram

### pipeline_suspend_trace

- top
  - cpu_clk_div（暂时不用）
  - miniRV
    - CTRL
    - IF
      - PC
      - prgrom（暂时不用）
    - IF_ID
    - ID
      - RF
      - SEXT
    - ID_EX
    - EX
      - ALU
        - arithmetic_unit
        - compare_unit
        - logic_unit
        - shift_unit
        - branch_unit
      - NPC
    - EX_MEM
    - MEM_WB
    - data_hazard_detect
  - MEM
    - dram（暂时不用）
  - imem
  - dmem

### pipeline_suspend

- top
  - cpu_clk_div
  - miniRV
    - CTRL
    - IF
      - PC
      - prgrom
    - IF_ID
    - ID
      - RF
      - SEXT
    - ID_EX
    - EX
      - ALU
        - arithmetic_unit
        - compare_unit
        - logic_unit
        - shift_unit
        - branch_unit
      - NPC
    - EX_MEM
    - MEM_WB
    - data_hazard_detect
  - IO_Bus
    - led_driver
      - led_clk_div
    - mem
      - dram

## 指导书

https://hitsz-cslab.gitee.io/cpu/

## 实验包

https://gitee.com/hitsz-cslab/cpu/tree/master/stupkt
