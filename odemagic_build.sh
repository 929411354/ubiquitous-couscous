#!/bin/bash
# ====== Codemagic构建脚本 ======
# 用法：设置环境变量后运行此脚本
# 需要安装 jq (macOS: brew install jq)

# === 参数配置 ===
export CM_API_KEY="YRAU6tGcqouHDJ-AmbQi8A-aoU1pHsDMMR3ZQUJalSI"  # 替换为您的API密钥
export CM_APP_ID="687e3ce724817b83deea48d7"           # 应用ID(来自URL)
export CM_WORKFLOW_ID="ubiquitous-couscous"          # 工作流名称
export IPA_PATH="build/ios/ipa/Runner.ipa"           # IPA文件路径(默认Flutter位置)
export BRANCH="main"                                 # 构建分支

# === 启动Codemagic构建 ===
echo "🛠️ 启动Codemagic构建..."
RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CM_API_KEY" \
  -d "{
    \"appId\": \"$CM_APP_ID\",
    \"workflowId\": \"$CM_WORKFLOW_ID\",
    \"branch\": \"$BRANCH\"
  }" \
  "https://api.codemagic.io/builds"
)

# === 处理响应 ===
BUILD_ID=$(echo "$RESPONSE" | jq -r '.buildId')

# === 错误检查 ===
if [ -z "$BUILD_ID" ] || [ "$BUILD_ID" = "null" ]; then
  echo "❌ 构建启动失败！错误信息："
  echo "$RESPONSE" | jq -r '.error.message' 2>/dev/null || echo "$RESPONSE"
  exit 1
fi

echo "✅ 构建已启动! ID: $BUILD_ID"
echo "🔗 查看构建状态: https://codemagic.io/app/$CM_APP_ID/build/$BUILD_ID"

# === 上传IPA文件 ===
if [ ! -f "$IPA_PATH" ]; then
  echo "⚠️ 找不到IPA文件: $IPA_PATH"
  echo "ℹ️ 尝试搜索替代位置..."
  
  # 自动搜索IPA文件
  ALTERNATIVE_PATH=$(find . -name "*.ipa" | head -1)
  if [ -n "$ALTERNATIVE_PATH" ]; then
    IPA_PATH="$ALTERNATIVE_PATH"
    echo "✅ 找到替代文件: $IPA_PATH"
  else
    echo "❌ 未找到任何IPA文件"
    exit 1
  fi
fi

echo "📤 上传IPA文件: $IPA_PATH"
UPLOAD_RESPONSE=$(curl -w "%{http_code}" -s -o /dev/null -X POST \
  -H "Authorization: Bearer $CM_API_KEY" \
  -F "file=@$IPA_PATH" \
  "https://api.codemagic.io/builds/$BUILD_ID/artifacts"
)

if [ "$UPLOAD_RESPONSE" -eq 200 ]; then
  echo "✅ IPA文件上传成功!"
else
  echo "❌ IPA上传失败! 状态码: $UPLOAD_RESPONSE"
  exit 1
fi
