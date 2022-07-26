`timescale 1ns / 1ps
module miniRV(
    input   wire        clk,
    input   wire        rst,
    // for trace test
    input   wire[31:0]  inst_i,             // �ⲿ����inst���滻IF�����inst
    output  wire[31:0]  pc_o,               // ��pc���
    output  wire        mem_we_o,           // ��mem_we���
    output  wire[31:0]  mem_addr_o,         // S��ָ���������ַ rs1+offset ��ALU��������
    output  wire[31:0]  mem_input_data_o,   // MEM�н�����������������
    input   wire[31:0]  mem_output_data_i,  // �ⲿ�������ݣ��滻MEM�������������
    output  wire        debug_rf_we_o,      // ID�н�дʹ��rf_we���
    output  wire[4:0]   debug_rf_wR_o,      // ID�н�д�Ĵ��������
    output  wire[31:0]  debug_rf_wD_o       // ID�н�д�������
    );
    
    wire[31:0]  pc;             // ��ǰpcֵ ����B��ָ�����ǰpcֵ����ALU       ��IF���������EX
    wire[31:0]  pc4;            // pc+4������jal,jalr�洢pc+4���Ĵ���            ��IF���������ID
    wire[31:0]  inst;           // ��imem������ָ��                              ��IF���������ID��CTRL
    wire[31:0]  sext;           // ������չ�����������     ��ID���������IF��EX
    wire[31:0]  rf_rD1;         // �Ĵ�������������1        ��ID���������IF��EX
    wire[31:0]  rf_rD2;         // �Ĵ�������������2        ��ID���������IF��EX
    wire[31:0]  alu_res;        // alu������              ��EX���������ID��MEM
    wire[31:0]  mem_rD;         // �洢��������             ��MEM���������ID  
    
    wire        branch_ctrl;    // ����CTRL����ת�����ź�
    wire        branch_ex;      // ����alu����ת�����ź�
    wire        branch;         // ��ת�����ź� ����IF
    assign branch = branch_ctrl & branch_ex;
    wire[1:0]   pc_sel;         // pcѡ���ź�   ��CTRL���������IF
    wire[2:0]   sext_sel;       // ������������չѡ���ź�   ��CTRL���������ID
    wire[1:0]   rf_wD_sel;      // �Ĵ���д����ѡ���ź�     ��CTRL���������ID
    wire        rf_we;          // �Ĵ���дʹ�ܿ���         ��CTRL���������ID
    wire[4:0]   alu_op;         // ALU������           ��CTRL���������EX
    wire        A_sel;          // ALU����1ѡ���ź�    ��CTRL���������EX
    wire        B_sel;          // ALU����2ѡ���ź�    ��CTRL���������EX
    wire[2:0]   mem_data_sel;   // dmem����ѡ���ź�    ��CTRL���������MEM
    wire        mem_we;         // dmemдʹ�ܿ����ź�  ��CTRL���������MEM
    
    // ���Ƶ�Ԫ
    CTRL u_CTRL(
        .rst            (rst),
        .op_i           (inst[6:0]),
        .func7_i        (inst[31:25]),
        .func3_i        (inst[14:12]),
        .pc_sel_o       (pc_sel),
        .branch_ctrl_o  (branch_ctrl),
        .sext_sel_o     (sext_sel),
        .rf_wD_sel_o    (rf_wD_sel),
        .rf_we_o        (rf_we),
        .alu_op_o       (alu_op),
        .A_sel_o        (A_sel),
        .B_sel_o        (B_sel),
        .mem_data_sel_o (mem_data_sel),
        .mem_we_o       (mem_we)
    );
    
    // ȡֵ��Ԫ
    IF u_IF(
        .rst            (rst),
        .clk            (clk),
        .sext_i         (sext),
        .rf_rD_i        (rf_rD1),
        .pc_sel_i       (pc_sel),
        .branch_i       (branch),
        .inst_o         (inst),
        .pc4_o          (pc4),
        .pc_o           (pc),
        // for trace test
        .outer_inst_i   (inst_i)
    );
    
    // ���뵥Ԫ
    ID u_ID(
        .rst            (rst),
        .clk            (clk),
        .sext_sel_i     (sext_sel),
        .rf_wD_sel_i    (rf_wD_sel),
        .rf_we_i        (rf_we),
        .inst_i         (inst),
        .pc4_i          (pc4),
        .alu_res_i      (alu_res),
        .mem_rD_i       (mem_rD),        
        .sext_o         (sext),
        .rf_rD1_o       (rf_rD1),
        .rf_rD2_o       (rf_rD2),
        // for trace test
        .debug_rf_we_o  (debug_rf_we_o),
        .debug_rf_wR_o  (debug_rf_wR_o),
        .debug_rf_wD_o  (debug_rf_wD_o)
    );
    
    // ���㵥Ԫ
    EX u_EX(
        .pc_i           (pc),
        .rf_rD1_i       (rf_rD1),
        .rf_rD2_i       (rf_rD2),
        .sext_i         (sext),
        .A_sel_i        (A_sel),
        .B_sel_i        (B_sel),
        .alu_op_i       (alu_op),
        .alu_res_o      (alu_res),
        .alu_branch_o   (branch_ex)
    );
    
    // ���ݴ洢��Ԫ
    MEM u_MEM(
        .rst                (rst),
        .clk                (clk),
        .mem_addr_i         (alu_res),
        .mem_wD_i           (rf_rD2),
        .mem_we_i           (mem_we),
        .mem_data_sel_i     (mem_data_sel),
        .mem_rD_o           (mem_rD),
        // for trace test
        .mem_input_data_o   (mem_input_data_o),
        .mem_output_data_i  (mem_output_data_i)
    );
    
    // for trace test
    assign pc_o = pc;               // ��ǰpc
    assign mem_addr_o = alu_res;    // S��ָ���������ַ rs1+offset ��ALU��������
    assign mem_we_o = mem_we;       // ��ǰmem_we
    
endmodule
