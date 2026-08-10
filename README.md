# Peter RISC CPU

一个基于 Verilog 实现的 32 位 RISC CPU，支持五级流水线，包含完整的 ALU、寄存器堆、数据存储器和控制单元。

## 特性

- 32 位 RISC 架构
- 支持 16 条指令：ADD, SUB, MUL, DIV, AND, OR, XOR, NOR, SLT, LUI, ADDI, ANDI, LW, SW, BEQ, BNE, J
- 模块化设计：ALU、寄存器堆、数据存储器、控制单元
- 支持 Mac 和 Windows 跨平台仿真

## 配置

详见setup.md

## 目录结构

Peter_risc_cpu
├── doc
│ └── datapath.png
├── README.md
├── rtl
│ ├── ALU
│ │ ├── adder_kogger_stone.v
│ │ ├── alu_top.v
│ │ ├── divider.v
│ │ ├── multiplier.v
│ │ └── subtractor.v
│ ├── core
│ │ ├── control_unit.v
│ │ ├── datapath.v
│ │ └── top_cpu.v
│ └── storage
│ ├── mem.v
│ └── reg.v
├── sim
│ ├── bash
│ │ ├── run_sim.bat
│ │ └── run_sim.sh
│ └── vcd
│ ├── dump_add.vcd
│ ├── dump_alu_top.vcd
│ ├── dump_core.vcd
│ ├── dump_div.vcd
│ ├── dump_mem.vcd
│ ├── dump_mul.vcd
│ ├── dump_reg.vcd
│ └── dump_sub.vcd
└── tb
├── ALU
│ ├── tb_adder_kogger_stone.v
│ ├── tb_alu_top.v
│ ├── tb_divider.v
│ ├── tb_multiplier.v
│ └── tb_subtractor.v
├── core
│ └── tb_core.v
└── storage
├── tb_mem.v
└── tb_reg.v
