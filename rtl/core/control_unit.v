`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: control_unit
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
`timescale 1ns / 1ps

module control_unit (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [5:0]  opcode,      
    input  wire        alu_ready,   
    input  wire        alu_zero,    
    
    output reg [2:0]   current_state,
    
    // 控制信号
    output reg         reg_write,   
    output reg         mem_write,   
    output reg [3:0]   alu_op,      
    output reg         alu_start,   
    output reg         mem_to_reg,  
    output reg         alu_src_b,   
    output reg [1:0]   pc_src,      
    output reg         pc_write,    
    output reg         reg_dst,     
    output reg         i_or_d,
    output reg         ir_write    
);

    // 状态定义 
    localparam IF  = 3'b000;
    localparam ID  = 3'b001;
    localparam EXE = 3'b010;
    localparam MEM = 3'b011;
    localparam WB  = 3'b100;

    // 指令操作码定义 
    localparam OP_RTYPE = 6'h00; 
    localparam OP_ADD   = 6'h01; localparam OP_SUB   = 6'h02;
    localparam OP_MUL   = 6'h03; localparam OP_DIV   = 6'h04;
    localparam OP_AND   = 6'h05; localparam OP_OR    = 6'h06;
    localparam OP_XOR   = 6'h07; localparam OP_NOR   = 6'h08;
    localparam OP_SLT   = 6'h09;
    localparam OP_ADDI  = 6'h0A; localparam OP_ANDI  = 6'h0B;
    localparam OP_LUI   = 6'h0C; localparam OP_LW    = 6'h0D;
    localparam OP_SW    = 6'h0E; localparam OP_BEQ   = 6'h0F;
    localparam OP_BNE   = 6'h10;
    localparam OP_J     = 6'h11;

    reg [2:0] next_state;

    // 1. 状态转移逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) current_state <= IF;
        else        current_state <= next_state;
    end

    // 2. 下一状态判断
    always @(*) begin
        case (current_state)
            IF:  next_state = ID;
            ID:  begin
                if (opcode == OP_J) next_state = IF;
                else                next_state = EXE;
            end
            EXE: begin
                if (!alu_ready) next_state = EXE;
                else if (opcode == OP_BEQ || opcode == OP_BNE) next_state = IF;
                else if (opcode == OP_LW || opcode == OP_SW)   next_state = MEM;
                else next_state = WB;
            end
            MEM: begin
                if (opcode == OP_LW) next_state = WB;
                else                 next_state = IF;
            end
            WB:      next_state = IF;
            default: next_state = IF;
        endcase
    end

    // 3. 控制信号生成
    always @(*) begin
        // 默认值清零
        reg_write = 0; mem_write = 0; alu_start = 0;
        mem_to_reg = 0; pc_write = 0; alu_op = 4'b0000;
        alu_src_b = 0; pc_src = 2'b00; reg_dst = 0; 
        i_or_d = 0; ir_write = 0;

        case (current_state)
            IF: begin
                i_or_d   = 0;
                ir_write = 1;
                pc_write = 1;
                pc_src   = 2'b00;
            end

            ID: begin
                if (opcode == OP_J) begin
                    pc_src   = 2'b10;
                    pc_write = 1;
                end
            end

            EXE: begin
                case (opcode)
                    OP_ADD, OP_ADDI, OP_LW, OP_SW: alu_op = 4'b0000;
                    OP_SUB, OP_BEQ,  OP_BNE:       alu_op = 4'b0001;
                    OP_AND, OP_ANDI:               alu_op = 4'b0010;
                    OP_OR:                         alu_op = 4'b0011;
                    OP_XOR:                        alu_op = 4'b0100;
                    OP_NOR:                        alu_op = 4'b0101;
                    OP_SLT:                        alu_op = 4'b0110;
                    OP_LUI:                        alu_op = 4'b0111;
                    OP_MUL:                        alu_op = 4'b1000;
                    OP_DIV:                        alu_op = 4'b1001;
                endcase

                if (opcode >= OP_ADDI && opcode <= OP_SW) alu_src_b = 1;

                if (opcode == OP_MUL || opcode == OP_DIV) begin
                    alu_start = alu_ready;   // 空闲时启动，计算时保持0
                end

                // 分支跳转
                if ((opcode == OP_BEQ && alu_zero) || (opcode == OP_BNE && !alu_zero)) begin
                    pc_src   = 2'b01;
                    pc_write = 1;
                end
            end

            MEM: begin
                i_or_d = 1;
                if (opcode == OP_SW) mem_write = 1;
            end

            WB: begin
                reg_write = 1;
                if (opcode == OP_LW) mem_to_reg = 1;
                if (opcode <= OP_SLT) reg_dst = 1;
                else                  reg_dst = 0;
            end
        endcase
    end

endmodule