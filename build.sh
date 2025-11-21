#!/bin/bash
cd immortalwrt
echo "update feeds"
./scripts/feeds update -a || { echo "update feeds failed"; exit 1; }
echo "install feeds"
./scripts/feeds install -a || { echo "install feeds failed"; exit 1; }
./scripts/feeds install -a -f -p qmodem || { echo "install qmodem feeds failed"; exit 1; }
cat ../xgp.config > .config
echo "make defconfig"
make defconfig || { echo "defconfig failed"; exit 1; }
echo "diff initial config and new config:"
diff ../xgp.config .config
echo "diff initial config and new config (from old config only):"
diff ../xgp.config .config | grep -e "^<" | grep -v "^< #"
echo "diff initial config and new config (from new config only):"
diff ../xgp.config .config | grep -e "^>" | grep -v "^> #"
echo "check device exist"
grep -Fxq "CONFIG_TARGET_rockchip_armv8_DEVICE_nlnet_xiguapi-v3=y" .config || exit 1
echo apply qmodem default setting
#cat feeds/qmodem/luci/luci-app-qmodem/root/etc/config/qmodem > files/etc/config/qmodem
cat feeds/qmodem/application/qmodem/files/etc/config/qmodem > files/etc/config/qmodem
cat >> files/etc/config/qmodem << EOF

config modem-slot 'wwan'
	option type 'usb'
	option slot '8-1'
	option net_led 'blue:net'
	option alias 'wwan'

config modem-slot 'mpcie1'
	option type 'pcie'
	option slot '0001:11:00.0'
	option net_led 'blue:net'
	option alias 'mpcie1'

config modem-slot 'mpcie2'
	option type 'pcie'
	option slot '0002:21:00.0'
	option net_led 'blue:net'
	option alias 'mpcie2'
EOF

year=$(date +%y)
month=$(date +%-m)
day=$(date +%-d)
hour=$(date +%-H)
zz_build_date=$(date "+%Y-%m-%d %H:%M:%S %z")
zz_build_uuid=$(uuidgen)

echo "zz_build_date=${zz_build_date}"
echo "zz_build_uuid=${zz_build_uuid}"
cat >> files/etc/uci-defaults/zzzz-version << EOF
echo "DISTRIB_REVISION='R${year}.${month}.${day}.${hour}'" >> /etc/openwrt_release
/bin/sync
EOF
echo "ZZ_BUILD_ID='${zz_build_uuid}'" > files/etc/zz_build_id
echo "ZZ_BUILD_HOST='$(hostname)'" >> files/etc/zz_build_id
echo "ZZ_BUILD_USER='$(whoami)'" >> files/etc/zz_build_id
echo "ZZ_BUILD_DATE='${zz_build_date}'" >> files/etc/zz_build_id
echo "ZZ_BUILD_REPO_HASH='$(cd .. && git rev-parse HEAD)'" >> files/etc/zz_build_id
echo "ZZ_BUILD_LEDE_HASH='$(git rev-parse HEAD)'" >> files/etc/zz_build_id

# ---- turboacc 自动添加（可控） ----
# 默认不启用。要启用请在 GitHub Actions secrets/env 添加 ADD_TURBOACC=1
# 如果想禁用 SFE（软件流量分载），在 env 中加 ADD_TURBOACC_NO_SFE=1
if [ "${ADD_TURBOACC:-0}" = "1" ]; then
  echo ">>> ADD_TURBOACC=1 detected — 自动下载并运行 chenmozhijin/turboacc 的 add_turboacc.sh"
  TMP_SCRIPT="$(mktemp -t add_turboacc.XXXXXX.sh)"
  if curl -fsSL "https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh" -o "${TMP_SCRIPT}"; then
    chmod +x "${TMP_SCRIPT}"
    # 是否传入 --no-sfe
    if [ "${ADD_TURBOACC_NO_SFE:-0}" = "1" ]; then
      echo ">>> 以 --no-sfe 模式运行 add_turboacc.sh"
      bash "${TMP_SCRIPT}" --no-sfe || { echo "ERROR: add_turboacc.sh 返回非零状态"; rm -f "${TMP_SCRIPT}"; exit 1; }
    else
      echo ">>> 以默认（含 sfe）模式运行 add_turboacc.sh"
      bash "${TMP_SCRIPT}" || { echo "ERROR: add_turboacc.sh 返回非零状态"; rm -f "${TMP_SCRIPT}"; exit 1; }
    fi
    rm -f "${TMP_SCRIPT}"
  else
    echo "ERROR: 无法下载 add_turboacc.sh (curl 失败)"
    exit 1
  fi
else
  echo "ADD_TURBOACC 未启用（或为0），跳过 turboacc 自动安装步骤。"
fi
# ---- end turboacc 自动添加 ----

echo "make download"
make download -j8 || { echo "download failed"; exit 1; }
echo "make lede"
make V=0 -j$(nproc) || { echo "make failed"; exit 1; }
