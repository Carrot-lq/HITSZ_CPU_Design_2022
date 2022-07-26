`timescale 1ns / 1ps
module branch_unit#(
    parameter BEQ       = 3'b000,
    parameter BNE       = 3'b001,
    parameter BLTU      = 3'b010,
    parameter BLT       = 3'b011,
    parameter BGEU      = 3'b100,
    parameter BGE       = 3'b101
)
(
    // 输入数据
    input   wire[31:0]  a_i,
    input   wire[31:0]  b_i,
    // 控制信号
    input   wire[3:0]   op_i,
    // 输出分支控制信号
    output  reg         branch_o
    );
    
    wire[31:0]  tmp;
    assign tmp = a_i - b_i;
    
    always @(*) begin
        case(op_i)
            BEQ:    branch_o = (tmp == 32'h0) ? 1'b1 : 1'b0;
            BNE:    branch_o = (tmp == 32'h0) ? 1'b0 : 1'b1;
            BLTU:   branch_o = (a_i < b_i) ? 1'b1 : 1'b0;
            BLT:    begin
                if(a_i[31] ^ b_i[31])
                    branch_o = a_i[31];
                else
                    branch_o = (tmp[31] == 1'b1) ? 1'b1 : 1'b0;
            end   
            BGEU:   branch_o = (a_i < b_i) ? 1'b0 : 1'b1;
            BGE:    begin
                if(a_i[31] ^ b_i[31])
                    branch_o = b_i[31];
                else
                    branch_o = (tmp[31] == 1'b1) ? 1'b0 : 1'b1;
            end
            default:branch_o = 1'b0;
        endcase
    end
endmodule