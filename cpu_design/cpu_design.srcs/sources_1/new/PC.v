`timescale 1ns / 1ps
module PC(
    input   wire        rst,
    input   wire        clk,
    input   wire[31:0]  pc_i,   // ��һ��ָ���ַ
    output  reg[31:0]   pc_o    // �����ǰָ��
    );
    
    // ʱ�������һ��ָ���ַ
    always@(posedge clk or posedge rst)begin
        if(rst) begin
            pc_o <= 32'hfffffffc;
        end else begin
            pc_o <= pc_i;
        end
    end
endmodule
