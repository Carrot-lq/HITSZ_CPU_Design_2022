`timescale 1ns / 1ps
module MEM(
    input   wire        rst,
    input   wire        clk,
    // 地址
    input   wire[31:0]  mem_addr_i,
    // 写数据
    input   wire[31:0]  mem_wD_i,
    // 控制信号
    input   wire        mem_we_i,
    input   wire[2:0]   mem_data_sel_i,
    // 输出
    output  reg[31:0]   mem_rD_o
    );
    
    wire [31:0] mem_addr_tmp = mem_addr_i - 16'h4000;

    reg  [31:0] dram_input;
    wire [31:0] dram_output;
    
    // 输出字节
    reg  [7:0]  dram_output_byte;
    // 输出字
    reg  [15:0] dram_output_word;
    // 输出双字
    wire [31:0] dram_output_dword;

    // 处理不同指令时不同输出
    // lb
    always @(*) begin
        case(mem_addr_tmp[1:0])
            2'b00: dram_output_byte = dram_output[7:0];
            2'b01: dram_output_byte = dram_output[15:8];
            2'b10: dram_output_byte = dram_output[23:16];
            2'b11: dram_output_byte = dram_output[31:24];
            default:;
        endcase
    end
    // lh
    always @(*) begin
        // 选择高字
        if(mem_addr_tmp[1])
            dram_output_word = dram_output[31:16];
        // 选择低字
        else
            dram_output_word = dram_output[15:0];
    end
    // lw
    assign dram_output_dword = dram_output;

    // 输入字节
    wire [7:0]  dram_input_byte   = mem_wD_i[7:0];
    // 输入字
    wire [15:0] dram_input_word   = mem_wD_i[15:0];
    // 输入双字
    wire [31:0] dram_input_dword  = mem_wD_i;

    // dram_input dram输入数据
    always @(*) begin
        case(mem_data_sel_i)
            // sb
            3'b000: begin
                case(mem_addr_tmp[1:0])
                    2'b00: dram_input = {dram_output[31:8], dram_input_byte};
                    2'b01: dram_input = {dram_output[31:16], dram_input_byte, dram_output[7:0]};
                    2'b10: dram_input = {dram_output[31:24], dram_input_byte, dram_output[15:0]};
                    2'b11: dram_input = {dram_input_byte, dram_output[23:0]};
                    default:;
                endcase
            end
            // sh
            3'b001: begin
                case(mem_addr_tmp[1])
                    1'b0: dram_input = {dram_output[31:16], dram_input_word};
                    1'b1: dram_input = {dram_input_word, dram_output[15:0]};
                    default:;
                endcase 
            end 
            // sw
            3'b010: dram_input = dram_input_dword;
            default:;
        endcase
    end
        
    // mem_rD_o MEM模块输出
    always @(*) begin
        case(mem_data_sel_i)
            3'b000: mem_rD_o = {{24{dram_output_byte[7]}}, dram_output_byte};     // lb
            3'b001: mem_rD_o = {{16{dram_output_word[15]}}, dram_output_word};    // lh
            3'b010: mem_rD_o = dram_output_dword;                                 // lw
            3'b100: mem_rD_o = {24'b0,dram_output_byte};                          // lbu
            3'b101: mem_rD_o = {16'b0,dram_output_word};                          // lhu
            default:;
        endcase
    end
    
//    wire ram_clk;
//    assign ram_clk = !clk; 
    dram U_dram (
        .clk    (clk),
        .a      (mem_addr_tmp[15:2]),
        .spo    (dram_output),
        .we     (mem_we_i),
        .d      (dram_input)
    );
    
endmodule
