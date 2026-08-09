`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: top_cpu
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

module top_cpu (
    input  wire        clk,
    input  wire        rst_n,
    output wire [31:0] debug_pc,
    output wire [31:0] debug_alu_out
);

    // --- 内部互连信号 ---
    wire [3:0] alu_op;
    wire       alu_start;
    wire       reg_write;
    wire       mem_write;
    wire       mem_to_reg;
    wire       alu_src_b;
    wire [1:0] pc_src;
    wire       reg_dst;
    wire       i_or_d;
    wire       pc_write_sig; 
    wire       ir_write_sig;

    wire [5:0] opcode;
    wire       alu_ready;
    wire       alu_zero;
    wire [2:0] current_state;    

    wire [31:0] mem_addr;
    wire [31:0] mem_din;
    wire [31:0] mem_dout;

    // --- 1. 实例化控制单元 ---
    control_unit ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .opcode(opcode),
        .alu_ready(alu_ready),
        .alu_zero(alu_zero),
        .current_state(current_state),   
        
        .reg_write(reg_write),
        .mem_write(mem_write),
        .alu_op(alu_op),
        .alu_start(alu_start),
        .mem_to_reg(mem_to_reg),
        .alu_src_b(alu_src_b),
        .pc_src(pc_src),
        .reg_dst(reg_dst),
        .i_or_d(i_or_d),
        .pc_write(pc_write_sig), 
        .ir_write(ir_write_sig)  
    );

    // --- 2. 实例化数据通路 ---
    datapath dp (
        .clk(clk),
        .rst_n(rst_n),
        .alu_op(alu_op),
        .alu_start(alu_start),
        .reg_write(reg_write),
        .mem_to_reg(mem_to_reg),
        .alu_src_b(alu_src_b),
        .pc_src(pc_src),
        .reg_dst(reg_dst),
        .pc_write(pc_write_sig), 
        .ir_write(ir_write_sig), 
        .i_or_d(i_or_d),
        .state(current_state),           
        
        .opcode(opcode),
        .alu_ready(alu_ready),
        .alu_zero(alu_zero),
        
        .mem_dout(mem_dout),
        .mem_addr(mem_addr),
        .mem_din(mem_din),
        .pc_out(debug_pc),
        .alu_result(debug_alu_out)
    );

    // --- 3. 存储器 ---
    data_mem memory (
        .clk(clk),
        .we(mem_write),
        .addr(mem_addr),
        .din(mem_din),
        .dout(mem_dout)
    );

endmodule