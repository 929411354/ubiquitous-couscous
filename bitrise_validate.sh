#!/bin/bash
# 验证关键文件是否存在
echo "=== 文件存在性验证 ==="
echo "工作目录: $PWD"

# 检查 Podfile
PODFILE_PATH="ios/Podfile"
if [ -f "$PODFILE_PATH" ]; then
  echo "✅ 找到 Podfile: $PODFILE_PATH"
else
  echo "❌ 错误：$PODFILE_PATH 不存在！"
  exit 1  # 主动报错中断构建
fi

# 检查 Gemfile
if [ -f "Gemfile" ]; then
  echo "✅ 找到 Gemfile"
else
  echo "⚠️ 警告：Gemfile 缺失，将自动创建..."
  echo "source 'https://rubygems.org'" > Gemfile
  echo "gem 'cocoapods', '2.4.2'" >> Gemfile
fi

echo "=== 验证通过 ==="
