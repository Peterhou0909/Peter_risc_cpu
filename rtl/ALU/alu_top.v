`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
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
//////////////////////////////////////////////////////////////////////////////////

module alu_top (
    input  wire        clk,
    input  wire        rst_n,
    
    // 控制信号
    input  wire [3:0]  alu_op,    // 操作码
    input  wire        start,     // 启动信号 
    
    // 输入数据
    input  wire [31:0] a,
    input  wire [31:0] b,
    
    // 输出数据
    output reg  [31:0] alu_out,   // 主输出
    output reg  [31:0] alu_out_hi,// 高位输出
    output wire        ready,     // 完成信号
    output wire        zero,      // 零标志位 
    output wire        overflow   // 溢出标志位
);

    // --- 操作码定义 ---
    localparam OP_ADD  = 4'b0000; // 加法 / ADDI
    localparam OP_SUB  = 4'b0001; // 减法 / BEQ / BNE
    localparam OP_AND  = 4'b0010; // 逻辑与
    localparam OP_OR   = 4'b0011; // 逻辑或
    localparam OP_XOR  = 4'b0100; // 逻辑异或
    localparam OP_NOR  = 4'b0101; // 逻辑或非
    localparam OP_SLT  = 4'b0110; // 小于则置 1
    localparam OP_LUI  = 4'b0111; // 加载高位立即数 
    localparam OP_MUL  = 4'b1000; // 乘法
    localparam OP_DIV  = 4'b1001; // 除法

    // --- 子模块：KSA 加法器 (复用于 ADD, SUB, SLT) ---
    wire [31:0] ksa_sum;
    wire        ksa_cout;
    wire        is_sub = (alu_op == OP_SUB || alu_op == OP_SLT);
    wire [31:0] b_inv  = is_sub ? ~b : b;
    wire        cin    = is_sub ? 1'b1 : 1'b0;
    
    kogge_stone_32 adder (
        .a(a),
        .b(b_inv),
        .cin(cin),
        .sum(ksa_sum),
        .cout(ksa_cout)
    );

    // --- 子模块：乘法器 ---
    wire [63:0] mul_res;
    wire        mul_ready;
    multiplier_seq mul_unit (
        .clk(clk), .rst_n(rst_n),
        .start(start && (alu_op == OP_MUL)),
        .a(a), .b(b),
        .product(mul_res), .ready(mul_ready)
    );

    // --- 子模块：除法器 ---
    wire [31:0] div_q, div_r;
    wire        div_ready, div_dbz;
    divider_seq div_unit (
        .clk(clk), .rst_n(rst_n),
        .start(start && (alu_op == OP_DIV)),
        .dividend(a), .divisor(b),
        .quotient(div_q), .remainder(div_r),
        .ready(div_ready), .dbz(div_dbz)
    );

    // --- 溢出判断逻辑 (仅对加减法有效) ---
    // 公式：如果两个操作数符号相同，但结果符号不同，则溢出
    assign overflow = (alu_op == OP_ADD || alu_op == OP_SUB) ? 
                      (a[31] == b_inv[31] && a[31] != ksa_sum[31]) : 1'b0;

    // --- 结果多路选择器 (Output Mux) ---
    always @(*) begin
        alu_out_hi = 32'd0;
        case (alu_op)
            OP_ADD:  alu_out = ksa_sum;
            OP_SUB:  alu_out = ksa_sum;
            OP_AND:  alu_out = a & b;
            OP_OR:   alu_out = a | b;
            OP_XOR:  alu_out = a ^ b;
            OP_NOR:  alu_out = ~(a | b);
            OP_LUI:  alu_out = {b[15:0], 16'd0}; 
            
            OP_SLT: begin
                // SLT 逻辑：如果 a < b (有符号)，则 alu_out = 1
                // 考虑溢出情况：(a[31] != b[31]) ? a[31] : ksa_sum[31] ^ overflow;
                alu_out = (a[31] != b[31]) ? {31'd0, a[31]} : {31'd0, ksa_sum[31]};
            end

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

    // --- 状态标志反馈 ---
    assign ready = (alu_op == OP_MUL) ? mul_ready :
                   (alu_op == OP_DIV) ? div_ready : 1'b1;

    assign zero  = (alu_out == 32'd0); 

endmodule