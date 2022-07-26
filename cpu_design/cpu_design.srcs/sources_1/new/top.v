`timescale 1ns / 1ps
module top(
    input   wire    clk_i,      // ϵͳʱ��   
    input   wire    rst_i,      // �첽�����źţ��ߵ�ƽ��Ч
    // �����
    output  wire    led0_en_o,
    output  wire    led1_en_o,
    output  wire    led2_en_o,
    output  wire    led3_en_o,
    output  wire    led4_en_o,
    output  wire    led5_en_o,
    output  wire    led6_en_o,
    output  wire    led7_en_o,
    output  wire    led_ca_o,
    output  wire    led_cb_o,
    output  wire    led_cc_o,
    output  wire    led_cd_o,
    output  wire    led_ce_o,
    output  wire    led_cf_o,
    output  wire    led_cg_o,
    output  wire    led_dp_o,
    // ���뿪��
    input   wire[23:0]  switch_i,
    // led��
    output  wire[23:0]  led_o
);
    // �����ʹ���ź�
    wire[7:0]   led_en;
    assign led0_en_o = led_en[0];
    assign led1_en_o = led_en[1];
    assign led2_en_o = led_en[2];
    assign led3_en_o = led_en[3];
    assign led4_en_o = led_en[4];
    assign led5_en_o = led_en[5];
    assign led6_en_o = led_en[6];
    assign led7_en_o = led_en[7];
    
    // ʱ�ӷ�Ƶ�����ʱ��cpu_clkΪ25MHz
    wire    cpu_clk;
    cpu_clk_div u_cpu_clk_div(
        .locked         (1'b1),
        .clk_in1        (clk_i),
        .clk_out1       (cpu_clk)
    );
    
    
    wire[31:0]  mem_rD;         // ������
    wire[31:0]  mem_wD;         // д����
    wire[31:0]  mem_addr;       // ��д��ַ
    wire        mem_we;         // дʹ���ź�
    wire[2:0]   mem_data_sel;   // mem����ѡ���ź�
    
    miniRV u_miniRV (
        .clk            (cpu_clk),
        .rst            (rst_i),
        .mem_rD_i       (mem_rD),
        .mem_addr_o     (mem_addr),
        .mem_wD_o       (mem_wD),
        .mem_we_o       (mem_we),
        .mem_data_sel_o (mem_data_sel)
    );
    
    // ������
    IO_Bus u_IO_Bus(
        .clk            (cpu_clk),
        .rst            (rst_i),
        .addr_i         (mem_addr),
        .wdata_i        (mem_wD),
        .rdata_o        (mem_rD),
        .mem_we_i       (mem_we),
        .mem_data_sel_i (mem_data_sel),
        .led_en_o       (led_en),
        .led_ca_o       (led_ca_o), 
        .led_cb_o       (led_cb_o), 
        .led_cc_o       (led_cc_o), 
        .led_cd_o       (led_cd_o), 
        .led_ce_o       (led_ce_o), 
        .led_cf_o       (led_cf_o), 
        .led_cg_o       (led_cg_o), 
        .led_dp_o       (led_dp_o),
        .switch_i       (switch_i),
        .led_o          (led_o)
    );
    
endmodule
