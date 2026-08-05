`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/08 17:37:44
// Design Name: 
// Module Name: div
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
module divider_seq (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,      // 开始信号
    input  wire [31:0] dividend,   // 被除数
    input  wire [31:0] divisor,    // 除数
    output reg  [31:0] quotient,   // 商
    output reg  [31:0] remainder,  // 余数
    output reg         ready,      // 空闲/完成信号
    output reg         dbz         // 除以0错误 (Divide by Zero)
);

    // 状态定义
    localparam IDLE = 2'b00;
    localparam CALC = 2'b01;
    localparam DONE = 2'b10;

    reg [1:0]  state;
    reg [5:0]  count;
    
    // 核心寄存器：使用一个64位的寄存器来合并处理余数和商
    // 高32位初始为0（最终变为余数），低32位初始为被除数（最终变为商）
    reg [63:0] temp_reg; 
    reg [31:0] temp_divisor;

    wire [63:0] shifted_reg = temp_reg << 1;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= IDLE;
            ready        <= 1'b1;
            dbz          <= 1'b0;
            quotient     <= 32'd0;
            remainder    <= 32'd0;
            count        <= 6'd0;
            temp_reg     <= 64'd0;
            temp_divisor <= 32'd0;
        end else begin
            case (state)
                IDLE: begin
                    ready <= 1'b1;
                    if (start) begin
                        ready <= 1'b0;
                        if (divisor == 32'd0) begin
                            dbz   <= 1'b1;  // 错误：除数为0
                            state <= DONE;
                        end else begin
                            dbz          <= 1'b0;
                            count        <= 6'd0;
                            temp_reg     <= {32'd0, dividend}; // 高32位清零，低32位放被除数
                            temp_divisor <= divisor;
                            state        <= CALC;
                        end
                    end
                end

                CALC: begin
                    if (count < 6'd32) begin                     
                        if (shifted_reg[63:32] >= temp_divisor) begin
                            // 够减：高32位减去除数，低位补1
                            temp_reg <= {shifted_reg[63:32] - temp_divisor, shifted_reg[31:1], 1'b1};
                        end else begin
                            // 不够减：直接保留左移后的结果（最低位本来就是0）
                            temp_reg <= shifted_reg;
                        end
                        count <= count + 6'd1;
                    end else begin
                        state <= DONE;
                    end
                end

                DONE: begin
                    quotient  <= temp_reg[31:0];  // 低32位是商
                    remainder <= temp_reg[63:32]; // 高32位是余数
                    ready     <= 1'b1;
                    state     <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule