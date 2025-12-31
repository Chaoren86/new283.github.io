#!/bin/bash

# 强制检查服务器响应头配置脚本（不使用缓存）
# 使用方法: ./check-headers-force.sh

URL="https://xhh-9ga2urkqb9549415-1393124641.tcloudbaseapp.com"

echo "=========================================="
echo "强制检查服务器响应头配置（不使用缓存）"
echo "=========================================="
echo "URL: $URL"
echo ""

# 检查 curl 是否可用
if ! command -v curl &> /dev/null; then
    echo "❌ 错误: 未找到 curl 命令"
    echo "请安装 curl 或使用浏览器开发者工具检查"
    exit 1
fi

echo "正在获取响应头（强制刷新，不使用缓存）..."
echo ""

# 获取响应头（强制不使用缓存）
HEADERS=$(curl -I -s \
    -H "Cache-Control: no-cache" \
    -H "Pragma: no-cache" \
    -H "If-None-Match: *" \
    -H "If-Modified-Since: 0" \
    "$URL")

# 显示所有响应头
echo "--- 完整响应头 ---"
echo "$HEADERS"
echo ""

# 检查 Content-Type
CONTENT_TYPE=$(echo "$HEADERS" | grep -i "content-type" | head -1)

echo "--- Content-Type 检查 ---"
if [ -z "$CONTENT_TYPE" ]; then
    echo "❌ 警告: 未找到 Content-Type 响应头"
    echo "   这可能是导致微信识别为文件的原因！"
else
    echo "找到: $CONTENT_TYPE"
    
    # 检查是否为 text/html
    if echo "$CONTENT_TYPE" | grep -qi "text/html"; then
        echo "✅ Content-Type 正确！包含 'text/html'"
        
        # 检查字符集
        if echo "$CONTENT_TYPE" | grep -qi "charset.*utf-8"; then
            echo "✅ 字符集设置正确 (UTF-8)"
        else
            echo "⚠️  建议: 添加 charset=UTF-8"
        fi
    else
        echo "❌ Content-Type 不正确！应该是 'text/html; charset=UTF-8'"
        echo "   当前值: $CONTENT_TYPE"
        echo "   这是导致微信识别为文件的主要原因！"
    fi
fi

echo ""

# 检查 Content-Disposition（如果存在，可能被识别为下载）
CONTENT_DISPOSITION=$(echo "$HEADERS" | grep -i "content-disposition" | head -1)
if [ -n "$CONTENT_DISPOSITION" ]; then
    echo "--- Content-Disposition 检查 ---"
    echo "找到: $CONTENT_DISPOSITION"
    if echo "$CONTENT_DISPOSITION" | grep -qi "attachment"; then
        echo "❌ 警告: 包含 'attachment'，会被识别为文件下载！"
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
    echo "✅ 状态码正常（获取到完整响应）"
elif [ "$STATUS_CODE" = "304" ]; then
    echo "⚠️  状态码: 304 (Not Modified - 使用缓存)"
    echo "   提示: 如果看到 304，请清除浏览器缓存后重试"
    echo "   或使用: curl -I -H 'Cache-Control: no-cache' $URL"
else
    echo "⚠️  状态码: $STATUS_CODE"
fi

echo ""

# 显示其他重要响应头
echo "--- 其他重要响应头 ---"
ETAG=$(echo "$HEADERS" | grep -i "etag" | head -1)
LAST_MODIFIED=$(echo "$HEADERS" | grep -i "last-modified" | head -1)
CACHE_CONTROL=$(echo "$HEADERS" | grep -i "cache-control" | head -1)

if [ -n "$ETAG" ]; then
    echo "$ETAG"
fi
if [ -n "$LAST_MODIFIED" ]; then
    echo "$LAST_MODIFIED"
fi
if [ -n "$CACHE_CONTROL" ]; then
    echo "$CACHE_CONTROL"
fi

echo ""
echo "=========================================="
echo "检查完成"
echo "=========================================="
echo ""

# 给出诊断结果
if [ -z "$CONTENT_TYPE" ] || ! echo "$CONTENT_TYPE" | grep -qi "text/html"; then
    echo "❌ 问题诊断:"
    echo "   Content-Type 不正确或缺失，这是导致微信识别为文件的主要原因！"
    echo ""
    echo "🔧 解决方案:"
    echo "   1. 联系腾讯云 CloudBase 技术支持"
    echo "   2. 检查服务器 MIME 类型配置"
    echo "   3. 确保 HTML 文件返回 'text/html; charset=UTF-8'"
    echo "   4. 检查是否有 CDN 或代理修改了响应头"
else
    echo "✅ Content-Type 配置正确"
    echo ""
    echo "如果微信仍然识别为文件，可能的原因："
    echo "   1. 微信缓存了旧的响应头（清除微信缓存）"
    echo "   2. URL 格式问题（虽然你的URL没有 .html 后缀）"
    echo "   3. 其他微信特定的识别规则"
fi

