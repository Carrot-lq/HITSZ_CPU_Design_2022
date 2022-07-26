`timescale 1ns / 1ps
module miniRV(
    input   wire        clk,
    input   wire        rst,
    input   wire[31:0]  mem_rD_i,       // mem����������
    output  wire[31:0]  mem_addr_o,     // mem��д��ַ
    output  wire[31:0]  mem_wD_o,       // memд�������
    output  wire        mem_we_o,       // memдʹ���ź�
    output  wire[2:0]   mem_data_sel_o  // memѡ���ź�
    );
    
    wire[31:0]  pc;             // ��ǰpcֵ ����B��ָ�����ǰpcֵ����ALU       ��IF���������EX
    wire[31:0]  pc4;            // pc+4������jal,jalr�洢pc+4���Ĵ���            ��IF���������ID
    wire[31:0]  inst;           // ��imem������ָ��                              ��IF���������ID��CTRL
    wire[31:0]  sext;           // ������չ�����������     ��ID���������IF��EX
    wire[31:0]  rD1;            // �Ĵ�������������1        ��ID���������IF��EX
    wire[31:0]  rD2;            // �Ĵ�������������2        ��ID���������IF��EX
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
    wire[4:0]   alu_op;         // ALU������          ��CTRL���������EX
    wire        A_sel;          // ALU����1ѡ���ź�   ��CTRL���������EX
    wire        B_sel;          // ALU����2ѡ���ź�   ��CTRL���������EX

    assign mem_addr_o = alu_res;
    assign mem_wD_o = rD2;
    
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
        .mem_data_sel_o (mem_data_sel_o),
        .mem_we_o       (mem_we_o)
    );
    // ȡֵ��Ԫ
    IF u_IF(
        .rst            (rst),
        .clk            (clk),
        .sext_i         (sext),
        .rD_i           (rD1),
        .pc_sel_i       (pc_sel),
        .branch_i       (branch),
        .inst_o         (inst),
        .pc4_o          (pc4),
        .pc_o           (pc)
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
        .mem_rD_i       (mem_rD_i),        
        .sext_o         (sext),
        .rD1_o          (rD1),
        .rD2_o          (rD2)
    );
    
    // ���㵥Ԫ
    EX u_EX(
        .pc_i           (pc),
        .rD1_i          (rD1),
        .rD2_i          (rD2),
        .sext_i         (sext),
        .A_sel_i        (A_sel),
        .B_sel_i        (B_sel),
        .alu_op_i       (alu_op),
        .alu_res_o      (alu_res),
        .alu_branch_o   (branch_ex)
    );
    
endmodule
