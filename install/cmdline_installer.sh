#!/usr/bin/env bash

APP_HOME="${HOME}/.cabbage_toolkit"
APP_CODE_REPOSITORY="https://github.com/AkaDaiki/cabbage-toolkit"
DESKTOP_DIR=$(xdg-user-dir DESKTOP 2>/dev/null || echo "${HOME}/Desktop")
DESKTOP_FILE="${DESKTOP_DIR}/大白菜工具箱.desktop"

main_func() {
  # 检查是否已安装
  if [[ -d "${APP_HOME}/program" ]]; then
    zenity --width="320" --question --text="检测到之前已安装过大白菜工具箱，是否重新安装？"
    result="$?"
    if [[ "${result}" != "0" ]]; then
      exit 0
    fi
    rm -rf "${APP_HOME}/program"
  fi

  mkdir -p "${APP_HOME}/program"

  # 克隆仓库
  echo "正在从 GitHub 下载大白菜工具箱..."
  git clone --depth=1 ${APP_CODE_REPOSITORY} "${APP_HOME}/program/cabbage-toolkit" >/dev/null 2>&1

  if [[ $? -ne 0 ]]; then
    zenity --width="320" --error --text="❌ 下载失败，请检查网络连接。"
    exit 1
  fi

  # 检查 .desktop 文件是否存在
  if [[ -f "${APP_HOME}/program/cabbage-toolkit/install/cabbage.desktop" ]]; then
    mkdir -p "${DESKTOP_DIR}"
    cp -f "${APP_HOME}/program/cabbage-toolkit/install/cabbage.desktop" "${DESKTOP_FILE}"

    # 自动修正执行权限
    chmod +x "${DESKTOP_FILE}"

    # 确保图标可见
    if [[ -f "${APP_HOME}/program/cabbage-toolkit/program/icon.png" ]]; then
      ICON_PATH="${APP_HOME}/program/cabbage-toolkit/program/icon.png"
      sed -i "s|^Icon=.*|Icon=${ICON_PATH}|g" "${DESKTOP_FILE}" 2>/dev/null
    fi

    zenity --width="320" --info --text="✅ 安装完成！\n\n请在桌面找到『大白菜工具箱』图标并右键 → 允许启动。"
    echo "install ok!"
  else
    zenity --width="320" --error --text="⚠️ 未找到 cabbage.desktop 文件，请确认仓库结构是否包含 install/cabbage.desktop。"
    exit 1
  fi
}

# 禁止以 root 身份运行
if [[ $EUID -eq 0 || -n "$SUDO_USER" ]]; then
  zenity --width="320" --error --text="请使用普通用户身份执行脚本。"
  exit 1
fi

main_func