`timescale 1ns / 1ps
module SEXT#(
    parameter R          = 3'b000,
    parameter I_nonshift = 3'b001, 
    parameter I_shift    = 3'b010,
    parameter S          = 3'b011, 
    parameter B          = 3'b100,
    parameter U          = 3'b101,
    parameter J          = 3'b110  
)(
    input   wire        rst,
    // 选择信号
    input   wire[2:0]   sext_sel_i,
    // 输入
    input   wire[31:0]  inst_i,
    output  reg[31:0]   sext_o
    );
    always@(*) begin
        if(rst)
            sext_o = 32'h0;
        else begin
            case(sext_sel_i)
                // R型指令
                R: sext_o = 32'h0;
                // I型指令非移位
                I_nonshift: sext_o = {{20{inst_i[31]}}, inst_i[31:20]};
                // I型指令移位
                I_shift: sext_o = {{27{inst_i[24]}}, inst_i[24:20]};
                // S型指令
                S: sext_o = {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
                // B型指令
                B: sext_o = {{19{inst_i[31]}}, inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                // U型
                U: sext_o = {inst_i[31:12], 12'b0};
                // J型
                J: sext_o = {{10{inst_i[31]}}, inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
                default: sext_o = 32'h0;
            endcase
        end
    end
endmodule
