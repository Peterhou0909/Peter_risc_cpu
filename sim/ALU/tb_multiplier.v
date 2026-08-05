`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/08 14:55:35
// Design Name: 
// Module Name: tb_multiply
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

module tb_multiplier_seq();

    // 信号定义
    reg         clk;
    reg         rst_n;
    reg         start;
    reg  [31:0] a;
    reg  [31:0] b;
    wire [63:0] product;
    wire        ready;

    // 实例化乘法器
    multiplier_seq uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .a(a),
        .b(b),
        .product(product),
        .ready(ready)
    );

    // 1. 生成时钟：周期为 10ns
    initial clk = 0;
    always #5 clk = ~clk;

    // 2. 仿真逻辑
    initial begin
        // 初始化
        rst_n = 0;
        start = 0;
        a = 0;
        b = 0;

        // 复位动作
        #20 rst_n = 1;
        #10;

        $display("========================================");
        $display("Starting Multiplier Test...");
        $display("========================================");

        // 1: 基础乘法 ---
        drive_multiplier(32'd10, 32'd20);
        check_result("Basic Mul 10*20");

        // 2: 包含 0 ---
        drive_multiplier(32'd500, 32'd0);
        check_result("Multiply by Zero");

        // 3: 最大值测试 ---
        drive_multiplier(32'hFFFF_FFFF, 32'd1);
        check_result("Max Value * 1");

        // 4: 随机压力测试 ---
        repeat(10) begin
            drive_multiplier($urandom, $urandom);
            check_result("Random Test");
        end

        $display("========================================");
        $display("All Tests Finished.");
        $display("========================================");
        $finish;
    end

    // 任务：驱动乘法器
    task drive_multiplier(input [31:0] val_a, input [31:0] val_b);
        begin
            @(posedge clk);
            a = val_a;
            b = val_b;
            start = 1;      // 发起请求
            
            @(posedge clk);
            start = 0;      // 撤销请求，防止重复触发
            
            // 等待直到 ready 信号回到 1，表示计算完成
            wait(ready == 1); 
            @(posedge clk); // 再等一个沿，确保 product 已经稳定输出
        end
    endtask

    // 任务：检查结果
    task check_result(input [8*40:1] test_name);
        reg [63:0] expected_val;
        begin
            expected_val = a * b; // 仿真器自动计算正确值
            if (product === expected_val) begin
                $display("[PASS] %s: %d * %d = %d", test_name, a, b, product);
            end else begin
                $display("[FAIL] %s: %d * %d | Expected %d, Got %d", 
                         test_name, a, b, expected_val, product);
            end
        end
    endtask

endmodule