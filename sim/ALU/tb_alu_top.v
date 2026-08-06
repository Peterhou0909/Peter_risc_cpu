`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:
// Design Name: 
// Module Name: 
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
module tb_alu_top();

    // 信号定义
    reg         clk;
    reg         rst_n;
    reg  [3:0]  alu_op;
    reg         start;
    reg  [31:0] a;
    reg  [31:0] b;
    
    wire [31:0] alu_out;
    wire [31:0] alu_out_hi;
    wire        ready;
    wire        zero;
    wire        overflow;

    // 实例化 ALU Top
    alu_top uut (
        .clk(clk), .rst_n(rst_n),
        .alu_op(alu_op), .start(start),
        .a(a), .b(b),
        .alu_out(alu_out), .alu_out_hi(alu_out_hi),
        .ready(ready), .zero(zero), .overflow(overflow)
    );

    // 时钟生成 (100MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // 操作码定义 (对应 alu_top.v)
    localparam OP_ADD = 4'b0000;
    localparam OP_SUB = 4'b0001;
    localparam OP_AND = 4'b0010;
    localparam OP_MUL = 4'b1000;
    localparam OP_DIV = 4'b1001;

    initial begin
        // 初始化
        rst_n = 0; start = 0; alu_op = 0; a = 0; b = 0;
        #20 rst_n = 1;
        #10;

        $display("--- Starting ALU Top Integration Test ---");

        // 1. 测试组合逻辑：加法 (ADD)
        // 组合逻辑应该立即 ready 为 1
        @(posedge clk);
        a = 32'd100; b = 32'd200; alu_op = OP_ADD;
        #1; // 等待组合逻辑稳定
        if (ready && alu_out === 32'd300)
            $display("[PASS] ADD: 100 + 200 = 300");
        else
            $display("[FAIL] ADD failed!");

        // 2. 测试组合逻辑：溢出判断 (Overflow)
        @(posedge clk);
        a = 32'h7FFF_FFFF; b = 32'd1; alu_op = OP_ADD; // 正最大 + 1
        #1;
        if (overflow)
            $display("[PASS] ADD Overflow detected.");

        // 3. 测试时序逻辑：乘法 (MUL)
        // 需要发 start 脉冲，并等待 ready
        @(posedge clk);
        a = 32'd25; b = 32'd4; alu_op = OP_MUL; 
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0; // 撤销 start
        
        wait(ready == 1); // 等待乘法器数 32 个周期
        if (alu_out === 32'd100)
            $display("[PASS] MUL: 25 * 4 = 100 (Multi-cycle)");
        else
            $display("[FAIL] MUL failed!");

        // 4. 测试时序逻辑：除法 (DIV)
        @(posedge clk);
        a = 32'd100; b = 32'd7; alu_op = OP_DIV; 
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        wait(ready == 1);
        if (alu_out === 32'd14 && alu_out_hi === 32'd2)
            $display("[PASS] DIV: 100 / 7 = 14 rem 2 (Multi-cycle)");
        else
            $display("[FAIL] DIV failed!");

        // 5. 测试逻辑运算：与 (AND)
        @(posedge clk);
        a = 32'hF0F0_F0F0; b = 32'hAAAA_AAAA; alu_op = OP_AND;
        #1;
        if (alu_out === (32'hF0F0_F0F0 & 32'hAAAA_AAAA))
            $display("[PASS] AND operation successful.");

        $display("--- ALU Top Integration Test Finished ---");
        #50 $finish;
    end

endmodule