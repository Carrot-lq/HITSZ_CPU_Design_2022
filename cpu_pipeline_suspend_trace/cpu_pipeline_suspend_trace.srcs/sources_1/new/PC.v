`timescale 1ns / 1ps
module PC(
    input   wire        rst,    // ��λ
    input   wire        clk,    // ʱ��
    input   wire        data_suspend_i,
    input   wire        flush_i,
    input   wire[31:0]  npc_i,  // ��һ��ָ���ַ
    output  reg[31:0]   pc_o    // �����ǰָ��
    );
    
    // �����������һ��ָ���ַ
    always@(posedge clk or posedge rst)begin
        if(rst) begin
            pc_o <= 32'hfffffffc;
        end else if(flush_i) begin
            pc_o <= npc_i;
        end else if(data_suspend_i) begin
            pc_o <= pc_o;
        end else begin
            pc_o <= pc_o + 4;
        end
    end
endmodule
