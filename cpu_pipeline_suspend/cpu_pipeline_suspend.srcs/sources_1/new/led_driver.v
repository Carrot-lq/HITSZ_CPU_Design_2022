`timescale 1ns / 1ps
module led_driver(
    input   wire        clk,
    input   wire        rst,
    input   wire[31:0]  led_data,
    output  reg[7:0]    led_en_o,
    output  reg         led_ca_o,
    output  reg         led_cb_o,
    output  reg         led_cc_o,
    output  reg         led_cd_o,
    output  reg         led_ce_o,
    output  reg         led_cf_o,
    output  reg         led_cg_o,
    output  reg         led_dp_o
    );
    
    wire                clk_led; // 分频后led时钟
    led_clk_div u_led_clk_div(
        .clk_i      (clk),
        .clk_led_o  (clk_led)
    );
    
    // 循环计数
    reg [2:0] led_cnt;
    always @ (posedge clk_led or posedge rst) begin
        if (rst) begin
            led_cnt <= 3'h0;
        end else if (led_cnt == 3'h7) begin
            led_cnt <= 3'h0;
        end else begin
            led_cnt <= led_cnt + 3'h1;
        end
    end
    
//    // 使能信号
//    wire led0_en = ~(led_cnt == 3'h0);
//    wire led1_en = ~(led_cnt == 3'h1);
//    wire led2_en = ~(led_cnt == 3'h2);
//    wire led3_en = ~(led_cnt == 3'h3);
//    wire led4_en = ~(led_cnt == 3'h4);
//    wire led5_en = ~(led_cnt == 3'h5);
//    wire led6_en = ~(led_cnt == 3'h6);
//    wire led7_en = ~(led_cnt == 3'h7);

    // 输出使能信号
    always @ (posedge clk_led or posedge rst) begin
        if (rst) begin
            led_en_o <= 8'b11111111;
        end else begin 
            case(led_cnt)
                3'h7:   led_en_o <= 8'b01111111;
                3'h6:   led_en_o <= 8'b10111111;
                3'h5:   led_en_o <= 8'b11011111;
                3'h4:   led_en_o <= 8'b11101111;
                3'h3:   led_en_o <= 8'b11110111;
                3'h2:   led_en_o <= 8'b11111011;
                3'h1:   led_en_o <= 8'b11111101;
                3'h0:   led_en_o <= 8'b11111110;
                default:led_en_o <= 8'b11111111;
            endcase
        end
    end
    
    // 轮换显示8位数字
    reg [3:0] led_display;
    always @ (posedge clk_led) begin
        case (led_cnt)
            3'h7 :  led_display <= led_data[31:28];
            3'h6 :  led_display <= led_data[27:24];
            3'h5 :  led_display <= led_data[23:20];
            3'h4 :  led_display <= led_data[19:16]; 
            3'h3 :  led_display <= led_data[15:12];
            3'h2 :  led_display <= led_data[11:8];
            3'h1 :  led_display <= led_data[7:4];
            3'h0 :  led_display <= led_data[3:0];
            default:led_display <= led_display;
        endcase
    end
    
    // 段信号
    wire led_ca = ~(led_display == 4'h0 | led_display == 4'h2 | led_display == 4'h3 | led_display == 4'h5 | led_display == 4'h6 | led_display == 4'h7 
                    | led_display == 4'h8 | led_display == 4'h9 | led_display == 4'ha | led_display == 4'hc | led_display == 4'he | led_display == 4'hf);
    wire led_cb = ~(led_display == 4'h0 | led_display == 4'h1 | led_display == 4'h2 | led_display == 4'h3 | led_display == 4'h4 | led_display == 4'h7 
                    | led_display == 4'h8 | led_display == 4'h9 | led_display == 4'ha | led_display == 4'hd);
    wire led_cc = ~(led_display == 4'h0 | led_display == 4'h1 | led_display == 4'h3 | led_display == 4'h4 | led_display == 4'h5 | led_display == 4'h6 | led_display == 4'h7 
                    | led_display == 4'h8 | led_display == 4'h9 | led_display == 4'ha | led_display == 4'hb | led_display == 4'hd);
    wire led_cd = ~(led_display == 4'h0 | led_display == 4'h2 | led_display == 4'h3 | led_display == 4'h5 | led_display == 4'h6 
                    | led_display == 4'h8 | led_display == 4'h9 | led_display == 4'hb | led_display == 4'hc | led_display == 4'hd | led_display == 4'he);
    wire led_ce = ~(led_display == 4'h0 | led_display == 4'h2 | led_display == 4'h6 
                    | led_display == 4'h8 | led_display == 4'ha | led_display == 4'hb | led_display == 4'hc | led_display == 4'hd | led_display == 4'he | led_display == 4'hf);
    wire led_cf = ~(led_display == 4'h0 | led_display == 4'h4 | led_display == 4'h5 | led_display == 4'h6 
                    | led_display == 4'h8 | led_display == 4'h9 | led_display == 4'ha | led_display == 4'hb | led_display == 4'hc | led_display == 4'he | led_display == 4'hf);
    wire led_cg = ~(led_display == 4'h2 | led_display == 4'h3 | led_display == 4'h4 | led_display == 4'h5 | led_display == 4'h6 
                    | led_display == 4'h8 | led_display == 4'h9 | led_display == 4'ha | led_display == 4'hb | led_display == 4'hd | led_display == 4'he | led_display == 4'hf);
    wire led_dp = 1; 
    
    // 输出段信号
    always @ (posedge clk_led or posedge rst) begin
        if (rst) begin
            led_ca_o <= 1'b1;
            led_cb_o <= 1'b1;
            led_cc_o <= 1'b1;
            led_cd_o <= 1'b1;
            led_ce_o <= 1'b1;
            led_cf_o <= 1'b1;
            led_cg_o <= 1'b1;
            led_dp_o <= 1'b1;
        end else begin
            led_ca_o <= led_ca;
            led_cb_o <= led_cb;
            led_cc_o <= led_cc;
            led_cd_o <= led_cd;
            led_ce_o <= led_ce;
            led_cf_o <= led_cf;
            led_cg_o <= led_cg;
            led_dp_o <= 1'b1;
        end
    end
    

    
endmodule
