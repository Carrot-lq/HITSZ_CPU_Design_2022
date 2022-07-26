`timescale 1ns / 1ps
module PC(
    input   wire        rst,
    input   wire        clk,
    input   wire[31:0]  pc_i,   // 下一条指令地址
    output  reg[31:0]   pc_o    // 输出当前指令
    );
    
    // 时序输出下一条指令地址
    always@(posedge clk or posedge rst)begin
        if(rst) begin
            pc_o <= 32'hfffffffc;
        end else begin
            pc_o <= pc_i;
        end
    end
endmodule
