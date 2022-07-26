`timescale 1ns / 1ps
module CTRL#(
    parameter OPCODE_JAL   = 7'b1101111,
    parameter OPCODE_JALR  = 7'b1100111,
    parameter OPCODE_LOAD  = 7'b0000011,
    parameter OPCODE_B     = 7'b1100011,
    parameter OPCODE_R     = 7'b0110011,
    parameter OPCODE_I     = 7'b0010011,
    parameter OPCODE_S     = 7'b0100011,
    parameter OPCODE_AUIPC = 7'b0010111,
    parameter OPCODE_LUI   = 7'b0110111
)
(
    input   wire        rst,            // 重置信号
    input   wire[6:0]   op_i,           // 输入的opcode
    input   wire[6:0]   func7_i,        // 输入的funct7
    input   wire[2:0]   func3_i,        // 输入的funct3
    // 送至IF的信号
    output  reg [1:0]   pc_sel_o,       // PC选择信号
    output  reg         branch_ctrl_o,  // B型指令跳转信号 
    // 送至ID的信号
    output  reg [2:0]   sext_sel_o,     // 符号扩展选择信号
    output  reg [1:0]   rf_wD_sel_o,    // 寄存器写数据选择信号
    output  reg         rf_we_o,        // 寄存器写使能信号
    // 送至EX的信号
    output  reg [4:0]   alu_op_o,       // alu操作码
    output  reg         A_sel_o,        // ALU输入1选择信号
    output  reg         B_sel_o,        // ALU输入2选择信号
    // 送至MEM的信号
    output  reg [2:0]   mem_data_sel_o, // mem数据选择信号
    output  reg         mem_we_o        // dmem写使能信号
    );

    // pc_sel_o
    always @(*) begin
        if(rst)
            pc_sel_o = 2'b00;
        else begin
            case(op_i)
                // B型指令，成功跳转为pc+offset，否则pc+4
                OPCODE_B:
                    pc_sel_o = 2'b01;
                // jalr，(pc+offset) & ~1
                OPCODE_JALR:
                    pc_sel_o = 2'b11;
                // jal，pc+offset
                OPCODE_JAL:
                    pc_sel_o = 2'b10;
                // 其他，pc+4
                default:
                    pc_sel_o = 2'b00;
            endcase
        end
    end

    // branch_ctrl_o
    always @(*) begin
        if(rst)
            branch_ctrl_o = 1'b0;
        else begin
            case(op_i)
                // B型指令可能需要跳转（结合ALU运算结果）
                OPCODE_B:
                    branch_ctrl_o = 1'b1;
                default:
                    branch_ctrl_o = 1'b0;
            endcase
        end
    end
    
    // rf_wD_sel_o
    always @(*) begin
        if(rst)
            rf_wD_sel_o = 2'b11;
        else begin
            case(op_i)
                // jal,jalr
                OPCODE_JAL,OPCODE_JALR:
                    rf_wD_sel_o = 2'b00;
                // lb,lw,ld
                OPCODE_LOAD:
                    rf_wD_sel_o = 2'b10;
                // 其他
                default:
                    rf_wD_sel_o = 2'b01;
            endcase
        end
    end
    
    // sext_sel_o
    always @(*) begin
        if(rst)
            sext_sel_o = 3'b000;
        else begin
            case(op_i)
                // R型指令
                OPCODE_R:
                    sext_sel_o = 3'b000;
                // I型指令
                OPCODE_I: begin
                    case(func3_i)
                        // 移位
                        3'b001, 3'b101:
                            sext_sel_o = 3'b010;
                        // 其他
                        default:
                            sext_sel_o = 3'b001;
                    endcase
                end
                // lb,lh,lw,jalr
                OPCODE_LOAD, OPCODE_JALR:
                    sext_sel_o = 3'b001;
                // S型
                OPCODE_S:
                    sext_sel_o = 3'b011;
                // B型
                OPCODE_B:
                    sext_sel_o = 3'b100;
                // aluipc,lui
                OPCODE_AUIPC, OPCODE_LUI:
                    sext_sel_o = 3'b101;
                // jal
                OPCODE_JAL:
                    sext_sel_o = 3'b110;
                default:;
            endcase
        end
    end

    // rf_we_o
    always @(*) begin
        if(rst)
            rf_we_o = 1'b0;
        else begin
            case(op_i)
                // R型，I型，U型，J型需要写寄存器
                OPCODE_R, OPCODE_I, OPCODE_LOAD, OPCODE_JAL, OPCODE_LUI, OPCODE_AUIPC, OPCODE_JALR:
                    rf_we_o = 1'b1;
                default:
                    rf_we_o = 1'b0;
            endcase
        end
    end
    
    // alu_op_o
    always @(*) begin
        case(op_i)
            // R型，I型
            OPCODE_R, OPCODE_I: begin
                case(func3_i)
                    // add/addi或sub
                    3'b000: begin
                        // I型指令只有加
                        if(op_i == OPCODE_I)
                            alu_op_o = 5'b00000;
                        // R型指令根据func7第6位判断加减
                        else
                            alu_op_o = (func7_i[5] == 1'b0) ? 5'b00000 : 5'b00001;
                    end
                    // 与 and/andi
                    3'b111:
                        alu_op_o = 5'b01000;
                    // 或 or/ori
                    3'b110:
                        alu_op_o = 5'b01001;
                    // 异或 xor/xori
                    3'b100:
                        alu_op_o = 5'b01010;
                    // 左移 sll/slli
                    3'b001:
                        alu_op_o = 5'b01100;
                    // 右移 srl/srli或sra/srai，根据func7第6位判断逻辑移位还是算术移位
                    3'b101:
                        alu_op_o = (func7_i[5] == 1'b0) ? 5'b01101 : 5'b01110;
                    // 有符号比较 slt/slti
                    3'b010:
                        alu_op_o = 5'b00100;
                    // 无符号比较 sltu/sltui
                    3'b011:
                        alu_op_o = 5'b00101;
                    default:;
                    endcase
            end
            // B型
            OPCODE_B: begin
                case(func3_i)
                    // beq
                    3'b000: alu_op_o = 5'b00000;
                    // bne
                    3'b001: alu_op_o = 5'b00001;
                    // blt
                    3'b100: alu_op_o = 5'b00011; 
                    // bltu
                    3'b110: alu_op_o = 5'b00010;
                    // bge
                    3'b101: alu_op_o = 5'b00101;
                    // bgeu
                    3'b111: alu_op_o = 5'b00100;
                    default:;
                endcase
            end
            // load,jal,S型,auipc, jalr
            OPCODE_LOAD, OPCODE_JAL, OPCODE_S, OPCODE_AUIPC, OPCODE_JALR:
                alu_op_o = 5'b00000;
            // lui
            OPCODE_LUI:
                alu_op_o = 5'b10000;
            default:;
        endcase
    end
    
    // A_sel_o
    always @(*) begin
        case(op_i)
            // ALU输入1为rD1
            OPCODE_R, OPCODE_I, OPCODE_LOAD, OPCODE_JAL, OPCODE_S, OPCODE_B:
                A_sel_o = 1'b1;
            // ALU输入1为PC
            default:
                A_sel_o = 1'b0;
        endcase
    end

    // B_sel_o
    always @(*) begin
        case(op_i)
            // ALU输入2为rD2
            OPCODE_R, OPCODE_B:
                B_sel_o = 1'b1;
            // ALU输入2为ext
            default:
                B_sel_o = 1'b0;
        endcase
    end
    
    // mem_data_sel
    always@(*) begin
        case(func3_i)
            // lb,sb
            3'b000: mem_data_sel_o = 3'b000;
            // lh,sh
            3'b001: mem_data_sel_o = 3'b001;
            // lw,sw
            3'b010: mem_data_sel_o = 3'b010;
            // lbu
            3'b100: mem_data_sel_o = 3'b100;
            // lhu
            3'b101: mem_data_sel_o = 3'b101;
            default:;
        endcase
    end
    
    // mem_we_o
    always @(*) begin
        if(rst)
            mem_we_o = 1'b0;
        else begin
            case(op_i)
                // S型指令需要写dmem
                OPCODE_S:
                    mem_we_o = 1'b1;
                // 其余均不需要
                default:
                    mem_we_o = 1'b0;
            endcase
        end
    end
endmodule
