`timescale 1ns / 1ps
module RF(
    input   wire        rst,
    input   wire        clk,
    // ¶Á¼Ä´æÆ÷ºÅ
    input   wire[4:0]   rR1_i,
    input   wire[4:0]   rR2_i,
    // Ð´¼Ä´æÆ÷ºÅ
    input   wire[4:0]   wR_i,
    // Ð´Êý¾Ý
    input   wire[31:0]  wD_i,
    // Ð´¿ØÖÆÐÅºÅ
    input   wire        we_i,
    // ¶ÁÊý¾Ý
    output  wire[31:0]  rD1_o,
    output  wire[31:0]  rD2_o
    );
    
    reg[31:0]    regs[0:31];
    
    always @(posedge clk) begin
        if(we_i) begin
            if(wR_i != 5'b0) begin
                regs[wR_i] <= wD_i;
            end
        end
    end
    
    assign rD1_o = (rR1_i == 5'b0) ? 32'h0 : regs[rR1_i];
    assign rD2_o = (rR2_i == 5'b0) ? 32'h0 : regs[rR2_i];

endmodule
