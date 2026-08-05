`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/08 16:11:20
// Design Name: 
// Module Name: tb_sub
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
// 文件名: tb_subtractor_fixed.v
`timescale 1ns/1ps
module subtractor32_tb;

    // 信号定义
    reg  [31:0] a;
    reg  [31:0] b;
    wire [31:0] diff;
    wire        cout;

    // 实例化
    subtractor32 uut (
        .a(a),
        .b(b),
        .diff(diff),
        .cout(cout)
    );

    initial begin
        // 1. 设置输入值 (100 - 40)
        a = 32'd100;
        b = 32'd40;

        // 2. 等待 10 个时间单位观察结果
        #10;

        // 3. 在终端打印结果
        // 预期结果：diff = 60
        $display("Time = %0t | A = %d, B = %d | Result (A-B) = %d", $time, a, b, diff);

        // 4. 结束
        $finish;
    end

endmodule