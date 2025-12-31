#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
检查服务器响应头配置脚本
使用方法: python3 check-headers.py
"""

import sys
import urllib.request
import urllib.error

URL = "https://xhh-9ga2urkqb9549415-1393124641.tcloudbaseapp.com"

def check_headers():
    print("=" * 50)
    print("检查服务器响应头配置")
    print("=" * 50)
    print(f"URL: {URL}")
    print()
    
    try:
        # 创建请求
        req = urllib.request.Request(URL)
        req.add_header('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36')
        
        # 发送 HEAD 请求（只获取响应头）
        try:
            response = urllib.request.urlopen(req, timeout=10)
        except urllib.error.HTTPError as e:
            response = e
        
        # 获取响应头
        headers = dict(response.headers)
        
        print("--- 完整响应头 ---")
        for key, value in headers.items():
            print(f"{key}: {value}")
        print()
        
        # 检查 Content-Type
        print("--- Content-Type 检查 ---")
        content_type = headers.get('Content-Type', headers.get('content-type', ''))
        
        if not content_type:
            print("❌ 警告: 未找到 Content-Type 响应头")
        else:
            print(f"找到: Content-Type: {content_type}")
            
            if 'text/html' in content_type.lower():
                print("✅ Content-Type 正确！包含 'text/html'")
                
                if 'charset=utf-8' in content_type.lower() or 'charset=UTF-8' in content_type:
                    print("✅ 字符集设置正确 (UTF-8)")
                else:
                    print("⚠️  建议: 添加 charset=UTF-8")
            else:
                print("❌ Content-Type 不正确！应该是 'text/html; charset=UTF-8'")
                print(f"   当前值: {content_type}")
        
        print()
        
        # 检查 Content-Disposition
        content_disposition = headers.get('Content-Disposition', headers.get('content-disposition', ''))
        if content_disposition:
            print("--- Content-Disposition 检查 ---")
            print(f"找到: Content-Disposition: {content_disposition}")
            if 'attachment' in content_disposition.lower():
                print("⚠️  警告: 包含 'attachment'，可能被识别为文件下载")
            else:
                print("✅ Content-Disposition 正常")
            print()
        
        # 检查状态码
        print("--- 状态码 ---")
        status_code = response.getcode()
        print(f"HTTP 状态: {status_code}")
        if status_code == 200:
            print("✅ 状态码正常")
        else:
            print(f"⚠️  状态码: {status_code}")
        
        print()
        print("=" * 50)
        print("检查完成")
        print("=" * 50)
        print()
        print("如果 Content-Type 不正确，需要修改服务器配置：")
        print("1. 联系腾讯云 CloudBase 技术支持")
        print("2. 检查服务器 MIME 类型配置")
        print("3. 确保 HTML 文件返回 'text/html; charset=UTF-8'")
        
    except urllib.error.URLError as e:
        print(f"❌ 错误: 无法连接到服务器")
        print(f"   详情: {e.reason}")
        print()
        print("请检查：")
        print("1. 网络连接是否正常")
        print("2. URL 是否正确")
        print("3. 服务器是否可访问")
        sys.exit(1)
    except Exception as e:
        print(f"❌ 发生错误: {e}")
        sys.exit(1)

if __name__ == "__main__":
    check_headers()

