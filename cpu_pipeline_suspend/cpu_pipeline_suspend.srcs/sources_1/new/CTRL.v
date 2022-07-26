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
    input   wire        rst,            // �����ź�
    input   wire[6:0]   op_i,           // �����opcode
    input   wire[6:0]   func7_i,        // �����funct7
    input   wire[2:0]   func3_i,        // �����funct3
    // ����IF���ź�
    output  reg [1:0]   pc_sel_o,       // PCѡ���ź�
    output  reg         branch_ctrl_o,  // B��ָ����ת�ź� 
    // ����ID���ź�
    output  reg [2:0]   sext_sel_o,     // ������չѡ���ź�
    output  reg [1:0]   rf_wD_sel_o,    // �Ĵ���д����ѡ���ź�
    output  reg         rf_we_o,        // �Ĵ���дʹ���ź�
    // ����EX���ź�
    output  reg [4:0]   alu_op_o,       // alu������
    output  reg         A_sel_o,        // ALU����1ѡ���ź�
    output  reg         B_sel_o,        // ALU����2ѡ���ź�
    // ����MEM���ź�
    output  reg [2:0]   mem_data_sel_o, // mem����ѡ���ź�
    output  reg         mem_we_o,       // dmemдʹ���ź�
    // ����ð�ռ���ź�
    output  reg         data_hazard_detect_ctrl_r1_o,
    output  reg         data_hazard_detect_ctrl_r2_o 
    );

    // pc_sel_o
    always @(*) begin
        if(rst)
            pc_sel_o = 2'b00;
        else begin
            case(op_i)
                // B��ָ��ɹ���תΪpc+offset������pc+4
                OPCODE_B:
                    pc_sel_o = 2'b01;
                // jalr��(pc+offset) & ~1
                OPCODE_JALR:
                    pc_sel_o = 2'b11;
                // jal��pc+offset
                OPCODE_JAL:
                    pc_sel_o = 2'b10;
                // ������pc+4
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
                // B��ָ�������Ҫ��ת�����ALU��������
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
                // ����
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
                // R��ָ��
                OPCODE_R:
                    sext_sel_o = 3'b000;
                // I��ָ��
                OPCODE_I: begin
                    case(func3_i)
                        // ��λ
                        3'b001, 3'b101:
                            sext_sel_o = 3'b010;
                        // ����
                        default:
                            sext_sel_o = 3'b001;
                    endcase
                end
                // lb,lh,lw,jalr
                OPCODE_LOAD, OPCODE_JALR:
                    sext_sel_o = 3'b001;
                // S��
                OPCODE_S:
                    sext_sel_o = 3'b011;
                // B��
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
                // R�ͣ�I�ͣ�U�ͣ�J����Ҫд�Ĵ���
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
            // R�ͣ�I��
            OPCODE_R, OPCODE_I: begin
                case(func3_i)
                    // add/addi��sub
                    3'b000: begin
                        // I��ָ��ֻ�м�
                        if(op_i == OPCODE_I)
                            alu_op_o = 5'b00000;
                        // R��ָ�����func7��6λ�жϼӼ�
                        else
                            alu_op_o = (func7_i[5] == 1'b0) ? 5'b00000 : 5'b00001;
                    end
                    // �� and/andi
                    3'b111:
                        alu_op_o = 5'b01000;
                    // �� or/ori
                    3'b110:
                        alu_op_o = 5'b01001;
                    // ��� xor/xori
                    3'b100:
                        alu_op_o = 5'b01010;
                    // ���� sll/slli
                    3'b001:
                        alu_op_o = 5'b01100;
                    // ���� srl/srli��sra/srai������func7��6λ�ж��߼���λ����������λ
                    3'b101:
                        alu_op_o = (func7_i[5] == 1'b0) ? 5'b01101 : 5'b01110;
                    // �з��űȽ� slt/slti
                    3'b010:
                        alu_op_o = 5'b00100;
                    // �޷��űȽ� sltu/sltui
                    3'b011:
                        alu_op_o = 5'b00101;
                    default:;
                    endcase
            end
            // B��
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
            // load,jal,S��,auipc, jalr
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
            // ALU����1ΪrD1
            OPCODE_R, OPCODE_I, OPCODE_LOAD, OPCODE_JAL, OPCODE_S, OPCODE_B:
                A_sel_o = 1'b1;
            // ALU����1ΪPC
            default:
                A_sel_o = 1'b0;
        endcase
    end

    // B_sel_o
    always @(*) begin
        case(op_i)
            // ALU����2ΪrD2
            OPCODE_R, OPCODE_B:
                B_sel_o = 1'b1;
            // ALU����2Ϊext
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
                // S��ָ����Ҫдdmem
                OPCODE_S:
                    mem_we_o = 1'b1;
                // ���������Ҫ
                default:
                    mem_we_o = 1'b0;
            endcase
        end
    end
    
    // data_hazard
    always @(*) begin
        case(op_i)
            OPCODE_R, OPCODE_I, OPCODE_S, OPCODE_LOAD, OPCODE_S, OPCODE_B, OPCODE_JALR:
                data_hazard_detect_ctrl_r1_o = 1'b1;
            default:
                data_hazard_detect_ctrl_r1_o = 1'b0;
        endcase
    end

    always @(*) begin
        case(op_i)
            OPCODE_R, OPCODE_S, OPCODE_B:
                data_hazard_detect_ctrl_r2_o = 1'b1;
            default:
                data_hazard_detect_ctrl_r2_o = 1'b0;
        endcase
    end
endmodule
