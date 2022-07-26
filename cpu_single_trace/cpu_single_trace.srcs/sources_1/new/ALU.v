`timescale 1ns / 1ps
module ALU#(
    parameter ARITHMETIC   = 2'b00,
    parameter COMPARE      = 2'b01,
    parameter LOGIC        = 2'b10,
    parameter SHIFT        = 2'b11
)
(
    // �����ź�
    input   wire[4:0]   alu_op_i,
    // ��������
    input   wire[31:0]  alu_a_i,
    input   wire[31:0]  alu_b_i,
    // �������
    output  reg[31:0]   alu_res_o,
    // �����֧����
    output  wire        branch_o
    );
    // alu_op��[3:2]ѡ��ͬ��Ԫ��00��Ӧ��������(�Ӽ�)��01��Ӧ�Ƚ����㣬10��Ӧ�߼����㣬11��Ӧ��λ����
    // alu_op��[1:0]ѡ��ͬ����
    // alu_op[4]ר������luiָ�alu���ֱ�����alu_b
    
    wire [31:0] res_arithmetic;
    wire [31:0] res_compare;
    wire [31:0] res_logic;
    wire [31:0] res_shift;
    
    // ѡ��alu������
    always @(*) begin
        // luiָ�ֱ�����������alu_b
        if(alu_op_i[4])
            alu_res_o = alu_b_i;
        // ����ָ�����op[3:2]ѡ��
        else
            case(alu_op_i[3:2])
                ARITHMETIC :    alu_res_o = res_arithmetic;
                COMPARE :       alu_res_o = res_compare;
                LOGIC :         alu_res_o = res_logic;
                SHIFT :         alu_res_o = res_shift;
            endcase
    end
    
    // �������㵥Ԫ
    arithmetic_unit u_arithmetic_unit(
        .a_i        (alu_a_i),
        .b_i        (alu_b_i),
        .op_i       (alu_op_i[1:0]),   
        .res_o      (res_arithmetic)
    );
    
    // �Ƚ����㵥Ԫ
    compare_unit u_compare_unit(
        .a_i        (alu_a_i),
        .b_i        (alu_b_i),
        .op_i       (alu_op_i[1:0]),
        .res_o      (res_compare)
    );
    
    // �߼����㵥Ԫ
    logic_unit u_logic_unit(
        .a_i        (alu_a_i),
        .b_i        (alu_b_i),
        .op_i       (alu_op_i[1:0]),
        .res_o      (res_logic)
    );
    
    // ��λ���㵥Ԫ
    shift_unit u_shift_unit(
        .a_i        (alu_a_i),
        .b_i        (alu_b_i),
        .op_i       (alu_op_i[1:0]),
        .res_o      (res_shift)
    );
    
    // ��֧��Ԫ
    branch_unit u_branch_unit(
        .a_i        (alu_a_i),
        .b_i        (alu_b_i),
        .op_i       (alu_op_i[3:0]),
        .branch_o   (branch_o)
    );
    
endmodule