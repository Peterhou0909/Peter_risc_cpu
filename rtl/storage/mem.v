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
module data_mem (
    input  wire        clk,
    input  wire        we,         // 写使能
    input  wire [31:0] addr,       // 地址 (通常来自 ALU)
    input  wire [31:0] din,        // 写入的数据
    output wire [31:0] dout        // 读出的数据
);

    // 定义存储深度
    reg [31:0] ram [0:1023];

    // 同步写入
    always @(posedge clk) begin
        if (we) begin
            ram[addr[11:2]] <= din; // addr[11:2] 是因为按字寻址，忽略低两位
        end
    end

    // 异步读取 
    assign dout = ram[addr[11:2]];

endmodule