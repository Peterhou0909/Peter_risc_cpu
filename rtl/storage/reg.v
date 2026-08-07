`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:
// Design Name: 
// Module Name: reg
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
module reg_file (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        we,         // 写使能信号
    input  wire [4:0]  ra1,        // 读寄存器 1 地址
    input  wire [4:0]  ra2,        // 读寄存器 2 地址
    input  wire [4:0]  wa,         // 写寄存器地址
    input  wire [31:0] wd,         // 写数据
    output wire [31:0] rd1,        // 读数据 1
    output wire [31:0] rd2         // 读数据 2
);

    // 定义 32 个 32 位寄存器
    reg [31:0] rf [31:1]; // R0 恒为 0，所以不需要实际存储空间

    // 异步读取 (组合逻辑)
    assign rd1 = (ra1 == 5'd0) ? 32'd0 : rf[ra1];
    assign rd2 = (ra2 == 5'd0) ? 32'd0 : rf[ra2];

    // 同步写入 (时序逻辑)
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 复位时将寄存器清零 (可选，根据需求)
            for (i = 1; i < 32; i = i + 1)
                rf[i] <= 32'd0;
        end else if (we && (wa != 5'd0)) begin
            rf[wa] <= wd;
        end
    end

endmodule