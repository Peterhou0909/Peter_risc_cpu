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
module tb_data_mem();

    reg         clk;
    reg         we;
    reg  [31:0] addr;
    reg  [31:0] din;
    wire [31:0] dout;

    // 实例化
    data_mem uut (
        .clk(clk), .we(we), .addr(addr), .din(din), .dout(dout)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        we = 0; addr = 0; din = 0;
        #20;

        $display("--- Starting Memory Test ---");

        // 1. 基础写读测试
        @(posedge clk);
        addr = 32'h0000_0004; din = 32'hDEAD_BEEF; we = 1;
        @(posedge clk);
        we = 0;
        #1;
        if (dout === 32'hDEAD_BEEF)
            $display("[PASS] Basic Write/Read at Addr 4.");

        // 2. 字节地址对齐测试
        // 写入地址 8，尝试从地址 9, 10, 11 读取
        // 理论上 addr[11:2] 都会指向同一个槽位
        @(posedge clk);
        addr = 32'd8; din = 32'h1122_3344; we = 1;
        @(posedge clk);
        we = 0;
        
        addr = 32'd9; #1;
        if (dout === 32'h1122_3344) $display("[PASS] Addr 9 points to Word at 8.");
        
        addr = 32'd11; #1;
        if (dout === 32'h1122_3344) $display("[PASS] Addr 11 points to Word at 8.");

        // 3. 边界地址测试
        @(posedge clk);
        addr = 32'd4092; din = 32'hAAAA_5555; we = 1; // 最后一个可访问地址 (1023*4)
        @(posedge clk);
        we = 0; #1;
        if (dout === 32'hAAAA_5555)
            $display("[PASS] Boundary address (1023) check.");

        #20 $finish;
    end
endmodule