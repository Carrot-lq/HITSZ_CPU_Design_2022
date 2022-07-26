`timescale 1ns / 1ps
module IO_Bus(
    input   wire        clk,
    input   wire        rst,
    input   wire[31:0]  addr_i,
    input   wire[31:0]  wdata_i,
    output  reg[31:0]   rdata_o,
    // mem
    input   wire        mem_we_i,
    input   wire[2:0]   mem_data_sel_i,
    // 数码管
    output  wire[7:0]   led_en_o,
    output  wire        led_ca_o,
    output  wire        led_cb_o,
    output  wire        led_cc_o,
    output  wire        led_cd_o,
    output  wire        led_ce_o,
    output  wire        led_cf_o,
    output  wire        led_cg_o,
    output  wire        led_dp_o,
    // switch拨码开关
    input   wire[23:0]  switch_i,
    // led灯
    output  reg[23:0]   led_o
    );
    
    reg[31:0]   led_data;
    wire[31:0]  mem_rD;    
    
    // rdata_o 输出数据
    always@(*) begin
        if(rst) begin
            rdata_o = 32'b0;
        end else if(addr_i == 32'hfffff070) begin
            rdata_o = {8'b0,switch_i};
        end else begin
            rdata_o = mem_rD;
        end
    end
    
    // led_data 数码管显示数据
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            led_data <= 32'h0;
        end else if(addr_i == 32'hfffff000 && mem_we_i) begin
            led_data <= wdata_i;
        end else begin
            led_data <= led_data;
        end
    end
    
    // led灯
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            led_o <= 24'b0;
        end else if(addr_i == 32'hfffff060 && mem_we_i) begin
            led_o <= wdata_i[23:0];
        end else begin
            led_o <= led_o;
        end
    end
    
    led_driver u_led_driver(
        .clk        (clk),
        .rst        (rst),
        .led_data   (led_data),
        .led_en_o   (led_en_o),
        .led_ca_o   (led_ca_o), 
        .led_cb_o   (led_cb_o), 
        .led_cc_o   (led_cc_o), 
        .led_cd_o   (led_cd_o), 
        .led_ce_o   (led_ce_o), 
        .led_cf_o   (led_cf_o), 
        .led_cg_o   (led_cg_o), 
        .led_dp_o   (led_dp_o)  
    );
    
    MEM u_MEM(
        .rst            (rst),
        .clk            (clk),
        .mem_addr_i     (addr_i),
        .mem_wD_i       (wdata_i),
        .mem_we_i       (mem_we_i),
        .mem_data_sel_i (mem_data_sel_i),
        .mem_rD_o       (mem_rD)
    );
endmodule
