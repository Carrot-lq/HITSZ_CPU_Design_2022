`timescale 1ns/1ps
module ID_EX(
    input   wire        clk,
    input   wire        rst,
    input   wire        suspend_i,
    input   wire        flush_i,
    // ID传至EX的信号
    input   wire        branch_ctrl_i,   
    output  reg         branch_ctrl_o,   
    input   wire[31:0]  pc_i,
    output  reg[31:0]   pc_o,
    input   wire[31:0]  pc4_i,
    output  reg[31:0]   pc4_o,
    input   wire[1:0]   pc_sel_i,
    output  reg[1:0]    pc_sel_o,    
    input   wire[31:0]  sext_i,
    output  reg[31:0]   sext_o,
    input   wire[31:0]  rf_rD1_i,
    output  reg[31:0]   rf_rD1_o,
    input   wire[31:0]  rf_rD2_i,
    output  reg[31:0]   rf_rD2_o,
    input   wire[4:0]   rf_rR1_i,
    output  reg[4:0]    rf_rR1_o,
    input   wire[4:0]   rf_rR2_i,
    output  reg[4:0]    rf_rR2_o,
    input   wire[4:0]   rf_wR_i,
    output  reg[4:0]    rf_wR_o,
    input   wire[1:0]   rf_wD_sel_i,
    output  reg[1:0]    rf_wD_sel_o,
    input   wire        rf_we_i,
    output  reg         rf_we_o,
    input   wire        A_sel_i,  
    output  reg         A_sel_o,  
    input   wire        B_sel_i,
    output  reg         B_sel_o,
    input   wire[4:0]   alu_op_i,
    output  reg[4:0]    alu_op_o,
    input   wire        mem_we_i,
    output  reg         mem_we_o,
    input   wire[2:0]   mem_data_sel_i,
    output  reg[2:0]    mem_data_sel_o
);
    // branch_ctrl
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            branch_ctrl_o <= 1'b0;
        end else if(flush_i) begin
            branch_ctrl_o <= 1'b0;
        end else if(suspend_i) begin
            branch_ctrl_o <= 1'b0;
        end else begin
            branch_ctrl_o <= branch_ctrl_i;
        end
    end
    
    // pc
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            pc_o <= 32'h0;
        end else if(suspend_i) begin
            pc_o <= pc_o;
        end else begin
            pc_o <= pc_i;
        end
    end
    
    // pc4
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
    
    // pc_sel
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            pc_sel_o <= 2'h0;
        end else if(flush_i) begin
            pc_sel_o <= 2'h0;
        end else if(suspend_i) begin
            pc_sel_o <= pc_sel_o;
        end else begin
            pc_sel_o <= pc_sel_i;
        end
    end
    
    // sext
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            sext_o <= 32'h0;
        end else if(flush_i) begin
            sext_o <= 32'h0;
        end else if(suspend_i) begin
            sext_o <= sext_o;
        end else begin
            sext_o <= sext_i;
        end
    end
    
    // rf_rD1
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            rf_rD1_o <= 32'h0;
        end else if(flush_i) begin
            rf_rD1_o <= 32'h0;
        end else if(suspend_i) begin
            rf_rD1_o <= rf_rD1_o;
        end else begin
            rf_rD1_o <= rf_rD1_i;
        end
    end
    
    // rf_rD2
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            rf_rD2_o <= 32'h0;
        end else if(flush_i) begin
            rf_rD2_o <= 32'h0;
        end else if(suspend_i) begin
            rf_rD2_o <= rf_rD2_o;
        end else begin
            rf_rD2_o <= rf_rD2_i;
        end
    end
    
    // rf_rR1
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            rf_rR1_o <= 5'h0;
        end else if(flush_i) begin
            rf_rR1_o <= 5'h0;
        end else if(suspend_i) begin
            rf_rR1_o <= rf_rR1_o;
        end else begin
            rf_rR1_o <= rf_rR1_i;
        end
    end
    
    // rf_rR2
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            rf_rR2_o <= 5'h0;
        end else if(flush_i) begin
            rf_rR2_o <= 5'h0;
        end else if(suspend_i) begin
            rf_rR2_o <= rf_rR2_o;
        end else begin
            rf_rR2_o <= rf_rR2_i;
        end
    end
    
    // rf_wR
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            rf_wR_o <= 5'h0;
        end else if(flush_i) begin
            rf_wR_o <= 5'h0;
        end else if(suspend_i) begin
            rf_wR_o <= 5'h0;
        end else begin
            rf_wR_o <= rf_wR_i;
        end
    end
    
    // rf_wD_sel
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            rf_wD_sel_o <= 2'h0;
        end else if(flush_i) begin
            rf_wD_sel_o <= 2'h0;
        end else if(suspend_i) begin
            rf_wD_sel_o <= rf_wD_sel_o;
        end else begin
            rf_wD_sel_o <= rf_wD_sel_i;
        end
    end 
    
    // rf_we
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            rf_we_o <= 1'b0;
        end else if(flush_i) begin
            rf_we_o <= 1'b0;
        end else if(suspend_i) begin
            rf_we_o <= 1'b0; 
        end else begin
            rf_we_o <= rf_we_i;
        end
    end
    
    // A_sel
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            A_sel_o <= 1'b0;
        end else if(flush_i) begin
            A_sel_o <= 1'b0;
        end else if(suspend_i) begin
            A_sel_o <= A_sel_o;
        end else begin
            A_sel_o <= A_sel_i;
        end
    end
    
    // B_sel
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            B_sel_o <= 1'b0;
        end else if(flush_i) begin
            B_sel_o <= 1'b0;
        end else if(suspend_i) begin
            B_sel_o <= B_sel_o;
        end else begin
            B_sel_o <= B_sel_i;
        end
    end
    
    // alu_op
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            alu_op_o <= 5'h0;
        end else if(flush_i) begin
            alu_op_o <= 5'h0;
        end else if(suspend_i) begin
            alu_op_o <= alu_op_o;
        end else begin
            alu_op_o <= alu_op_i;
        end
    end
    
    // mem_we
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            mem_we_o <= 1'b0;
        end else if(flush_i) begin
            mem_we_o <= 1'b0;
        end else if(suspend_i) begin
            mem_we_o <= 1'b0;
        end else begin
            mem_we_o <= mem_we_i;
        end
    end
    
    // mem_data_sel
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            mem_data_sel_o <= 3'h0;
        end else if(flush_i) begin
            mem_data_sel_o <= 3'h0;
        end else if(suspend_i) begin
            mem_data_sel_o <= mem_data_sel_o;
        end else begin
            mem_data_sel_o <= mem_data_sel_i;
        end
    end

endmodule
