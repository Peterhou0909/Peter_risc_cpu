`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/08 16:10:58
// Design Name: 
// Module Name: sub
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
module subtractor32 (
    input  [31:0] a,      // 被减数
    input  [31:0] b,      // 减数
    output [31:0] diff,   // 差值
    output        cout    // 进位输出 
);

    assign {cout, diff} = a + (~b) + 32'd1;

endmodule
