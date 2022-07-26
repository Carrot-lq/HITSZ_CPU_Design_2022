`timescale 1ns / 1ps
module RF(
    input   wire        rst,
    input   wire        clk,
    // ���Ĵ�����
    input   wire[4:0]   rR1_i,
    input   wire[4:0]   rR2_i,
    // д�Ĵ�����
    input   wire[4:0]   wR_i,
    // д����
    input   wire[31:0]  wD_i,
    // д�����ź�
    input   wire        we_i,
    // ������
    output  wire[31:0]  rD1_o,
    output  wire[31:0]  rD2_o
    );
    
    reg[31:0]    regs[0:31];
    
    always @(posedge clk) begin
        if(we_i) begin
            if(wR_i != 5'b0) begin
                regs[wR_i] <= wD_i;
            end
        end
    end
    
    assign rD1_o = (rR1_i == 5'b0) ? 32'h0 : regs[rR1_i];
    assign rD2_o = (rR2_i == 5'b0) ? 32'h0 : regs[rR2_i];

endmodule
