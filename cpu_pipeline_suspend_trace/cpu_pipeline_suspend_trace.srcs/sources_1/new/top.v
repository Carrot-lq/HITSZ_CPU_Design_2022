`timescale 1ns / 1ps
module top(
    input   wire        clk,                // ϵͳʱ��
    input   wire        rst_n,              // �첽�����źţ��͵�ƽ��Ч
    // for trace test
    output  wire        debug_wb_have_inst, // WB�׶��Ƿ���ָ�� (�Ե�����CPU����flag��Ϊ1)
    output  wire[31:0]  debug_wb_pc,        // WB�׶ε�PC (��wb_have_inst=0�������Ϊ����ֵ)
    output  wire        debug_wb_ena,       // WB�׶εļĴ���дʹ�� (��wb_have_inst=0�������Ϊ����ֵ)
    output  wire[4:0]   debug_wb_reg,       // WB�׶�д��ļĴ����� (��wb_ena��wb_have_inst=0�������Ϊ����ֵ)
    output  wire[31:0]  debug_wb_value      // WB�׶�д��Ĵ�����ֵ (��wb_ena��wb_have_inst=0�������Ϊ����ֵ)
);
    
//    wire    cpu_clk;        // ��Ƶ��ʱ��
//    cpu_clk_div u_cpu_clk_div(
//        .rst            (rst_i),
//        .clk_i          (clk_i),
//        .cpu_clk_o      (cpu_clk)
//    );
        
    wire[31:0]  mem_rD;
    wire[31:0]  mem_wD;
    wire[31:0]  mem_addr;
    wire        mem_we;
    wire[2:0]   mem_data_sel;
    
    // for trace test
    wire        rst = ~rst_n;       // �ߵ�ƽ��Ч�������ź�
    wire[31:0]  inst;               // 32λָ��    ��inst_mem���������cpu
    wire[31:0]  pc;                 // 32λpc����15:2��Ч    ��cpu���������inst_mem��trace����
    wire        debug_rf_we;        // regfile�Ĵ���дʹ�ܿ����ź�    ��cpu���������trace����
    wire[4:0]   debug_rf_wR;        // д��Ĵ�����5λ���    ��cpu���������trace����
    wire[31:0]  debug_rf_wD;        // д��Ĵ�����32λ����    ��cpu���������trace����
    wire[31:0]  mem_input_data;     // дdmem�����32λ����    ��cpu���������data_mem
    wire[31:0]  mem_output_data;    // ��dmem�����32λ����    ��cpu���������data_mem
    
    wire    flush;
    reg     flush_after_1_cycle;
    reg     flush_after_2_cycle;
    reg     flush_after_3_cycle;
    reg     flush_after_4_cycle;
    wire    suspend;
    reg     suspend_after_1_cycle;
    reg     suspend_after_2_cycle;
    reg     suspend_after_3_cycle;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            suspend_after_1_cycle <= 1'b0;
            suspend_after_2_cycle <= 1'b0;
            suspend_after_3_cycle <= 1'b0;
            flush_after_1_cycle <= 1'b0;
            flush_after_2_cycle <= 1'b0;
            flush_after_3_cycle <= 1'b0;
            flush_after_4_cycle <= 1'b0;
        end
        else begin
            suspend_after_1_cycle <= suspend;
            suspend_after_2_cycle <= suspend_after_1_cycle;        
            suspend_after_3_cycle <= suspend_after_2_cycle;
            flush_after_1_cycle <= flush;
            flush_after_2_cycle <= flush_after_1_cycle;
            flush_after_3_cycle <= flush_after_2_cycle;
            flush_after_4_cycle <= flush_after_3_cycle;        
        end
    end
    
    reg [2:0] cnt;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) cnt <= 3'h5;
        else if(cnt == 2'h0) cnt <= cnt;
        else cnt <= cnt - 1;
    end

    
    miniRV u_miniRV (
        .clk            (clk),
        .rst            (rst),
        .suspend_o      (suspend),
        .flush_o        (flush),
        .mem_rD_i       (mem_rD),
        .mem_addr_o     (mem_addr),
        .mem_wD_o       (mem_wD),
        .mem_we_o       (mem_we),
        .mem_data_sel_o (mem_data_sel),
        // for trace test
        .inst_i             (inst),
        .pc_o               (pc),
        .pc_wb_o            (debug_wb_pc),
        .debug_rf_we_o      (debug_rf_we),
        .debug_rf_wR_o      (debug_rf_wR),
        .debug_rf_wD_o      (debug_rf_wD)
    );

    // ���ݴ洢��Ԫ
    MEM u_MEM(
        .rst                (rst),
        .clk                (clk),
        .mem_addr_i         (mem_addr),
        .mem_wD_i           (mem_wD),
        .mem_we_i           (mem_we),
        .mem_data_sel_i     (mem_data_sel),
        .mem_data_o         (mem_rD),
        // for trace test
        .mem_input_data_o   (mem_input_data),
        .mem_output_data_i  (mem_output_data)
    );

    // ��������ģ�飬ֻ��Ҫʵ���������ߣ�����Ҫ����ļ�
    inst_mem imem(
        .a     (pc[15:2]),
        .spo   (inst)
    );
    
    data_mem dmem(
        .clk    (clk),
        .a      (mem_addr[15:2]),
        .spo    (mem_output_data),
        .we     (mem_we),
        .d      (mem_input_data)
    );
    
    // for trace test
    assign debug_wb_have_inst = (cnt == 2'h0) & ~flush_after_3_cycle & ~suspend_after_3_cycle & ~flush_after_4_cycle;
    assign debug_wb_ena = debug_rf_we;
    assign debug_wb_reg = debug_rf_wR;
    assign debug_wb_value = debug_rf_wD;
endmodule
