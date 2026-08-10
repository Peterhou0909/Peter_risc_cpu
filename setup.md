# Peter RISC CPU - 仿真环境配置指南

## 项目简介

这是一个基于 Verilog 的 RISC CPU 实现，支持在 Mac 和 Windows 上运行仿真。

---

## 系统要求

| 项目     | Mac                              | Windows                        |
| -------- | -------------------------------- | ------------------------------ |
| 操作系统 | macOS 11+ (Big Sur)              | Windows 10/11                  |
| 芯片     | Intel 或 Apple Silicon           | x86_64                         |
| 必需工具 | Homebrew, Icarus Verilog, Surfer | Icarus Verilog, GTKWave/Surfer |

---

## Mac 用户配置

### 1. 安装 Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. 安装依赖

```bash
brew install icarus-verilog
brew install surfer
```

### 3. 验证安装

```bash
iverilog -v
surfer --version
```

### 4.运行仿真

```bash
cd /path/to/Peter_risc_cpu
chmod +x sim/bash/run_sim.sh
./sim/bash/run_sim.sh all
```

## Windows 用户配置

### 1. 安装 Icarus Verilog

- 方法一：使用安装包（推荐）

访问 https://bleyer.org/icarus/
下载最新版 verilog-\*-x64_setup.exe
双击安装，记住安装路径（如 C:\iverilog）
安装完成后，将 C:\iverilog\bin 添加到系统 PATH

- 方法二：使用 MSYS2

```bash
pacman -S mingw-w64-x86_64-iverilog
```

### 2. 安装 GTKWave（Windows 推荐）

访问 http://gtkwave.sourceforge.net/
下载 Windows 版本安装包
双击安装，将安装目录的 bin 路径添加到系统 PATH

### 3. 验证安装

打开 命令提示符 (cmd) 或 PowerShell，运行：

```cmd
iverilog -v
gtkwave --version
```

### 4. 运行仿真

```cmd
cd C:\path\to\Peter_risc_cpu
sim\bash\run_sim.bat all
```

运行单个模块

模块｜ Mac ｜Windows
加法器｜ ./run_sim.sh adder ｜run_sim.bat adder
减法器 ｜./run_sim.sh subtractor｜ run_sim.bat subtractor
乘法器｜ ./run_sim.sh multiplier ｜run_sim.bat multiplier
除法器｜./run_sim.sh divider ｜run_sim.bat divider
ALU ｜./run_sim.sh alu ｜run_sim.bat alu
存储器｜ ./run_sim.sh mem ｜run_sim.bat mem
寄存器堆｜ ./run_sim.sh reg ｜run_sim.bat reg
CPU ｜./run_sim.sh core ｜run_sim.bat core
全部｜ ./run_sim.sh all｜ run_sim.bat all

## 查看波形

### Mac (Surfer)

```bash
surfer sim/vcd/cpu_sim.vcd
Windows (GTKWave)
```

```cmd
gtkwave sim/vcd/cpu_sim.vcd
```

### 使用 VS Code（可选）

安装 VS Code
安装 Verilog-HDL/SystemVerilog 扩展
打开项目文件夹
按 Cmd+Shift+P (Mac) / Ctrl+Shift+P (Windows)
输入 Tasks: Run Task
选择对应的仿真任务
