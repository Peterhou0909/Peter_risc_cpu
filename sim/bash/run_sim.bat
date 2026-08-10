@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ============================================================
:: Peter RISC CPU - Windows 一键运行仿真脚本
:: 用法: run_sim.bat [模块名]
:: 模块名: adder, subtractor, multiplier, divider, alu, mem, reg, core, all
:: ============================================================

:: 获取脚本所在目录的父目录（项目根目录）
set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%..\..

:: 定义目录
set VCD_DIR=%PROJECT_ROOT%\sim\vcd
set RTL_ALU=%PROJECT_ROOT%\rtl\ALU
set RTL_CORE=%PROJECT_ROOT%\rtl\core
set RTL_STORAGE=%PROJECT_ROOT%\rtl\storage
set TB_ALU=%PROJECT_ROOT%\tb\ALU
set TB_CORE=%PROJECT_ROOT%\tb\core
set TB_STORAGE=%PROJECT_ROOT%\tb\storage

:: 创建 VCD 目录
if not exist "%VCD_DIR%" mkdir "%VCD_DIR%"

:: ============================================================
:: 显示帮助信息
:: ============================================================
:show_help
echo.
echo 用法: run_sim.bat [模块名]
echo.
echo 模块名:
echo   adder        - Kogge-Stone 加法器
echo   subtractor   - 减法器
echo   multiplier   - 乘法器
echo   divider      - 除法器
echo   alu          - ALU 顶层
echo   mem          - 数据存储器 (data_mem)
echo   reg          - 寄存器堆 (reg_file)
echo   core         - CPU 顶层 (top_cpu)
echo   all          - 运行所有仿真 (默认)
echo.
echo 示例:
echo   run_sim.bat alu      # 只运行 ALU 仿真
echo   run_sim.bat core     # 只运行 CPU 仿真
echo   run_sim.bat all      # 运行所有仿真
echo.
goto :eof

:: ============================================================
:: 函数: 运行单个仿真
:: ============================================================
:run_sim
set exe_name=%1
set src_files=%2
set tb_file=%3
set vcd_file=%4

echo.
echo [编译] %exe_name%

:: 编译
iverilog -o "%VCD_DIR%\%exe_name%" %src_files% "%tb_file%"
if %errorlevel% neq 0 (
    echo [错误] 编译失败: %exe_name%
    exit /b 1
)

echo [成功] 编译完成: %exe_name%

:: 运行仿真
echo [运行] 仿真: %exe_name%
cd /d "%VCD_DIR%" && vvp %exe_name%
if %errorlevel% neq 0 (
    echo [错误] 仿真失败: %exe_name%
    exit /b 1
)

echo [成功] 仿真完成: %exe_name%
echo [波形] %VCD_DIR%\%vcd_file%
echo.
exit /b 0

:: ============================================================
:: 各模块仿真函数
:: ============================================================
:run_adder
call :run_sim "tb_adder" "%RTL_ALU%\adder_kogger_stone.v" "%TB_ALU%\tb_adder_kogger_stone.v" "dump_adder.vcd"
exit /b

:run_subtractor
call :run_sim "tb_subtractor" "%RTL_ALU%\subtractor.v" "%TB_ALU%\tb_subtractor.v" "dump_sub.vcd"
exit /b

:run_multiplier
call :run_sim "tb_multiplier" "%RTL_ALU%\multiplier.v" "%TB_ALU%\tb_multiplier.v" "dump_mul.vcd"
exit /b

:run_divider
call :run_sim "tb_divider" "%RTL_ALU%\divider.v" "%TB_ALU%\tb_divider.v" "dump_div.vcd"
exit /b

:run_alu
call :run_sim "tb_alu_top" "%RTL_ALU%\adder_kogger_stone.v %RTL_ALU%\subtractor.v %RTL_ALU%\multiplier.v %RTL_ALU%\divider.v %RTL_ALU%\alu_top.v" "%TB_ALU%\tb_alu_top.v" "dump_alu.vcd"
exit /b

:run_mem
call :run_sim "tb_mem" "%RTL_STORAGE%\mem.v" "%TB_STORAGE%\tb_mem.v" "dump_mem.vcd"
exit /b

:run_reg
call :run_sim "tb_reg" "%RTL_STORAGE%\reg.v" "%TB_STORAGE%\tb_reg.v" "dump_reg.vcd"
exit /b

:run_core
call :run_sim "tb_core" "%RTL_ALU%\adder_kogger_stone.v %RTL_ALU%\subtractor.v %RTL_ALU%\multiplier.v %RTL_ALU%\divider.v %RTL_ALU%\alu_top.v %RTL_STORAGE%\mem.v %RTL_STORAGE%\reg.v %RTL_CORE%\control_unit.v %RTL_CORE%\datapath.v %RTL_CORE%\top_cpu.v" "%TB_CORE%\tb_core.v" "cpu_sim.vcd"
exit /b

:run_all
echo.
echo ========================================
echo   运行所有仿真测试...
echo ========================================
echo.

set failed=0
set total=0

call :run_adder
if %errorlevel% neq 0 set /a failed+=1
set /a total+=1
echo ---

call :run_subtractor
if %errorlevel% neq 0 set /a failed+=1
set /a total+=1
echo ---

call :run_multiplier
if %errorlevel% neq 0 set /a failed+=1
set /a total+=1
echo ---

call :run_divider
if %errorlevel% neq 0 set /a failed+=1
set /a total+=1
echo ---

call :run_alu
if %errorlevel% neq 0 set /a failed+=1
set /a total+=1
echo ---

call :run_mem
if %errorlevel% neq 0 set /a failed+=1
set /a total+=1
echo ---

call :run_reg
if %errorlevel% neq 0 set /a failed+=1
set /a total+=1
echo ---

call :run_core
if %errorlevel% neq 0 set /a failed+=1
set /a total+=1
echo ---

echo.
echo ========================================
echo   测试结果汇总
echo ========================================
echo 总测试数: %total%
set /a pass=%total%-%failed%
echo 通过: %pass%
echo 失败: %failed%
if %failed%==0 (
    echo [成功] 所有测试通过!
) else (
    echo [失败] 有 %failed% 个测试失败!
)
echo.
exit /b

:: ============================================================
:: 主逻辑
:: ============================================================
if "%1"=="" goto run_all
if "%1"=="all" goto run_all
if "%1"=="adder" goto run_adder
if "%1"=="subtractor" goto run_subtractor
if "%1"=="multiplier" goto run_multiplier
if "%1"=="divider" goto run_divider
if "%1"=="alu" goto run_alu
if "%1"=="mem" goto run_mem
if "%1"=="reg" goto run_reg
if "%1"=="core" goto run_core
if "%1"=="help" goto show_help
if "%1"=="-h" goto show_help
if "%1"=="--help" goto show_help

echo [错误] 未知模块 '%1'
goto show_help