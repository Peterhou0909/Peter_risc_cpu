`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/08/06 11:17:58
// Design Name: 
// Module Name: alu_top
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
module alu_top (
    input  wire        clk,
    input  wire        rst_n,
    
    // 控制信号
    input  wire [3:0]  alu_op,    // 操作码，定义见下文
    input  wire        start,     // 启动信号（仅对乘除法有效）
    
    // 输入数据
    input  wire [31:0] a,
    input  wire [31:0] b,
    
    // 输出数据
    output reg  [31:0] alu_out,   // 主输出（结果、商）
    output reg  [31:0] alu_out_hi,// 高位输出（余数、乘法高32位）
    output wire        ready,     // ALU空闲信号
    output wire        zero,      // 零标志位
    output wire        overflow   // 加减法溢出标志
);

    // --- 操作码定义 (Encoding) ---
    localparam OP_ADD  = 4'b0000;
    localparam OP_SUB  = 4'b0001;
    localparam OP_AND  = 4'b0010;
    localparam OP_OR   = 4'b0011;
    localparam OP_XOR  = 4'b0100;
    localparam OP_NOR  = 4'b0101;
    localparam OP_SLT  = 4'b0110; // Set Less Than 
    localparam OP_MUL  = 4'b1000;
    localparam OP_DIV  = 4'b1001;

    // --- 内部中间信号 ---
    
    // 1. 加减法器 (KSA)
    wire [31:0] ksa_sum;
    wire        ksa_cout;
    wire [31:0] b_inv = (alu_op == OP_SUB || alu_op == OP_SLT) ? ~b : b;
    wire        cin   = (alu_op == OP_SUB || alu_op == OP_SLT) ? 1'b1 : 1'b0;
    
    kogge_stone_32 adder (
        .a(a),
        .b(b_inv),
        .cin(cin),
        .sum(ksa_sum),
        .cout(ksa_cout)
    );

    // 2. 乘法器 (Sequential)
    wire [63:0] mul_res;
    wire        mul_ready;
    multiplier_seq mul_unit (
        .clk(clk), .rst_n(rst_n),
        .start(start && (alu_op == OP_MUL)),
        .a(a), .b(b),
        .product(mul_res),
        .ready(mul_ready)
    );

    // 3. 除法器 (Sequential)
    wire [31:0] div_q, div_r;
    wire        div_ready, div_dbz;
    divider_seq div_unit (
        .clk(clk), .rst_n(rst_n),
        .start(start && (alu_op == OP_DIV)),
        .dividend(a), .divisor(b),
        .quotient(div_q), .remainder(div_r),
        .ready(div_ready), .dbz(div_dbz)
    );

    // --- 组合逻辑：结果选择 (Mux) ---
    always @(*) begin
        alu_out_hi = 32'd0;
        case (alu_op)
            OP_ADD:  alu_out = ksa_sum;
            OP_SUB:  alu_out = ksa_sum;
            OP_AND:  alu_out = a & b;
            OP_OR:   alu_out = a | b;
            OP_XOR:  alu_out = a ^ b;
            OP_NOR:  alu_out = ~(a | b);
            OP_SLT:  alu_out = (a[31] != b[31]) ? a[31] : ksa_sum[31]; // 简单的有符号比较
            
            OP_MUL:  begin
                alu_out    = mul_res[31:0];
                alu_out_hi = mul_res[63:32];
            end
            
            OP_DIV:  begin
                alu_out    = div_q;
                alu_out_hi = div_r;
            end
            
            default: alu_out = 32'd0;
        endcase
    end

    // --- 状态反馈信号 ---
    
    // 关键点：统一 ready 信号
    // 如果是乘除法，看子模块的 ready；如果是基础运算，永远是 1 (组合逻辑瞬间完成)
    assign ready = (alu_op == OP_MUL) ? mul_ready :
                   (alu_op == OP_DIV) ? div_ready : 1'b1;

    assign zero = (alu_out == 32'd0);
    
    // 溢出判断：仅在加减法有效 (同号相加结果异号，或异号相减结果异常)
    assign overflow = (alu_op == OP_ADD || alu_op == OP_SUB) ? 
                      (a[31] == b_inv[31] && a[31] != ksa_sum[31]) : 1'b0;

endmodule