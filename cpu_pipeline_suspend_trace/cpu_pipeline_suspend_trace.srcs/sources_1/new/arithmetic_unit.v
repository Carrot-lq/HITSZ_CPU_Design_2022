`timescale 1ns / 1ps
module arithmetic_unit(
    // 输入数据
    input   wire[31:0]  a_i,
    input   wire[31:0]  b_i,
    // 控制信号
    input   wire[1:0]   op_i,
    // 输出数据
    output  reg[31:0]   res_o
    );
    
    always @(*) begin
        case(op_i)
            // 加
            2'b00 : res_o = a_i + b_i;
            // 减
            2'b01 : res_o = a_i + (~b_i + 1'b1);
            default: res_o = 32'b0;
        endcase
    end
endmodule
