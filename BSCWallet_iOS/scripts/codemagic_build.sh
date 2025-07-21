#!/bin/bash
# codemagic_build.sh
# 用于在本地触发Codemagic构建并上传IPA文件

# === 配置参数 ===
export CM_API_KEY="YOUR_API_KEY"  # 替换为您的API密钥
export CM_APP_ID="YOUR_APP_ID"    # 替换为Codemagic中的应用ID
export CM_WORKFLOW_ID="ios-workflow"   # 替换为您的工作流名称
export IPA_PATH="path/to/YourApp.ipa"   # 替换为IPA文件路径

# === 启动构建 ===
RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CM_API_KEY" \
  -d @- <<EOF
{
  "appId": "$CM_APP_ID",
  "workflowId": "$CM_WORKFLOW_ID",
  "branch": "main"
}
EOF
)

# === 处理响应 ===
BUILD_ID=$(echo "$RESPONSE" | jq -r '.buildId')
if [ -z "$BUILD_ID" ] || [ "$BUILD_ID" = "null" ]; then
  echo "❌ 构建启动失败:"
  echo "$RESPONSE" | jq .
  exit 1
fi

echo "✅ 构建启动成功! ID: $BUILD_ID"
echo "👉 查看构建状态: https://codemagic.io/app/$CM_APP_ID/build/$BUILD_ID"

# === 上传IPA文件 ===
if [ ! -f "$IPA_PATH" ]; then
  echo "❌ IPA文件不存在: $IPA_PATH"
  exit 1
fi

echo "📤 正在上传IPA文件..."
UPLOAD_RESPONSE=$(curl -i -X POST \
  -H "Authorization: Bearer $CM_API_KEY" \
  -F "file=@$IPA_PATH" \
  "https://api.codemagic.io/builds/$BUILD_ID/artifacts" 2>/dev/null)

# 检查上传状态
if echo "$UPLOAD_RESPONSE" | grep -q "HTTP/1.1 200"; then
  echo "✅ IPA文件上传完成"
else
  echo "❌ IPA上传失败"
  echo "$UPLOAD_RESPONSE"
  exit 1
fi
