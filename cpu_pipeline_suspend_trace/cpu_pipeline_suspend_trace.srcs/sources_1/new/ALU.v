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
    // alu_opcode��[3:2]����ѡ��ͬ��Ԫ����������Ϊ�������
    // alu_opcode��[1:0]��Ϊѡ��ͬ��Ԫ�Ĳ�����
    // alu_opcode[4]����luiָ��ֱ�����alu_b
    
    wire [31:0] res_arithmetic;
    wire [31:0] res_compare;
    wire [31:0] res_logic;
    wire [31:0] res_shift;    
    // �������㵥Ԫ
    arithmetic_unit u_arithmetic_unit(
        .a_i        (alu_a_i),
        .b_i        (alu_b_i),
        .op_i       (alu_op_i[1:0]),
        .res_o      (res_arithmetic)
    );
    // �Ƚϲ�����Ԫ
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
    // ��֧���㵥Ԫ - B��ָ��
    branch_unit u_branch_unit(
        .a_i        (alu_a_i),
        .b_i        (alu_b_i),
        .op_i       (alu_op_i[3:0]),
        .branch     (branch_o)
    );
    
    // ����opcodeѡ��������
    always @(*) begin
        // luiָ�ֱ���������������alu_b����
        if(alu_op_i[4])
            alu_res_o = alu_b_i;
        else
            case(alu_op_i[3:2])
                ARITHMETIC :    alu_res_o = res_arithmetic;
                COMPARE :       alu_res_o = res_compare;
                LOGIC :         alu_res_o = res_logic;
                SHIFT :         alu_res_o = res_shift;
            endcase
    end
    
endmodule
