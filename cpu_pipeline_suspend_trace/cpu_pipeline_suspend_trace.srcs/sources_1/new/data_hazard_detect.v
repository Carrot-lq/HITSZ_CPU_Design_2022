`timescale 1ns / 1ps
module data_hazard_detect(
    input   wire        clk,
    input   wire        rst,
    input   wire[4:0]   rf_rR1_id_ex_i,
    input   wire[4:0]   rf_rR2_id_ex_i,
    input   wire[4:0]   rf_wR_ex_mem_i,
    input   wire[4:0]   rf_wR_mem_wb_i,
    input   wire[4:0]   rf_wR_wb_i, 
    input   wire        ctrl_detect_r1,
    input   wire        ctrl_detect_r2,
    output  wire        suspend_o
    );
    
    wire rf_rR1_id_ex_hazard  = (rf_rR1_id_ex_i == rf_wR_ex_mem_i) ?  (rf_wR_ex_mem_i != 5'h0) : 1'b0;
    wire rf_rR2_id_ex_hazard  = (rf_rR2_id_ex_i == rf_wR_ex_mem_i) ?  (rf_wR_ex_mem_i != 5'h0) : 1'b0;
    wire rf_rR1_id_mem_hazard = (rf_rR1_id_ex_i == rf_wR_mem_wb_i)  ? (rf_wR_mem_wb_i  != 5'h0) : 1'b0;
    wire rf_rR2_id_mem_hazard = (rf_rR2_id_ex_i == rf_wR_mem_wb_i)  ? (rf_wR_mem_wb_i  != 5'h0) : 1'b0;
    wire rf_rR1_id_wb_hazard  = (rf_rR1_id_ex_i == rf_wR_wb_i) ? (rf_wR_wb_i != 5'h0) : 1'b0;
    wire rf_rR2_id_wb_hazard  = (rf_rR2_id_ex_i == rf_wR_wb_i) ? (rf_wR_wb_i != 5'h0) : 1'b0;
    wire suspend_r1 = (rf_rR1_id_ex_hazard | rf_rR1_id_mem_hazard | rf_rR1_id_wb_hazard) & ctrl_detect_r1;
    wire suspend_r2 = (rf_rR2_id_ex_hazard | rf_rR2_id_mem_hazard | rf_rR2_id_wb_hazard) & ctrl_detect_r2;
    assign suspend_o = suspend_r1 | suspend_r2;
    
endmodule
