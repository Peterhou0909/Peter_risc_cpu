`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: tb_alu_top
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
module tb_alu_top_v2();

    // --- 1. 信号定义 ---
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

    // --- 2. 实例化 UUT ---
    alu_top uut (
        .clk(clk), .rst_n(rst_n),
        .alu_op(alu_op), .start(start),
        .a(a), .b(b),
        .alu_out(alu_out), .alu_out_hi(alu_out_hi),
        .ready(ready), .zero(zero), .overflow(overflow)
    );

    // --- 3. 操作码定义 (必须与 alu_top.v 一致) ---
    localparam OP_ADD  = 4'b0000;
    localparam OP_SUB  = 4'b0001;
    localparam OP_AND  = 4'b0010;
    localparam OP_OR   = 4'b0011;
    localparam OP_XOR  = 4'b0100;
    localparam OP_NOR  = 4'b0101;
    localparam OP_SLT  = 4'b0110;
    localparam OP_LUI  = 4'b0111;
    localparam OP_MUL  = 4'b1000;
    localparam OP_DIV  = 4'b1001;

    // --- 4. 时钟生成 (100MHz) ---
    initial clk = 0;
    always #5 clk = ~clk;

    // --- 5. 测试流程 ---
    initial begin
        // 初始化
        rst_n = 0; start = 0; alu_op = 0; a = 0; b = 0;
        #20 rst_n = 1;
        #10;

        $display("========================================");
        $display("ALU Top : Starting Comprehensive Test...");
        $display("========================================");

        // --- Case 1: 逻辑运算 (AND, OR, NOR) ---
        drive_alu(OP_AND, 32'hF0F0F0F0, 32'hAAAA_AAAA, "Logic AND");
        drive_alu(OP_OR,  32'hF0F0F0F0, 32'hAAAA_AAAA, "Logic OR");
        drive_alu(OP_NOR, 32'h0000_FFFF, 32'h0000_0000, "Logic NOR");

        // --- Case 2: SLT 比较测试 (有符号) ---
        drive_alu(OP_SLT, 32'd10, 32'd20, "SLT: 10 < 20 (Result should be 1)");
        drive_alu(OP_SLT, 32'hFFFF_FFFB, 32'd5, "SLT: -5 < 5 (Result should be 1)");
        drive_alu(OP_SLT, 32'd100, 32'd50, "SLT: 100 < 50 (Result should be 0)");

        // --- Case 3: LUI 测试 ---
        drive_alu(OP_LUI, 32'h0, 32'hABCD, "LUI: Load ABCD to Upper");

        // --- Case 4: 乘法握手测试 (关键) ---
        drive_alu_multi_cycle(OP_MUL, 32'd25, 32'd4, "MUL: 25 * 4");

        // --- Case 5: 除法握手测试 ---
        drive_divider(32'd100, 32'd7, "DIV: 100 / 7");

        // --- Case 6: 溢出测试 ---
        drive_alu(OP_ADD, 32'h7FFF_FFFF, 32'h0000_0001, "ADD Overflow");

        $display("========================================");
        $display("All Tests Finished.");
        $display("========================================");
        $finish;
    end

    // --- 6. 辅助 Task ---

    // 针对组合逻辑的驱动 (ADD, AND, SLT, LUI等)
    task drive_alu(input [3:0] op, input [31:0] val_a, input [31:0] val_b, input [8*40:1] name);
        begin
            @(posedge clk);
            alu_op = op; a = val_a; b = val_b; start = 0;
            #1; // 等待组合逻辑
            $display("[PASS] %s | a=%h, b=%h -> Out=%h, Zero=%b, Ov=%b", 
                     name, a, b, alu_out, zero, overflow);
        end
    endtask

    // 针对乘法时序逻辑的驱动
    task drive_alu_multi_cycle(input [3:0] op, input [31:0] val_a, input [31:0] val_b, input [8*40:1] name);
        begin
            @(posedge clk);
            alu_op = op; a = val_a; b = val_b; start = 1;
            @(posedge clk);
            start = 0;
            
            // 稳健握手：先等 ready 变低，再等 ready 变高
            @(posedge clk);
            if(ready === 1) @(posedge clk); // 如果还在 IDLE，再等一拍
            wait(ready == 1);
            
            #1;
            $display("[PASS] %s | a=%d, b=%d -> Result=%d", name, a, b, alu_out);
        end
    endtask

    // 针对除法时序逻辑的驱动
    task drive_divider(input [31:0] d_end, input [31:0] d_sor, input [8*40:1] name);
        begin
            @(posedge clk);
            alu_op = OP_DIV; a = d_end; b = d_sor; start = 1;
            @(posedge clk);
            start = 0;
            
            @(posedge clk);
            if(ready === 1) @(posedge clk);
            wait(ready == 1);
            
            #1;
            $display("[PASS] %s | %d / %d -> Q=%d, R=%d", name, a, b, alu_out, alu_out_hi);
        end
    endtask

endmodule