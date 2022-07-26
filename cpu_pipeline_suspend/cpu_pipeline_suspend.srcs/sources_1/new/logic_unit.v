`timescale 1ns / 1ps
module logic_unit#(
    parameter AND   = 2'b00,
    parameter OR    = 2'b01,
    parameter XOR   = 2'b10
)(
    // ��������
    input   wire[31:0]  a_i,
    input   wire[31:0]  b_i,
    // �����ź�
    input   wire[1:0]   op_i,
    // �������
    output  reg[31:0]   res_o
    );
    
    always @(*) begin
        case(op_i)
            AND:     res_o = a_i & b_i;
            OR:      res_o = a_i | b_i;
            XOR:     res_o = a_i ^ b_i;
            default: res_o = 32'h0;
        endcase
    end
endmodule
