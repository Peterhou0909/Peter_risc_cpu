`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/08 15:02:58
// Design Name: 
// Module Name: kogger_stone
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
// ====================================================
// 32-bit Kogge-Stone Adder 
// ====================================================
module kogge_stone_32 (
    input  [31:0] a,
    input  [31:0] b,
    input         cin,
    output [31:0] sum,
    output        cout
);

    // 第1级：预处理 - 生成初始 P 和 G
    wire [31:0] G0, P0;
    wire [31:0] half_sum;

    assign G0 = a & b;
    assign P0 = a ^ b; 
    assign half_sum = a ^ b;

    // -------------------------------------------------
    // 并行前缀树层级 (Level 1 to 5 for 32-bit)
    // -------------------------------------------------
    wire [31:0] G [1:5];
    wire [31:0] P [1:5];

    genvar n, i;
    generate
        for (n = 1; n <= 5; n = n + 1) begin : levels
            // 每一层的跨度 (stride) 
            localparam stride = 1 << (n - 1);
            
            for (i = 0; i < 32; i = i + 1) begin : bits
                if (i < stride) begin
                    // 如果当前位小于跨度，则直接传递上一层的值
                    assign G[n][i] = (n == 1) ? G0[i] : G[n-1][i];
                    assign P[n][i] = (n == 1) ? P0[i] : P[n-1][i];
                end else begin
                    // 当前位大于跨度，前缀合并
                    wire prev_G = (n == 1) ? G0[i-stride] : G[n-1][i-stride];
                    wire prev_P = (n == 1) ? P0[i-stride] : P[n-1][i-stride];
                    wire curr_G = (n == 1) ? G0[i]        : G[n-1][i];
                    wire curr_P = (n == 1) ? P0[i]        : P[n-1][i];
                    
                    assign G[n][i] = curr_G | (curr_P & prev_G);
                    assign P[n][i] = curr_P & prev_P;
                end
            end
        end
    endgenerate

    // -------------------------------------------------
    // 进位生成逻辑 
    // C[i] 代表进入第 i 位的进位信号 
    // -------------------------------------------------
    wire [31:0] C;
    
    assign C[0] = cin; // 第0位的进位输入就是外部的 cin
    
    generate
        for (i = 1; i < 32; i = i + 1) begin : carry_gen
            // 第 i 位的进位 = 前 i-1 位的组生成信号 | (前 i-1 位的组传播信号 & 外部进位)
            assign C[i] = G[5][i-1] | (P[5][i-1] & cin);
        end
    endgenerate

    // -------------------------------------------------
    // 计算最终结果
    // -------------------------------------------------
    assign sum = half_sum ^ C;
    
    // 最终进位输出
    assign cout = G[5][31] | (P[5][31] & cin);

endmodule
