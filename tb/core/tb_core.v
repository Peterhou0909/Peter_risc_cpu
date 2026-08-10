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

module tb_top_cpu();

    // 1. 信号定义
    reg clk;
    reg rst_n;
    wire [31:0] debug_pc;
    wire [31:0] debug_alu_out;

    // 2. 实例化 CPU 顶层
    top_cpu dut (
        .clk(clk),
        .rst_n(rst_n),
        .debug_pc(debug_pc),
        .debug_alu_out(debug_alu_out)
    );

    // 3. 时钟生成 (100MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // 4. 程序加载与仿真逻辑
    initial begin
        
        $dumpfile("dump_core.vcd");
        $dumpvars(0, dut);

        // 初始化
        rst_n = 0;
        
        // 手动向内存注入机器码 

        // [0] ADDI R1, R0, 3  -> 32'h28010003
        dut.memory.ram[0] = {6'h0A, 5'd0, 5'd1, 16'd3};
        
        // [1] ADDI R2, R0, 5  -> 32'h28020005
        dut.memory.ram[1] = {6'h0A, 5'd0, 5'd2, 16'd5};
        
        // [2] MUL  R3, R1, R2 -> 32'h0C221800 (Opcode 03, rs 1, rt 2, rd 3)
        dut.memory.ram[2] = {6'h03, 5'd1, 5'd2, 5'd3, 11'd0};
        
        // [3] ADDI R4, R3, 10 -> 32'h2864000A (Opcode 0A, rs 3, rt 4, imm 10)
        dut.memory.ram[3] = {6'h0A, 5'd3, 5'd4, 16'd10};
        
        // [4] SW   R4, 4(R0)  -> 32'h38040004 (Opcode 0E, rs 0, rt 4, offset 4)
        dut.memory.ram[4] = {6'h0E, 5'd0, 5'd4, 16'd4};
        
        // [5] J    0          -> 32'h44000000 (Opcode 11, target 0)
        dut.memory.ram[5] = {6'h11, 26'd0};

        $display("========================================");
        $display("CPU Multi-Cycle Test: (3 * 5) + 10 = 25");
        $display("========================================");

        #20 rst_n = 1; // 释放复位

        // 运行足够长的时间
        #1000;

        // 检查内存地址 4 的值是否为 25
        if (dut.memory.ram[1] === 32'd25) // 这里 ram[1] 对应字节地址 4 (因为 addr[11:2])
            $display("[SUCCESS] Memory at Addr 4 (Word 1) is 25!");
        else
            $display("[FAILED] Expected 25, Got %d", dut.memory.ram[1]);

        $display("========================================");
        $finish;
    end

    // 5. 调试：实时监控寄存器变化 (层级引用)
    initial begin
        $monitor("Time:%0t | PC:%h | State:%b | R1:%d | R2:%d | R3:%d | R4:%d", 
                 $time, debug_pc, dut.ctrl.current_state, 
                 dut.dp.rf.rf[1], dut.dp.rf.rf[2], dut.dp.rf.rf[3], dut.dp.rf.rf[4]);
    end

endmodule