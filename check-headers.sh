#!/bin/bash

# 检查服务器响应头配置脚本
# 使用方法: ./check-headers.sh

URL="https://xhh-9ga2urkqb9549415-1393124641.tcloudbaseapp.com"

echo "=========================================="
echo "检查服务器响应头配置"
echo "=========================================="
echo "URL: $URL"
echo ""

# 检查 curl 是否可用
if ! command -v curl &> /dev/null; then
    echo "❌ 错误: 未找到 curl 命令"
    echo "请安装 curl 或使用浏览器开发者工具检查"
    exit 1
fi

echo "正在获取响应头..."
echo ""

# 获取响应头（强制不使用缓存，获取完整响应）
HEADERS=$(curl -I -s -H "Cache-Control: no-cache" -H "Pragma: no-cache" "$URL")

# 显示所有响应头
echo "--- 完整响应头 ---"
echo "$HEADERS"
echo ""

# 检查 Content-Type
CONTENT_TYPE=$(echo "$HEADERS" | grep -i "content-type" | head -1)

echo "--- Content-Type 检查 ---"
if [ -z "$CONTENT_TYPE" ]; then
    echo "❌ 警告: 未找到 Content-Type 响应头"
else
    echo "找到: $CONTENT_TYPE"
    
    # 检查是否为 text/html
    if echo "$CONTENT_TYPE" | grep -qi "text/html"; then
        echo "✅ Content-Type 正确！包含 'text/html'"
    else
        echo "❌ Content-Type 不正确！应该是 'text/html; charset=UTF-8'"
        echo "   当前值: $CONTENT_TYPE"
    fi
fi

echo ""

# 检查 Content-Disposition（如果存在，可能被识别为下载）
CONTENT_DISPOSITION=$(echo "$HEADERS" | grep -i "content-disposition" | head -1)
if [ -n "$CONTENT_DISPOSITION" ]; then
    echo "--- Content-Disposition 检查 ---"
    echo "找到: $CONTENT_DISPOSITION"
    if echo "$CONTENT_DISPOSITION" | grep -qi "attachment"; then
        echo "⚠️  警告: 包含 'attachment'，可能被识别为文件下载"
    else
        echo "✅ Content-Disposition 正常"
    fi
    echo ""
fi

# 检查状态码
STATUS_CODE=$(echo "$HEADERS" | grep -i "HTTP" | head -1 | awk '{print $2}')
echo "--- 状态码 ---"
echo "HTTP 状态: $STATUS_CODE"
if [ "$STATUS_CODE" = "200" ]; then
    echo "✅ 状态码正常"
else
    echo "⚠️  状态码: $STATUS_CODE"
fi

echo ""
echo "=========================================="
echo "检查完成"
echo "=========================================="
echo ""
echo "如果 Content-Type 不正确，需要修改服务器配置："
echo "1. 联系腾讯云 CloudBase 技术支持"
echo "2. 检查服务器 MIME 类型配置"
echo "3. 确保 HTML 文件返回 'text/html; charset=UTF-8'"

