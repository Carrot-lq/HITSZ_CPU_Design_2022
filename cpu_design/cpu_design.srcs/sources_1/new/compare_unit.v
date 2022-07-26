`timescale 1ns / 1ps
module compare_unit(
    // 输入数据
    input   wire[31:0]  a_i,
    input   wire[31:0]  b_i,
    // 控制信号
    input   wire[1:0]   op_i,
    // 输出数据
    output  reg[31:0]   res_o
    );
    wire[31:0]  tmp;
    assign tmp = a_i - b_i;
    
    always@(*) begin
        case(op_i)
            // 有符号比较
            2'b00: begin
                if(a_i[31] ^ b_i[31])
                    res_o = a_i[31];
                else
                    res_o = (tmp[31]) ? 32'h1 : 32'h0;
            end
            // 无符号比较
            2'b01: begin
                res_o = (a_i < b_i) ? 32'h1 : 32'h0;
            end
            default:
                res_o = 32'h0;
        endcase
    end
endmodule
