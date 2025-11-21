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
