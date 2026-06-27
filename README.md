# Gemini Cloud Run Hello World (Google ADK Version)

一个使用 **Google Agent Development Kit (ADK)** 并部署在 Google Cloud Run 上的 AI Agent Web 应用。

## 项目结构
- `app.py`: Flask Web 服务器后端，集成最新的 **google-adk**，通过 `LlmAgent` 与 `InMemoryRunner` 实现 Agent 交互。
- `templates/index.html`: 前端界面，基于原生 CSS 打造的暗色调磨砂玻璃风格界面，支持实时测试。
- `static/style.css`: 统一的 UI 设计系统及样式，拥有平滑动画与悬停微交互。
- `requirements.txt`: Python 依赖包配置，包含 `google-adk`。
- `Dockerfile`: 用于构建 Google Cloud Run 容器镜像。
- `.dockerignore`: 排除不需要上传的文件，加速部署。

---

## 本地开发与测试

### 1. 创建虚拟环境并安装依赖
```bash
# 创建虚拟环境
uv venv

# 激活虚拟环境
.venv\Scripts\activate

# 安装依赖
uv pip install -r requirements.txt
```

### 2. 配置 API Key 并启动
```bash
# Windows (PowerShell)
$env:GEMINI_API_KEY="您的_GEMINI_API_KEY"
python app.py

# Windows (CMD)
set GEMINI_API_KEY="您的_GEMINI_API_KEY"
python app.py

# Linux/macOS
export GEMINI_API_KEY="您的_GEMINI_API_KEY"
python app.py
```
启动后在浏览器打开 `http://127.0.0.1:8080` 即可使用。

---

## 部署至 Google Cloud Run

由于 Cloud Run MCP 模块需要使用您的 Google Cloud 凭据，请确保您满足以下前提条件：

### 1. 登录并配置 GCP 凭据
在您的终端运行以下命令以登录您的 GCP 账号：
```bash
gcloud auth login
gcloud auth application-default login
```

### 2. 使用 Cloud Run MCP 工具部署
在模型对话中，输入您的 **GCP Project ID**。确认后，我们将为您触发部署工具：
- 目标路径：`e:\workspace\gemini-ai-hackathon-2026`
- 目标服务名称：建议为 `gemini-hello-world`
- 环境变量配置：在部署的配置中设置 `GEMINI_API_KEY`，这样您的 Cloud Run 应用就能直接调用 Gemini 了！
