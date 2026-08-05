`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/08 14:55:15
// Design Name: 
// Module Name: multiply
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module multiplier_seq (
    input  wire        clk,       // 系统时钟
    input  wire        rst_n,     // 异步复位，低电平有效
    input  wire        start,     // 开始计算信号 (由 CPU 发出)
    input  wire [31:0] a,         // 被乘数
    input  wire [31:0] b,         // 乘数
    output reg  [63:0] product,   // 乘法结果
    output reg         ready      // 乘法器空闲
);

    // 状态定义
    localparam IDLE = 2'b00;
    localparam CALC = 2'b01;
    localparam DONE = 2'b10;

    reg [1:0]  state;             // 状态机寄存器
    reg [5:0]  count;             // 计数器，0-32
    reg [63:0] temp_a;            // 用于移位的被乘数
    reg [31:0] temp_b;            // 用于移位的乘数

    // 状态机逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state   <= IDLE;
            product <= 64'd0;
            ready   <= 1'b1;
            count   <= 6'd0;
            temp_a  <= 64'd0;
            temp_b  <= 32'd0;
        end else begin
            case (state)
                IDLE: begin
                    ready <= 1'b1;
                    if (start) begin
                        ready   <= 1'b0;
                        state   <= CALC;
                        count   <= 6'd0;
                        product <= 64'd0;
                        // 初始化：将被乘数扩展到64位，乘数载入临时寄存器
                        temp_a  <= {32'd0, a};
                        temp_b  <= b;
                    end
                end

                CALC: begin
                    if (count < 6'd32) begin
                        // 如果当前乘数的最低位是1，则累加 temp_a
                        if (temp_b[0]) begin
                            product <= product + temp_a;
                        end
                        // 被乘数左移，乘数右移
                        temp_a <= temp_a << 1;
                        temp_b <= temp_b >> 1;
                        count  <= count + 6'd1;
                    end else begin
                        state <= DONE;
                    end
                end

                DONE: begin
                    ready <= 1'b1;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule