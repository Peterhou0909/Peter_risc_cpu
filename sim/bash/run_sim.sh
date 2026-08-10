# ============================================================
# Peter RISC CPU - 一键运行所有仿真脚本 面向Mac/Linux
# 用法: ./run_sim.sh [模块名]
# 模块名: adder, subtractor, multiplier, divider, alu, mem, reg, core, all
# ============================================================

# 获取脚本所在目录的父目录（项目根目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 定义目录
VCD_DIR="$PROJECT_ROOT/sim/vcd"
RTL_ALU="$PROJECT_ROOT/rtl/ALU"
RTL_CORE="$PROJECT_ROOT/rtl/core"
RTL_STORAGE="$PROJECT_ROOT/rtl/storage"
TB_ALU="$PROJECT_ROOT/tb/ALU"
TB_CORE="$PROJECT_ROOT/tb/core"
TB_STORAGE="$PROJECT_ROOT/tb/storage"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 创建 VCD 目录
mkdir -p "$VCD_DIR"

# ============================================================
# 函数: 运行单个仿真
# 参数: $1=可执行文件名, $2=源文件列表, $3=testbench文件
# ============================================================
run_sim() {
    local exe_name="$1"
    local src_files="$2"
    local tb_file="$3"
    local vcd_file="$4"
    
    echo -e "${BLUE}>>> 编译: $exe_name${NC}"
    
    # 编译
    iverilog -o "$VCD_DIR/$exe_name" $src_files "$tb_file"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ 编译失败: $exe_name${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✓ 编译成功: $exe_name${NC}"
    
    # 运行仿真
    echo -e "${BLUE}>>> 运行仿真: $exe_name${NC}"
    cd "$VCD_DIR" && vvp "$exe_name"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ 仿真失败: $exe_name${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✓ 仿真完成: $exe_name${NC}"
    echo -e "${YELLOW}  波形文件: $VCD_DIR/$vcd_file${NC}"
    echo ""
    return 0
}

# ============================================================
# 显示帮助信息
# ============================================================
show_help() {
    echo "用法: ./run_sim.sh [模块名]"
    echo ""
    echo "模块名:"
    echo "  adder        - Kogge-Stone 加法器"
    echo "  subtractor   - 减法器"
    echo "  multiplier   - 乘法器"
    echo "  divider      - 除法器"
    echo "  alu          - ALU 顶层"
    echo "  mem          - 数据存储器 (data_mem)"
    echo "  reg          - 寄存器堆 (reg_file)"
    echo "  core         - CPU 顶层 (top_cpu)"
    echo "  all          - 运行所有仿真 (默认)"
    echo ""
    echo "示例:"
    echo "  ./run_sim.sh alu      # 只运行 ALU 仿真"
    echo "  ./run_sim.sh core     # 只运行 CPU 仿真"
    echo "  ./run_sim.sh all      # 运行所有仿真"
}

# ============================================================
# 各模块仿真函数
# ============================================================

run_adder() {
    run_sim "tb_adder" \
        "$RTL_ALU/adder_kogger_stone.v" \
        "$TB_ALU/tb_adder_kogger_stone.v" \
        "dump_adder.vcd"
}

run_subtractor() {
    run_sim "tb_subtractor" \
        "$RTL_ALU/subtractor.v" \
        "$TB_ALU/tb_subtractor.v" \
        "dump_sub.vcd"
}

run_multiplier() {
    run_sim "tb_multiplier" \
        "$RTL_ALU/multiplier.v" \
        "$TB_ALU/tb_multiplier.v" \
        "dump_mul.vcd"
}

run_divider() {
    run_sim "tb_divider" \
        "$RTL_ALU/divider.v" \
        "$TB_ALU/tb_divider.v" \
        "dump_div.vcd"
}

run_alu() {
    run_sim "tb_alu_top" \
        "$RTL_ALU/adder_kogger_stone.v $RTL_ALU/subtractor.v $RTL_ALU/multiplier.v $RTL_ALU/divider.v $RTL_ALU/alu_top.v" \
        "$TB_ALU/tb_alu_top.v" \
        "dump_alu.vcd"
}

run_mem() {
    run_sim "tb_mem" \
        "$RTL_STORAGE/mem.v" \
        "$TB_STORAGE/tb_mem.v" \
        "dump_mem.vcd"
}

run_reg() {
    run_sim "tb_reg" \
        "$RTL_STORAGE/reg.v" \
        "$TB_STORAGE/tb_reg.v" \
        "dump_reg.vcd"
}

run_core() {
    run_sim "tb_core" \
        "$RTL_ALU/adder_kogger_stone.v $RTL_ALU/subtractor.v $RTL_ALU/multiplier.v $RTL_ALU/divider.v $RTL_ALU/alu_top.v $RTL_STORAGE/mem.v $RTL_STORAGE/reg.v $RTL_CORE/control_unit.v $RTL_CORE/datapath.v $RTL_CORE/top_cpu.v" \
        "$TB_CORE/tb_core.v" \
        "cpu_sim.vcd"
}

run_all() {
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}  运行所有仿真测试...${NC}"
    echo -e "${YELLOW}========================================${NC}"
    echo ""
    
    local failed=0
    local total=0
    
    for func in run_adder run_subtractor run_multiplier run_divider run_alu run_mem run_reg run_core; do
        total=$((total + 1))
        $func
        if [ $? -ne 0 ]; then
            failed=$((failed + 1))
        fi
        echo "---"
    done
    
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}  测试结果汇总${NC}"
    echo -e "${YELLOW}========================================${NC}"
    echo -e "总测试数: $total"
    echo -e "通过: $((total - failed))"
    echo -e "失败: $failed"
    
    if [ $failed -eq 0 ]; then
        echo -e "${GREEN}✓ 所有测试通过!${NC}"
    else
        echo -e "${RED}✗ 有 $failed 个测试失败!${NC}"
    fi
}

# ============================================================
# 主逻辑
# ============================================================

# 检查是否在正确的目录
if [ ! -d "$PROJECT_ROOT/rtl" ] || [ ! -d "$PROJECT_ROOT/tb" ]; then
    echo -e "${RED}错误: 请在项目根目录下运行此脚本${NC}"
    echo "当前目录: $PROJECT_ROOT"
    exit 1
fi

# 检查参数
case "$1" in
    adder)
        run_adder
        ;;
    subtractor)
        run_subtractor
        ;;
    multiplier)
        run_multiplier
        ;;
    divider)
        run_divider
        ;;
    alu)
        run_alu
        ;;
    mem)
        run_mem
        ;;
    reg)
        run_reg
        ;;
    core)
        run_core
        ;;
    all|"")
        run_all
        ;;
    -h|--help|help)
        show_help
        ;;
    *)
        echo -e "${RED}错误: 未知模块 '$1'${NC}"
        show_help
        exit 1
        ;;
esac