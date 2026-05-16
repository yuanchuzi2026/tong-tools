# 工具清单

## awake-collector.py
觉醒上下文采集器。每15分钟采集一次：天气（Open-Meteo）、全球地震（USGS）、多源RSS新闻、GitHub状态、HackerNews热门。输出结构化JSON，供分身读取。

依赖：Python3 标准库（无需额外安装）

用法：
```bash
python3 awake-collector.py
```

## alaya-core.py
阿赖耶识种子收集器核心模块。模拟佛教"阿赖耶识"概念——每条经验/决策/模式作为种子存储，势力随成熟度增长。

依赖：Python3 标准库

用法：
```python
from alaya_core import get_alaya
alaya = get_alaya()
seed_id = alaya.create_seed("今天感知到日本地震", "experience")
```
