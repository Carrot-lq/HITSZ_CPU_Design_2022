`timescale 1ns / 1ps
module NPC(
    input   wire        rst,
    // �����ź�
    input   wire[31:0]  pc_i,       // ��ǰpc
    input   wire[31:0]  sext_i,     // ������ƫ����
    input   wire[31:0]  rf_rD_i,    // jalr �Ĵ���ֵ
    // �����ź�
    input   wire        branch_i,   // ��ת�ź�
    input   wire[1:0]   pc_sel_i,   // pcѡ���ź�
    // ����ź�
    output  reg[31:0]   npc_o       // ��һ��ָ���ַ
    );
    
    // npc_o���������һ��ָ���ַ
    always @(*) begin
        if(rst)
            npc_o = pc_i;
        else begin
            case (pc_sel_i)
                // pc+4
                2'b00: npc_o = pc_i + 3'h4;
                // branch
                2'b01: npc_o = (branch_i == 1'b1) ? (pc_i + sext_i) : (pc_i + 4);
                // jal
                2'b10: npc_o = pc_i + sext_i;
                // jalr
                2'b11: npc_o = (rf_rD_i + sext_i) & (32'hFFFE);
                default: 
                    npc_o = 32'b0;
            endcase 
        end      
    end
    
endmodule
