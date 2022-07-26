`timescale 1ns / 1ps
module MEM(
    input   wire        rst,
    input   wire        clk,
    // ��ַ
    input   wire[31:0]  mem_addr_i,
    // д����
    input   wire[31:0]  mem_wD_i,
    // �����ź�
    input   wire        mem_we_i,
    input   wire[2:0]   mem_data_sel_i,
    // ���
    output  reg[31:0]   mem_rD_o
    );
    
    wire [31:0] mem_addr_tmp = mem_addr_i - 16'h4000;

    reg  [31:0] dram_input;
    wire [31:0] dram_output;
    // ����ֽ�
    reg  [7:0]  dram_output_byte;
    // �����
    reg  [15:0] dram_output_word;
    // ���˫��
    wire [31:0] dram_output_dword;

    // ����ָͬ��ʱ��ͬ���
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
        // ѡ�����
        if(mem_addr_tmp[1])
            dram_output_word = dram_output[31:16];
        // ѡ�����
        else
            dram_output_word = dram_output[15:0];
    end
    // lw
    assign dram_output_dword = dram_output;
    
    // �����ֽ�
    wire [7:0]  dram_input_byte  = mem_wD_i[7:0];
    // ������
    wire [15:0] dram_input_word  = mem_wD_i[15:0];
    // ����˫��
    wire [31:0] dram_input_dword = mem_wD_i;
    
    // dram_input dram��������
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
    
    // mem_rD_o MEMģ�����
    always @(*) begin
        case(mem_data_sel_i)
            3'b000: mem_rD_o = {{24{dram_output_byte[7]}}, dram_output_byte};     // lb
            3'b001: mem_rD_o = {{16{dram_output_word[15]}}, dram_output_word};    // lh
            3'b010: mem_rD_o = dram_output_dword;                                 // lw
            3'b100: mem_rD_o = {24'b0, dram_output_byte};                         // lbu
            3'b101: mem_rD_o = {16'b0, dram_output_word};                         // lhu
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
