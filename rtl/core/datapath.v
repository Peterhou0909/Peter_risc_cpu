`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: datapath
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

module datapath (
    input  wire        clk,
    input  wire        rst_n,

    // 来自控制单元的控制信号
    input  wire [3:0]  alu_op,
    input  wire        alu_start,
    input  wire        reg_write,
    input  wire        mem_to_reg,
    input  wire        alu_src_b,
    input  wire [1:0]  pc_src,
    input  wire        reg_dst,
    input  wire        pc_write,     
    input  wire        i_or_d,     
    input  wire        ir_write,
  
    // 新增：当前状态，用于在EXE阶段锁存ALU结果
    input  wire [2:0]  state,

    // 给控制单元的状态信号
    output wire [5:0]  opcode,
    output wire        alu_ready,
    output wire        alu_zero,

    // 存储器接口
    input  wire [31:0] mem_dout,
    output wire [31:0] mem_addr,
    output wire [31:0] mem_din,
    
    // 调试用输出
    output wire [31:0] pc_out,
    output wire [31:0] alu_result
);

    // 状态常量
    localparam EXE = 3'b010;

    // --- 1. 指令寄存器 ---
    reg [31:0] ir;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) ir <= 32'd0;
        else if (ir_write) ir <= mem_dout; 
    end

    wire [31:0] instr = ir;
    assign opcode = instr[31:26];

    // --- 2. PC 寄存器逻辑 ---
    reg  [31:0] pc;
    wire [31:0] pc_next;

    // 跳转目标计算（pc 已在 IF 阶段更新为当前指令地址+4）
    wire [31:0] imm_ext = {{16{instr[15]}}, instr[15:0]};
    wire [31:0] pc_branch = pc + (imm_ext << 2);   // 基址为 pc
    wire [31:0] pc_jump   = {pc[31:28], instr[25:0], 2'b00}; // 高4位取自 pc

    assign pc_next = (pc_src == 2'b10) ? pc_jump :
                     (pc_src == 2'b01) ? pc_branch : pc + 4;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) pc <= 32'd0;
        else if (pc_write) pc <= pc_next; 
    end

    assign pc_out = pc;

    // --- 3. ALU 结果锁存（用于后续 MEM/WB）---
    wire [31:0] alu_out, alu_out_hi;    // 来自 alu_top
    reg  [31:0] alu_out_reg;            // 锁存器

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            alu_out_reg <= 32'd0;
        end else begin
            // 在 EXE 阶段且 alu_ready 有效时锁存结果
            if (state == EXE && alu_ready) begin
                alu_out_reg <= alu_out;
            end
        end
    end

    // 存储器地址使用锁存结果
    assign mem_addr = i_or_d ? alu_out_reg : pc; 

    // --- 4. 寄存器堆 ---
    wire [31:0] rd1, rd2;
    wire [4:0]  write_reg  = reg_dst ? instr[15:11] : instr[20:16];
    wire [31:0] write_data = mem_to_reg ? mem_dout : alu_out_reg;  // 使用锁存结果

    reg_file rf (
        .clk(clk), .rst_n(rst_n), .we(reg_write),
        .ra1(instr[25:21]), .ra2(instr[20:16]),
        .wa(write_reg), .wd(write_data),
        .rd1(rd1), .rd2(rd2)
    );

    // --- 5. ALU 逻辑 ---
    wire [31:0] alu_in_b = alu_src_b ? imm_ext : rd2;
    alu_top alu_inst (
        .clk(clk), .rst_n(rst_n),
        .alu_op(alu_op), .start(alu_start),
        .a(rd1), .b(alu_in_b),
        .alu_out(alu_out), .alu_out_hi(alu_out_hi),
        .ready(alu_ready), .zero(alu_zero)
    );

    assign alu_result = alu_out;
    assign mem_din = rd2;

endmodule