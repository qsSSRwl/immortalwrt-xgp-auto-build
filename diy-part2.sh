#!/bin/bash
# -----------------------------------------------------------------------------
# TurboACC 集成脚本
# 作用: 下载并执行 turboacc 源码安装脚本
# -----------------------------------------------------------------------------

echo "Running diy-part2.sh to install TurboACC..."

# 1. 下载并执行 TurboACC 安装脚本
# 注意：这会修改 firewall4, nftables 等核心组件，请确保没有其他脚本冲突
curl -sSL https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh

# 2. (可选) 强制在 .config 中启用插件
# 如果你不希望在 menuconfig 手动勾选，可以取消下面几行的注释
# echo "CONFIG_PACKAGE_luci-app-turboacc=y" >> .config
# echo "CONFIG_PACKAGE_luci-app-turboacc-include-bbr-cca=y" >> .config
# echo "CONFIG_PACKAGE_luci-app-turboacc-include-shortcut-fe=y" >> .config
# echo "CONFIG_PACKAGE_luci-app-turboacc-include-pdnsd=y" >> .config

echo "TurboACC installation script finished."
