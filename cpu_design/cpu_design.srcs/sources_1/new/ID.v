`timescale 1ns / 1ps
module ID#(
    parameter PC4           = 2'b00,
    parameter ALU_RESULT    = 2'b01,
    parameter MEM_DATA      = 2'b10
)
(
    input   wire        rst,
    input   wire        clk,
    //来自控制模块的信号
    input   wire[2:0]   sext_sel_i,
    input   wire[1:0]   rf_wD_sel_i,
    input   wire        rf_we_i,
    //来自IF的信号
    input   wire[31:0]  inst_i,
    input   wire[31:0]  pc4_i,    
    //来自alu的信号
    input   wire[31:0]  alu_res_i,
    //来自dmem的信号
    input   wire[31:0]  mem_rD_i,
    //输出的信号
    output  wire[31:0]  rD1_o,
    output  wire[31:0]  rD2_o,
    //输出的立即数
    output  wire[31:0]  sext_o
    );
    
    // 写入寄存器的数据
    reg[31:0]   rf_wD;
    always @(*) begin
        if(rst) begin
            rf_wD = 32'b0;
        end else begin
            case(rf_wD_sel_i) 
                PC4 :       rf_wD = pc4_i;
                ALU_RESULT: rf_wD = alu_res_i;
                MEM_DATA :  rf_wD = mem_rD_i;
                default :   rf_wD = 32'h0;
            endcase
        end
    end

    // 寄存器堆regfile
    RF u_RF(
        .rst        (rst),
        .clk        (clk),
        .we_i       (rf_we_i),
        .rR1_i      (inst_i[19:15]),
        .rR2_i      (inst_i[24:20]),
        .wR_i       (inst_i[11:7]),
        .wD_i       (rf_wD),
        .rD1_o      (rD1_o),
        .rD2_o      (rD2_o)
    );
    
    // 符号扩展单元
    SEXT u_SEXT(
        .rst        (rst),
        .inst_i     (inst_i),        
        .sext_sel_i (sext_sel_i),
        .sext_o     (sext_o)      
    );
endmodule
