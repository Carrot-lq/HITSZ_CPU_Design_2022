`timescale 1ns / 1ps
module RF(
    input   wire        rst,
    input   wire        clk,
    // ¶Á¼Ä´æÆ÷
    input   wire[4:0]   rf_rR1_i,
    input   wire[4:0]   rf_rR2_i,
    // Ð´¼Ä´æÆ÷
    input   wire[4:0]   rf_wR_i,
    // Ð´Êý¾Ý
    input   wire[31:0]  rf_wD_i,
    // Ð´¿ØÖÆÐÅºÅ
    input   wire        rf_we_i,
    // ¶ÁÊý¾Ý
    output  wire[31:0]  rf_rD1_o,
    output  wire[31:0]  rf_rD2_o
    );
    
    reg[31:0]    regs[0:31];
    
    always @(posedge clk) begin
        if(rf_we_i) begin
            if(rf_wR_i != 5'b0) begin
                regs[rf_wR_i] <= rf_wD_i;
            end
        end
    end
    
    assign rf_rD1_o = (rf_rR1_i == 5'b0) ? 32'h0 : regs[rf_rR1_i];
    assign rf_rD2_o = (rf_rR2_i == 5'b0) ? 32'h0 : regs[rf_rR2_i];

endmodule
