`timescale 1ns / 1ps
module arithmetic_unit(
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
            // ��
            2'b00 : res_o = a_i + b_i;
            // ��
            2'b01 : res_o = a_i + (~b_i + 1'b1);
            default: res_o = 32'b0;
        endcase
    end
endmodule
