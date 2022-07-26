`timescale 1ns / 1ps
module cpu_clk_div(
    input   wire    clk_i,
    input   wire    rst,
    output  reg     cpu_clk_o
    );
    
    reg [1:0] cnt = 0;
    wire cnt_end = (cnt == 3);
    
    always @ (posedge clk_i or posedge rst) begin
        if(rst) begin
            cnt <= 2'h0;
        end else if(cnt_end) begin 
            cnt <= 2'h0;
        end else begin
            cnt <= cnt + 1;
        end
    end
    
    always @ (posedge clk_i or posedge rst) begin
        if(rst) begin
            cpu_clk_o <= 1'b0;
        end else if(cnt_end) begin
            cpu_clk_o <= ~cpu_clk_o;
        end else begin
            cpu_clk_o <= cpu_clk_o;
        end
    end
endmodule
