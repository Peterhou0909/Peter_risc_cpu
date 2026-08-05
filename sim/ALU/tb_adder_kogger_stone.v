`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/08 15:03:16
// Design Name: 
// Module Name: kogger_stone_tb
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
`timescale 1ns / 1ps

module tb_kogge_stone_32();

    // 信号定义
    reg  [31:0] a;
    reg  [31:0] b;
    reg         cin;
    wire [31:0] sum;
    wire        cout;

    // 实例化被测模块 (UUT)
    kogge_stone_32 uut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    // 辅助变量：用于生成黄金参考结果进行比对
    wire [32:0] reference_result = a + b + cin;
    wire [31:0] ref_sum  = reference_result[31:0];
    wire        ref_cout = reference_result[32];

    integer i;
    integer errors = 0;

    initial begin
        // 初始化信号
        a = 0;
        b = 0;
        cin = 0;
        errors = 0;

        $display("========================================");
        $display("Starting Kogge-Stone Adder Testbench...");
        $display("========================================");

        // --- 1. 基础测试 ---
        #10 a = 32'd10; b = 32'd20; cin = 0;
        #1 check_result("Basic Addition 1");

        #10 a = 32'd100; b = 32'd200; cin = 1;
        #1 check_result("Basic Addition with Cin");

        // --- 2. 边界测试 ---
        #10 a = 32'hFFFF_FFFF; b = 32'd0; cin = 0;
        #1 check_result("Max A");

        #10 a = 32'hFFFF_FFFF; b = 32'd0; cin = 1;
        #1 check_result("Max A + Cin (Carry Out Test)");

        #10 a = 32'hFFFF_FFFF; b = 32'hFFFF_FFFF; cin = 1;
        #1 check_result("All Ones + Cin");

        #10 a = 32'h5555_5555; b = 32'hAAAA_AAAA; cin = 0;
        #1 check_result("Alternating Bits (No Carry)");

        #10 a = 32'h5555_5555; b = 32'hAAAA_AAAA; cin = 1;
        #1 check_result("Alternating Bits (With Carry)");

        // --- 3. 大规模随机测试 ---
        $display("\nStarting 1000 Random Tests...");
        for (i = 0; i < 1000; i = i + 1) begin
            #10;
            a = $urandom;      // 生成32位随机数
            b = $urandom;
            cin = $urandom % 2; // 随机 0 或 1
            
            #1; // 等待组合逻辑稳定
            if (sum !== ref_sum || cout !== ref_cout) begin
                $display("ERROR at Random Test %0d: a=%h, b=%h, cin=%b | expected={%b, %h}, got={%b, %h}", 
                         i, a, b, cin, ref_cout, ref_sum, cout, sum);
                errors = errors + 1;
            end
        end

        // --- 4. 结果统计 ---
        #20;
        $display("========================================");
        if (errors == 0)
            $display("TEST PASSED! No errors found.");
        else
            $display("TEST FAILED! Total errors: %0d", errors);
        $display("========================================");
        $finish;
    end

    // 自动比对任务
   task check_result(input [8*40:1] test_name); 
        begin
            if (sum === ref_sum && cout === ref_cout) begin
                $display("[PASS] %s: a=%h, b=%h, cin=%b -> sum=%h, cout=%b", 
                         test_name, a, b, cin, sum, cout);
            end else begin
                $display("[FAIL] %s: a=%h, b=%h, cin=%b -> Expected {%b, %h}, Got {%b, %h}", 
                         test_name, a, b, cin, ref_cout, ref_sum, cout, sum);
                errors = errors + 1;
            end
        end
    endtask

endmodule