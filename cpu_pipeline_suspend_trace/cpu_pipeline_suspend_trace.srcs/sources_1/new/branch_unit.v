`timescale 1ns / 1ps
module branch_unit#(
    parameter EQ                    = 3'b000,
    parameter NEQ                   = 3'b001,
    parameter UNSIGNED_LT           = 3'b010,
    parameter SIGNED_LT             = 3'b011,
    parameter UNSIGNED_GE           = 3'b100,
    parameter SIGNED_GE             = 3'b101
)
(
    // 输入数据
    input   wire[31:0]  a_i,
    input   wire[31:0]  b_i,
    // 控制信号
    input   wire[3:0]   op_i,
    // 输出分支控制信号
    output  reg         branch
    );
    
    wire [31:0] tmp = (a_i - b_i);
    
    always @(*) begin
        case(op_i)
            // a-b = 0
            EQ:          branch = (tmp == 32'h0) ? 1'b1 : 1'b0;
            // a-b != 0
            NEQ:         branch = (tmp != 32'h0) ? 1'b1 : 1'b0;
            // a-b < 0
            UNSIGNED_LT: branch = (a_i < b_i) ? 1'b1 : 1'b0;
            SIGNED_LT: begin
                // a,b异号
                if(a_i[31] ^ b_i[31])
                    branch = a_i[31];
                // a,b同号，a-b < 0
                else
                    branch = (tmp[31] == 1'b1) ? 1'b1 : 1'b0;
            end   
            // a-b > 0
            UNSIGNED_GE: branch = (a_i >= b_i) ? 1'b1 : 1'b0;
            SIGNED_GE: begin
                // a,b异号
                if(a_i[31] ^ b_i[31])
                    branch = b_i[31];
                // a,b同号，a-b > 0
                else
                    branch = (tmp[31] == 1'b0) ? 1'b1 : 1'b0;
            end
            default:     branch = 1'b0;
        endcase
    end
endmodule
