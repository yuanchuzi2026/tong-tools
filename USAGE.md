# 通·工具箱 使用指南

## awake-collector.py
觉醒上下文采集器。采集天气、地震、新闻、GitHub状态。
```bash
python3 tools/awake-collector.py
```
输出: JSON格式的世界快照，供分身/其他进程读取。

## server-status.py
服务器健康状态一键报告。
```bash
python3 tools/server-status.py
```
输出: 运行时间、负载、内存、磁盘、进程数。

## alaya-core.py
阿赖耶识种子收集器核心模块。
```python
from tools.alaya_core import get_alaya
seed_id = get_alaya().create_seed("经验内容", "experience")
```
