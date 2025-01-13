# Rivalz rClient 自动化脚本

这是一个用于管理和监控 Rivalz rClient 的自动化脚本，提供了简单的安装、配置和监控功能。

## 系统要求

- Linux 操作系统（Ubuntu/Debian 推荐）
- 最小配置要求：
  - CPU: 2核心
  - 内存: 2GB
  - 磁盘空间: 10GB
- Root 或 sudo 权限
- 网络连接

## 快速开始

1. 下载脚本
```bash
git clone https://github.com/mumumusf/rivalz.ai.git
cd rivalz.ai
chmod +x setup_rivalz.sh
```

2. 运行脚本
```bash
sudo ./setup_rivalz.sh
```

3. 按照提示输入：
   - 钱包地址（必须是有效的以太坊地址）
   - 资源分配（CPU、内存、磁盘）
   - 监控参数设置

## 交互式控制台命令

脚本提供了一个交互式控制台，可以使用以下命令：

| 命令 | 描述 |
|------|------|
| status | 显示当前运行状态 |
| config | 修改配置参数 |
| restart | 重启客户端 |
| stop | 停止客户端 |
| start | 启动客户端 |
| log | 查看运行日志 |
| monitor | 查看监控日志 |
| system | 查看系统状态 |
| limit | 显示资源限制 |
| help | 显示帮助信息 |
| quit | 退出控制台 |

## 配置说明

### 资源配置
- CPU 限制：建议预留 1 核心给系统使用
- 内存限制：建议分配总内存的 50%
- 磁盘限制：建议至少 10GB

### 监控参数
- 检查间隔：多久检查一次客户端状态（建议 30 秒）
- 最大重启次数：5 分钟内允许的最大重启次数（建议 5 次）

## 日志文件

- 运行日志：`rivalz.log`
- 监控日志：`rivalz_monitor.log`
- 配置文件：`~/.rivalz/config`

## VPS 部署教程

### 1. 准备工作
```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装必要工具
sudo apt install -y curl wget git
```

### 2. 安装 Node.js
```bash
# 添加 Node.js 源
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# 安装 Node.js
sudo apt install -y nodejs

# 验证安装
node --version
npm --version
```

### 3. 下载和运行脚本
```bash
# 克隆仓库
git clone https://github.com/mumumusf/rivalz.ai.git
cd rivalz.ai

# 设置权限并运行
chmod +x setup_rivalz.sh
sudo ./setup_rivalz.sh
```

### 4. 使用 Screen 后台运行
```bash
# 安装 screen
sudo apt install -y screen

# 创建新会话
screen -S rivalz

# 运行脚本
./setup_rivalz.sh

# 分离会话（按 Ctrl+A 然后按 D）
# 重新连接会话
screen -r rivalz
```

## 常见问题

1. 如何修改配置？
   ```bash
   # 在控制台中输入
   rivalz> config
   ```

2. 如何查看日志？
   ```bash
   # 查看运行日志
   rivalz> log
   
   # 查看监控日志
   rivalz> monitor
   ```

3. 客户端频繁重启怎么办？
   - 检查系统资源使用情况
   - 查看监控日志寻找错误信息
   - 适当增加资源分配

4. 如何完全停止服务？
   ```bash
   rivalz> stop
   rivalz> quit
   ```

## 安全建议

1. 系统安全
   ```bash
   # 更新系统
   sudo apt update && sudo apt upgrade -y
   
   # 配置防火墙
   sudo ufw allow ssh
   sudo ufw enable
   ```

2. 资源监控
   ```bash
   # 查看系统资源
   rivalz> system
   
   # 查看限制
   rivalz> limit
   ```

3. 日志管理
   ```bash
   # 定期检查日志
   rivalz> log
   rivalz> monitor
   ```

## 最佳实践

1. 资源分配
   - 在高配置服务器上可以分配更多资源
   - 在低配置服务器上要预留足够系统资源

2. 监控设置
   - 检查间隔不要设置太短（建议 30-60 秒）
   - 根据网络状况调整重启次数限制

3. 日志管理
   - 定期检查日志文件
   - 及时处理警告和错误信息

## 故障排除

1. 安装失败
   ```bash
   # 检查系统要求
   free -h          # 检查内存
   nproc            # 检查CPU核心数
   df -h            # 检查磁盘空间
   ```

2. 客户端无法启动
   ```bash
   # 检查日志
   rivalz> log
   
   # 检查系统资源
   rivalz> system
   ```

3. 性能问题
   ```bash
   # 查看系统状态
   rivalz> system
   
   # 调整配置
   rivalz> config
   ```

## 更新记录

- v1.0.0
  - 初始版本发布
  - 基本功能实现
  - 交互式控制台

## 支持

如果遇到问题：
1. 查看监控日志 `rivalz> monitor`
2. 检查系统资源 `rivalz> system`
3. 在 [GitHub Issues](https://github.com/mumumusf/rivalz.ai/issues) 提交问题

## 许可证

MIT License 