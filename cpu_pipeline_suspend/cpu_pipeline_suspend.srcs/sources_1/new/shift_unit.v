`timescale 1ns / 1ps
module shift_unit#(
    parameter LEFT              = 2'b00,
    parameter RIGHT_LOGIC       = 2'b01,
    parameter RIGHT_ARITHMETIC  = 2'b10
)
(
    // 输入数据
    input   wire[31:0]  a_i,
    input   wire[31:0]  b_i,// 仅低5位有效
    // 控制信号
    input   wire[1:0]   op_i,
    // 输出数据
    output  wire[31:0]   res_o
    );
    reg [31:0] tmp;
    always @(*) begin
        case(op_i)
            LEFT:begin
                tmp = (b_i[0]==1'b1) ? {a_i[30:0],1'b0} : a_i;
                tmp = (b_i[1]==1'b1) ? {tmp[29:0],2'b0} : tmp;
                tmp = (b_i[2]==1'b1) ? {tmp[27:0],4'b0} : tmp;
                tmp = (b_i[3]==1'b1) ? {tmp[23:0],8'b0} : tmp;
                tmp = (b_i[4]==1'b1) ? {tmp[15:0],16'b0}: tmp;
            end
            RIGHT_LOGIC:begin
                tmp = (b_i[0]==1'b1) ? {1'b0,a_i[31:1]}     : a_i;
                tmp = (b_i[1]==1'b1) ? {2'b0,tmp[31:2]}     : tmp;
                tmp = (b_i[2]==1'b1) ? {4'b0,tmp[31:4]}     : tmp;
                tmp = (b_i[3]==1'b1) ? {8'b0,tmp[31:8]}     : tmp;
                tmp = (b_i[4]==1'b1) ? {16'b0,tmp[31:16]}   : tmp; 
            end
            RIGHT_ARITHMETIC: begin
                tmp = (b_i[0]==1'b1) ? {{1{a_i[31]}},a_i[31:1]}     : a_i;
                tmp = (b_i[1]==1'b1) ? {{2{a_i[31]}},tmp[31:2]}     : tmp;
                tmp = (b_i[2]==1'b1) ? {{4{a_i[31]}},tmp[31:4]}     : tmp;
                tmp = (b_i[3]==1'b1) ? {{8{a_i[31]}},tmp[31:8]}     : tmp;
                tmp = (b_i[4]==1'b1) ? {{16{a_i[31]}},tmp[31:16]}   : tmp; 
            end
            default: tmp = 32'b0;
        endcase
    end
    
    assign res_o = tmp;
    
endmodule
