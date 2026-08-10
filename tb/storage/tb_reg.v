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

module tb_reg_file();

    reg         clk;
    reg         rst_n;
    reg         we;
    reg  [4:0]  ra1, ra2, wa;
    reg  [31:0] wd;
    wire [31:0] rd1, rd2;

    // 实例化
    reg_file uut (
        .clk(clk), .rst_n(rst_n), .we(we),
        .ra1(ra1), .ra2(ra2), .wa(wa), .wd(wd),
        .rd1(rd1), .rd2(rd2)
    );

    // 时钟生成
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump_reg.vcd");
        $dumpvars(0, uut);
        // 初始化
        rst_n = 0; we = 0; ra1 = 0; ra2 = 0; wa = 0; wd = 0;
        #20 rst_n = 1;

        $display("--- Starting RegFile Test ---");

        // 1. 测试 R0 恒零：尝试向 R0 写入数据
        @(posedge clk);
        wa = 5'd0; wd = 32'hAAAA_BBBB; we = 1;
        @(posedge clk);
        we = 0; ra1 = 5'd0;
        #1; // 等待组合逻辑稳定
        if (rd1 === 32'd0) 
            $display("[PASS] R0 is hardwired to 0.");
        else 
            $display("[FAIL] R0 was modified!");

        // 2. 基础读写测试：写入 R1, R2 并同时读出
        @(posedge clk);
        wa = 5'd1; wd = 32'h1234_5678; we = 1;
        @(posedge clk);
        wa = 5'd2; wd = 32'h8765_4321; we = 1;
        @(posedge clk);
        we = 0; ra1 = 5'd1; ra2 = 5'd2;
        #1;
        if (rd1 === 32'h1234_5678 && rd2 === 32'h8765_4321)
            $display("[PASS] Dual port read successful.");
        else
            $display("[FAIL] Read data mismatch!");

        // 3. 写使能测试：we=0 时不应写入
        @(posedge clk);
        wa = 5'd3; wd = 32'hFFFF_FFFF; we = 0; 
        @(posedge clk);
        ra1 = 5'd3;
        #1;
        if (rd1 !== 32'hFFFF_FFFF)
            $display("[PASS] Write Enable (we) is working.");
        else
            $display("[FAIL] Data written even when we=0!");

        #20 $finish;
    end
endmodule