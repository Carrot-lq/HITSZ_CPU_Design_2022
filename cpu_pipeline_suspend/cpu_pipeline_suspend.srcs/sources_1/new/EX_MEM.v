`timescale 1ns / 1ps
module EX_MEM(
    input   wire        clk,
    input   wire        rst,
    // EX传至MEM的信号
    input   wire[31:0]  pc_i,
    output  reg[31:0]   pc_o,
    input   wire[31:0]  pc4_i,
    output  reg[31:0]   pc4_o,
    input   wire[4:0]   rf_wR_i,
    output  reg[4:0]    rf_wR_o,
    input   wire[1:0]   rf_wD_sel_i,
    output  reg[1:0]    rf_wD_sel_o,
    input   wire        rf_we_i,
    output  reg         rf_we_o,
    input   wire[31:0]  alu_res_i,
    output  reg[31:0]   alu_res_o,
    input   wire[31:0]  mem_wD_i,
    output  reg[31:0]   mem_wD_o,
    input   wire        mem_we_i,
    output  reg         mem_we_o,
    input   wire[2:0]   mem_data_sel_i,
    output  reg[2:0]    mem_data_sel_o
    );
    
    // pc
    always @(posedge clk or posedge rst) begin
        if(rst)
            pc_o <= 32'h0;
        else
            pc_o <= pc_i;
    end 
    
    // pc+4
    always @(posedge clk or posedge rst) begin
        if(rst)
            pc4_o <= 32'h0;
        else
            pc4_o <= pc4_i;
    end 
    
    // rf_wR
    always @(posedge clk or posedge rst) begin
        if(rst)
            rf_wR_o <= 4'h0;
        else
            rf_wR_o <= rf_wR_i;
    end 
    
    // rf_wD_sel
    always @(posedge clk or posedge rst) begin
        if(rst)
            rf_wD_sel_o <= 2'h0;
        else
            rf_wD_sel_o <= rf_wD_sel_i;
    end 
    
    // rf_we
    always @(posedge clk or posedge rst) begin
        if(rst)
            rf_we_o <= 1'b0;
        else
            rf_we_o <= rf_we_i;
    end
    
    // alu_res
    always @(posedge clk or posedge rst) begin
        if(rst)
            alu_res_o <= 32'h0;
        else
            alu_res_o <= alu_res_i;
    end
    
    // mem_wD
    always @(posedge clk or posedge rst) begin
        if(rst)
            mem_wD_o <= 32'h0;
        else
            mem_wD_o <= mem_wD_i;
    end
    
    // mem_we
    always @(posedge clk or posedge rst) begin
        if(rst)
            mem_we_o <= 1'b0;
        else
            mem_we_o <= mem_we_i;
    end
    
    //mem_data_sel
    always @(posedge clk or posedge rst) begin
        if(rst)
            mem_data_sel_o <= 3'h0;
        else
            mem_data_sel_o <= mem_data_sel_i;
    end
    
endmodule
