# 腾讯云 CloudBase 路由配置指南

## 📋 可用的文件扩展名选项

### 1. 标准 HTML 扩展名
- `.html` - 最常用，兼容性最好
- `.htm` - 短版本，兼容性好
- `.shtml` - 服务器端包含（如果支持）

### 2. 无扩展名（推荐）⭐
- 完全去掉扩展名，通过路由配置
- 例如：`/index` 而不是 `/index.html`
- 更简洁，更不容易被识别为文件

### 3. 其他选项
- 使用路由重写规则
- 配置索引文档
- 使用重定向规则

---

## 🎯 推荐方案：去掉 HTML 扩展名

### 为什么推荐去掉扩展名？

1. **避免被识别为文件**
   - 没有 `.html` 扩展名，微信更不容易识别为文件下载
   - URL 更简洁专业

2. **更好的 SEO**
   - 更短的 URL
   - 更友好的用户体验

3. **路由灵活性**
   - 可以配置路由规则
   - 支持 RESTful 风格的 URL

---

## 🔧 腾讯云 CloudBase 配置方法

### 方案 1: 使用索引文档（最简单）

#### 配置步骤：

1. **登录腾讯云控制台**
2. **进入 CloudBase → 静态网站托管**
3. **配置索引文档**:
   - 索引文档: `index.html`
   - 错误文档: `index.html` (可选)

#### 效果：
- 访问 `https://xhh-9ga2urkqb9549415-1393124641.tcloudbaseapp.com/` 
  → 自动返回 `index.html`
- 访问 `https://xhh-9ga2urkqb9549415-1393124641.tcloudbaseapp.com/index`
  → 可以配置为返回 `index.html`

### 方案 2: 配置重定向规则

#### 在 CloudBase 控制台配置：

1. **进入静态网站托管 → 重定向规则**
2. **添加规则**:

```json
{
  "source": "/index",
  "target": "/index.html",
  "statusCode": 200,
  "type": "rewrite"
}
```

或者使用通配符：
```json
{
  "source": "/*",
  "target": "/index.html",
  "statusCode": 200,
  "type": "rewrite"
}
```

### 方案 3: 使用 .htaccess（如果支持）

如果 CloudBase 支持 Apache 配置，创建 `.htaccess` 文件：

```apache
# 去掉 .html 扩展名
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^([^\.]+)$ $1.html [NC,L]

# 确保 Content-Type 正确
<IfModule mod_mime.c>
    AddType text/html;charset=UTF-8 .html
    AddType text/html;charset=UTF-8 .htm
    AddCharset UTF-8 .html
    AddCharset UTF-8 .htm
</IfModule>

# 设置默认 Content-Type
<IfModule mod_headers.c>
    Header set Content-Type "text/html; charset=UTF-8"
</IfModule>
```

### 方案 4: 使用 CloudBase 函数（高级）

如果需要更复杂的路由，可以使用 CloudBase 云函数：

```javascript
// 云函数：路由处理
exports.main = async (event, context) => {
    const path = event.path;
    
    // 如果路径没有扩展名，返回 index.html
    if (!path.includes('.')) {
        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'text/html; charset=UTF-8'
            },
            body: require('fs').readFileSync('./index.html', 'utf8')
        };
    }
    
    // 其他路径处理...
};
```

---

## 📝 具体配置示例

### 场景 1: 单页应用（SPA）

**目标**: 所有路径都返回 `index.html`

**配置**:
```json
{
  "rewriteRules": [
    {
      "source": "/*",
      "target": "/index.html",
      "statusCode": 200
    }
  ]
}
```

**效果**:
- `/` → `index.html`
- `/about` → `index.html`
- `/contact` → `index.html`
- 所有路径都返回同一个 HTML 文件

### 场景 2: 去掉扩展名

**目标**: `/index` 访问 `/index.html`

**配置**:
```json
{
  "rewriteRules": [
    {
      "source": "/index",
      "target": "/index.html",
      "statusCode": 200
    }
  ]
}
```

**效果**:
- `/index` → `index.html` (无扩展名)
- `/index.html` → `index.html` (仍然可用)

### 场景 3: 忽略所有 HTML 扩展名

**目标**: 访问 `/page` 自动指向 `/page.html`

**配置**:
```json
{
  "rewriteRules": [
    {
      "source": "/*",
      "target": "/$1.html",
      "statusCode": 200,
      "condition": {
        "fileExists": false
      }
    }
  ]
}
```

---

## ✅ 确保 Content-Type 正确

无论使用哪种方案，都需要确保：

### 1. 服务器响应头
```
Content-Type: text/html; charset=UTF-8
```

### 2. HTML 文件中的 Meta 标签
```html
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta charset="UTF-8">
```

### 3. 文件扩展名映射
确保 CloudBase 正确配置了 MIME 类型：
- `.html` → `text/html; charset=UTF-8`
- `.htm` → `text/html; charset=UTF-8`
- 无扩展名 → `text/html; charset=UTF-8` (通过路由规则)

---

## 🎯 推荐配置（针对你的情况）

### 最佳实践：

1. **使用索引文档**
   - 配置 `index.html` 为索引文档
   - 访问根路径 `/` 自动返回 `index.html`

2. **配置重定向规则**
   ```json
   {
     "rewriteRules": [
       {
         "source": "/index",
         "target": "/index.html",
         "statusCode": 200
       }
     ]
   }
   ```

3. **确保 Content-Type**
   - 联系腾讯云技术支持
   - 确保所有路径（包括重定向后的）都返回正确的 Content-Type

4. **测试不同路径**
   ```bash
   # 测试根路径
   curl -I https://xhh-9ga2urkqb9549415-1393124641.tcloudbaseapp.com/
   
   # 测试 /index
   curl -I https://xhh-9ga2urkqb9549415-1393124641.tcloudbaseapp.com/index
   
   # 测试 /index.html
   curl -I https://xhh-9ga2urkqb9549415-1393124641.tcloudbaseapp.com/index.html
   ```

---

## 🔍 验证配置

### 检查清单：

- [ ] 索引文档配置正确
- [ ] 重定向规则配置正确
- [ ] 所有路径返回正确的 Content-Type
- [ ] 无扩展名路径正常工作
- [ ] 微信能正确识别（清除缓存后测试）

### 测试命令：

```bash
# 测试根路径
curl -I https://xhh-9ga2urkqb9549415-1393124641.tcloudbaseapp.com/

# 测试 /index（如果配置了）
curl -I https://xhh-9ga2urkqb9549415-1393124641.tcloudbaseapp.com/index

# 查看 Content-Type
curl -I https://xhh-9ga2urkqb9549415-1393124641.tcloudbaseapp.com/ | grep -i "content-type"
```

---

## 💡 额外建议

### 1. 使用自定义域名
- 更短的 URL
- 更专业的形象
- 可能避免某些识别问题

### 2. 配置 HTTPS
- 确保使用 HTTPS（你已经有了）
- 微信对 HTTPS 的支持更好

### 3. 优化 URL 结构
- 使用简洁的路径
- 避免过长的 URL
- 使用有意义的路径名

---

## 📞 需要帮助？

如果配置遇到问题：

1. **查看 CloudBase 文档**
   - 静态网站托管配置
   - 重定向规则配置

2. **联系腾讯云技术支持**
   - 说明你的路由配置需求
   - 请求确保 Content-Type 正确

3. **测试和验证**
   - 使用 curl 测试不同路径
   - 在浏览器中测试
   - 在微信中测试

---

## ✅ 总结

**推荐方案**:
1. ✅ 使用索引文档（最简单）
2. ✅ 配置重定向规则去掉扩展名
3. ✅ 确保所有路径返回正确的 Content-Type

**优势**:
- URL 更简洁（无扩展名）
- 更不容易被识别为文件
- 更好的用户体验
- 更灵活的路由配置

