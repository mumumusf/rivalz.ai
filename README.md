# Rivalz rClient 部署教程

## 目录
- [注册说明](#注册说明)
- [系统要求](#系统要求)
- [安装步骤](#安装步骤)
- [运行说明](#运行说明)
- [持久化运行](#持久化运行)
- [常见问题](#常见问题)

## 注册说明

在开始部署之前，请先完成 Rivalz 账户注册：

1. 访问注册链接：[https://rivalz.ai?r=YOYOMYOYOA](https://rivalz.ai?r=YOYOMYOYOA)
2. 使用您的 Web3 钱包（如 MetaMask）连接
3. 完成注册流程
4. 记录您的钱包地址，后续部署时需要使用

注册完成后，您就可以开始按照以下步骤部署 rClient 了。

## 系统要求

- 操作系统：Ubuntu 18.04 或更高版本
- Node.js：20.0.0 或更高版本
- 内存：至少 2GB RAM
- 磁盘空间：至少 10GB 可用空间
- 网络：稳定的网络连接

## 安装步骤

### 1. 安装 Node.js
```bash
# 添加 Node.js 20.x 源
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# 安装 Node.js
sudo apt-get install -y nodejs

# 验证安装
node -v  # 应显示 v20.x.x
npm -v   # 确认 npm 已安装
```

### 2. 安装 Rivalz CLI
```bash
# 全局安装 rivalz-node-cli (Linux/Mac 需要 sudo)
sudo npm install -g rivalz-node-cli

# 验证安装
rivalz --version
```

## 运行说明

### 1. 基本运行
```bash
rivalz run
```

### 2. 配置过程
运行后会依次提示：
1. 输入 EVM 钱包地址（格式：0x + 40位16进制字符）
2. 选择要使用的磁盘
3. 设置分配的磁盘空间

### 3. 验证运行状态
成功运行会显示：
- ✔ 节点注册成功
- ✔ 连接成功
- ✔ 数据验证和同步成功
- ✔ 主节点心跳连接正常

## 持久化运行

为了确保程序持续运行，我们使用 screen 进行管理：

### 1. 安装 screen
```bash
sudo apt install screen
```

### 2. 创建并启动会话
```bash
# 创建新的 screen 会话
screen -S rivalz

# 在 screen 会话中运行 Rivalz
rivalz run
```

### 3. 管理 screen 会话
```bash
# 分离会话（保持程序运行）
# 先按 Ctrl + A，然后按 D

# 查看所有会话
screen -ls

# 重新连接到会话
screen -r rivalz

# 结束会话（如果需要）
# 重新连接后输入 exit 或按 Ctrl+D
```

### 4. 常见 screen 操作
- `Ctrl + A` 然后 `D`: 分离会话
- `Ctrl + A` 然后 `C`: 创建新窗口
- `Ctrl + A` 然后 `N`: 切换到下一个窗口
- `Ctrl + A` 然后 `P`: 切换到上一个窗口
- `Ctrl + A` 然后 `K`: 杀死当前窗口
- `Ctrl + A` 然后 `?`: 显示帮助

## 常见问题

### 1. 程序无法启动
- 检查 Node.js 版本是否正确
- 确认 rivalz-node-cli 安装成功
- 检查系统资源是否充足

### 2. 连接断开
- 检查网络连接是否稳定
- 使用 pm2 确保自动重连
- 查看日志了解具体原因：`pm2 logs rivalz`

### 3. 钱包地址问题
- 确保输入的是正确的 EVM 地址
- 地址格式必须是 0x 开头的 42 位字符
- 可以使用 `rivalz change-wallet` 修改钱包地址

### 4. 资源配置问题
- 确保分配的磁盘空间在系统可用范围内
- 可以使用 `rivalz change-hardware-config` 修改配置

## 常用命令
```bash
# 查看状态
rivalz info

# 更新版本
rivalz update-version

# 修改配置
rivalz change-hardware-config

# 修改钱包
rivalz change-wallet

# 查看帮助
rivalz help
```

## 日志查看
```bash
# 重新连接到 screen 会话查看输出
screen -r rivalz

# 如果只想查看日志文件
tail -f rivalz.log
```

## 注意事项

1. 保持系统时间准确
2. 确保网络稳定
3. 定期检查系统资源使用情况
4. 定期检查更新：`rivalz update-version`
5. 定期查看运行状态：`screen -r rivalz`

## 支持与帮助

如果遇到问题：
1. 查看详细日志
2. 检查系统资源
3. 确认网络连接
4. 使用 `rivalz help` 查看帮助信息 