# 本地测试说明

## 启动本地服务器

### 方法一：使用 Python（推荐）

在项目目录下运行：

```bash
# Python 3
python3 -m http.server 8000

# 或者 Python 2
python -m SimpleHTTPServer 8000
```

然后在浏览器中访问：`http://localhost:8000/index.html`

### 方法二：使用 Node.js

如果已安装 Node.js，可以使用 `http-server`：

```bash
# 安装 http-server（如果还没安装）
npm install -g http-server

# 启动服务器
http-server -p 8000
```

### 方法三：使用 VS Code Live Server

如果使用 VS Code：
1. 安装 "Live Server" 扩展
2. 右键点击 `index.html`
3. 选择 "Open with Live Server"

## 测试步骤

1. **打开页面**
   - 访问 `http://localhost:8000/index.html`
   - 应该看到安全检测页面

2. **完成安全检测**
   - 等待安全检测动画完成
   - 点击"点击进入"按钮

3. **线路选择界面**
   - 应该看到线路选择界面
   - 系统会自动检测各线路的延迟
   - 观察延迟显示（绿色=快，橙色=中，红色=慢）

4. **选择线路**
   - 可以点击任意线路进行选择
   - 系统会自动选择最快的线路
   - 点击"确认选择"按钮

5. **测试刷新功能**
   - 点击右上角的刷新按钮（🔄）
   - 观察延迟重新检测

6. **测试取消功能**
   - 点击"取消"按钮
   - 应该使用默认线路直接加载

## 注意事项

- 由于延迟检测需要访问实际URL，如果URL无法访问，延迟检测可能会失败
- 在本地测试时，延迟检测可能受网络环境影响
- 如果只有一个线路配置，会跳过选择界面直接加载

## 修改线路配置

在 `index.html` 文件中找到 `routeConfig` 数组（约第1467行），可以修改或添加线路：

```javascript
const routeConfig = [
    {
        id: 'route1',
        name: '线路一',
        url: 'https://your-url-here.com',
        description: '主线路'
    },
    // 添加更多线路...
];
```

