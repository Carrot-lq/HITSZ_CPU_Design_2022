`timescale 1ns/1ps
module IF_ID(
    input   wire        clk,
    input   wire        rst,
    input   wire        suspend_i,
    input   wire        flush_i,
    // IF传给ID的信号
    input   wire[31:0]  inst_i,
    output  reg[31:0]   inst_o,
    input   wire[31:0]  pc_i,
    output  reg[31:0]   pc_o,
    input   wire[31:0]  pc4_i,
    output  reg[31:0]   pc4_o
);
    // inst
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            inst_o <= 32'h0;
        end else if(flush_i) begin
            inst_o <= 32'h0;
        end else if(suspend_i) begin
            inst_o <= inst_o;
        end else begin
            inst_o <= inst_i;
        end
    end
    
    // pc
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            pc_o <= 32'h0;
        end else if(flush_i) begin
            pc_o <= 32'h0;
        end else if(suspend_i) begin
            pc_o <= pc_o;
        end else begin
            pc_o <= pc_i;
        end
    end
    // pc + 4
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            pc4_o <= 32'h0;
        end else if(flush_i) begin
            pc4_o <= 32'h0;
        end else if(suspend_i) begin
            pc4_o <= pc4_o;
        end else begin
            pc4_o <= pc4_i;
        end
    end
endmodule