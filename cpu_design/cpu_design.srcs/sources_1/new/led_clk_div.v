`timescale 1ns / 1ps
module led_clk_div(
    input   wire    clk_i,
    input   wire    rst,
    output  reg     clk_led_o
    );

    reg [15:0] cnt = 0;
    wire cnt_end = (cnt == 9999);
    
    always @ (posedge clk_i or posedge rst) begin
        if(rst) begin
            cnt <= 16'h0;
        end else if(cnt_end) begin 
            cnt <= 16'h0;
        end else begin
            cnt <= cnt + 1;
        end
    end
    
    always @ (posedge clk_i or posedge rst) begin
        if(rst) begin
            clk_led_o <= 1'b0;
        end else if(cnt_end) begin
            clk_led_o <= ~clk_led_o;
        end else begin
            clk_led_o <= clk_led_o;
        end
    end
    
endmodule
