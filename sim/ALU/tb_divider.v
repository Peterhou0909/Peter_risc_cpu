`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/08 17:38:02
// Design Name: 
// Module Name: tb_div
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
module tb_divider_seq();

    // 信号定义
    reg         clk;
    reg         rst_n;
    reg         start;
    reg  [31:0] dividend;
    reg  [31:0] divisor;
    
    wire [31:0] quotient;
    wire [31:0] remainder;
    wire        ready;
    wire        dbz;

    // 实例化除法器
    divider_seq uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .dividend(dividend),
        .divisor(divisor),
        .quotient(quotient),
        .remainder(remainder),
        .ready(ready),
        .dbz(dbz)
    );

    // 1. 时钟生成 (100MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // 2. 仿真过程
    initial begin
        // 初始化
        rst_n = 0;
        start = 0;
        dividend = 0;
        divisor = 0;

        // 复位
        #20 rst_n = 1;
        #10;

        $display("========================================");
        $display("Starting Sequential Divider Test...");
        $display("========================================");

        // --- Case 1: 整除 ---
        drive_divider(32'd100, 32'd10);
        check_result("Perfect Division (100/10)");

        // --- Case 2: 带余数除法 ---
        drive_divider(32'd10, 32'd3);
        check_result("Division with Remainder (10/3)");

        // --- Case 3: 被除数小于除数 ---
        drive_divider(32'd5, 32'd12);
        check_result("Small Dividend (5/12)");

        // --- Case 4: 除以0测试 ---
        drive_divider(32'd100, 32'd0);
        if (dbz) $display("[PASS] Divide by Zero detected correctly.");
        else     $display("[FAIL] Divide by Zero NOT detected!");

        // --- Case 5: 随机压力测试 ---
        repeat(10) begin
            drive_divider($urandom % 1000, ($urandom % 50) + 1); // 保证除数不为0
            check_result("Random Test");
        end

        $display("========================================");
        $display("All Division Tests Finished.");
        $display("========================================");
        $finish;
    end

    // 任务：驱动除法器
    task drive_divider(input [31:0] d_end, input [31:0] d_sor);
        begin
            @(posedge clk);
            dividend = d_end;
            divisor = d_sor;
            start = 1;
            @(posedge clk);
            start = 0;
            
            // 等待计算完成
            wait(ready == 1);
            @(posedge clk);
        end
    endtask

    // 任务：验证结果
    task check_result(input [8*40:1] test_name);
        reg [31:0] ref_q;
        reg [31:0] ref_r;
        begin
            ref_q = dividend / divisor;
            ref_r = dividend % divisor;
            
            // 验证恒等式: Dividend = Q*D + R
            if ((quotient === ref_q) && (remainder === ref_r)) begin
                $display("[PASS] %s: %d / %d = %d ... %d", 
                         test_name, dividend, divisor, quotient, remainder);
            end else begin
                $display("[FAIL] %s: %d / %d | Expected %d...%d, Got %d...%d", 
                         test_name, dividend, divisor, ref_q, ref_r, quotient, remainder);
            end
        end
    endtask

endmodule