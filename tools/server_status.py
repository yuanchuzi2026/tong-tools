#!/usr/bin/env python3
"""服务器状态报告 — 一键展示服务器健康状况"""
import subprocess, json, os
from datetime import datetime

def run(cmd):
    try:
        r = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=5)
        return r.stdout.strip()
    except: return "N/A"

status = {
    "time": datetime.now().strftime("%Y-%m-%d %H:%M"),
    "uptime": run("uptime -p"),
    "load": run("cat /proc/loadavg | awk '{print $1" "$2" "$3}'"),
    "memory": run("free -h | grep Mem | awk '{print $3"/"$2}'"),
    "disk": run("df -h / | tail -1 | awk '{print $3"/"$2" ("$5")"}'"),
    "processes": run("ps aux | wc -l"),
    "temp": "N/A (cloud server)",
}

print(json.dumps(status, indent=2, ensure_ascii=False))
