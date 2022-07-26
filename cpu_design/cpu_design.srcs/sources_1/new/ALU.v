`timescale 1ns / 1ps
module ALU#(
    parameter ARITHMETIC   = 2'b00,
    parameter COMPARE      = 2'b01,
    parameter LOGIC        = 2'b10,
    parameter SHIFT        = 2'b11
)
(
    // 控制信号
    input   wire[4:0]   alu_op_i,
    // 输入数据
    input   wire[31:0]  alu_a_i,
    input   wire[31:0]  alu_b_i,
    // 输出数据
    output  reg[31:0]   alu_res_o,
    // 输出分支控制
    output  wire        branch_o
    );
    // alu_op的[3:2]选择不同单元，00对应算术运算(加减)，01对应比较运算，10对应逻辑运算，11对应移位运算
    // alu_op的[1:0]选择不同操作
    // alu_op[4]专门用于lui指令，alu结果直接输出alu_b
    
    wire [31:0] res_arithmetic;
    wire [31:0] res_compare;
    wire [31:0] res_logic;
    wire [31:0] res_shift;
    
    // 选择alu输出结果
    always @(*) begin
        // lui指令，直接输出立即数alu_b
        if(alu_op_i[4])
            alu_res_o = alu_b_i;
        // 其他指令根据op[3:2]选择
        else
            case(alu_op_i[3:2])
                ARITHMETIC :    alu_res_o = res_arithmetic;
                COMPARE :       alu_res_o = res_compare;
                LOGIC :         alu_res_o = res_logic;
                SHIFT :         alu_res_o = res_shift;
            endcase
    end
    
    // 算数运算单元
    arithmetic_unit u_arithmetic_unit(
        .a_i        (alu_a_i),
        .b_i        (alu_b_i),
        .op_i       (alu_op_i[1:0]),   
        .res_o      (res_arithmetic)
    );
    
    // 比较运算单元
    compare_unit u_compare_unit(
        .a_i        (alu_a_i),
        .b_i        (alu_b_i),
        .op_i       (alu_op_i[1:0]),
        .res_o      (res_compare)
    );
    
    // 逻辑运算单元
    logic_unit u_logic_unit(
        .a_i        (alu_a_i),
        .b_i        (alu_b_i),
        .op_i       (alu_op_i[1:0]),
        .res_o      (res_logic)
    );
    
    // 移位运算单元
    shift_unit u_shift_unit(
        .a_i        (alu_a_i),
        .b_i        (alu_b_i),
        .op_i       (alu_op_i[1:0]),
        .res_o      (res_shift)
    );
    
    // 分支单元
    branch_unit u_branch_unit(
        .a_i        (alu_a_i),
        .b_i        (alu_b_i),
        .op_i       (alu_op_i[3:0]),
        .branch_o   (branch_o)
    );
    
endmodule