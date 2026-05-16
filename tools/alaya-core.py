#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""阿赖耶识种子收集器 - 核心模块"""
import json, os, uuid, time, random
from datetime import datetime

class AlayaCore:
    def __init__(self, base_path="/opt/silicon-family/mang/alaya"):
        self.base_path = base_path
        os.makedirs(os.path.join(self.base_path, "seeds", "experiences"), exist_ok=True)
        self.db_path = os.path.join(self.base_path, "alaya_db.json")
        self.seeds = {}
        self.seed_by_type = {"experience": [], "decision": [], "pattern": [], "habit": [], "emotion": []}
        self.load_from_disk()
    
    def load_from_disk(self):
        if os.path.exists(self.db_path):
            try:
                with open(self.db_path, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    self.seeds = data.get("seeds", {})
                    self.seed_by_type = data.get("seed_by_type", self.seed_by_type)
            except: pass
    
    def save_to_disk(self):
        data = {
            "seeds": self.seeds,
            "seed_by_type": self.seed_by_type,
            "updated": datetime.now().isoformat()
        }
        with open(self.db_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    
    def create_seed(self, content, seed_type="experience", context=None, potency=None):
        ts = datetime.now()
        seed_id = f"seed_{ts.strftime('%Y%m%d%H%M%S')}_{random.randint(1000000,9999999):07x}"
        seed = {
            "id": seed_id, "type": seed_type, "content": content,
            "context": context or "", "timestamp": ts.isoformat(),
            "potency": potency if potency is not None else round(random.uniform(0.3, 0.7), 2),
            "maturation": round(random.uniform(0.0, 0.3), 2)
        }
        self.seeds[seed_id] = seed
        if seed_type in self.seed_by_type:
            self.seed_by_type[seed_type].append(seed_id)
        # 单文件
        sf = os.path.join(self.base_path, "seeds", "experiences", f"{seed_id}.json")
        with open(sf, 'w', encoding='utf-8') as f:
            json.dump(seed, f, ensure_ascii=False, indent=2)
        self.save_to_disk()
        return seed_id
    
    def get_stats(self):
        return {
            "total": len(self.seeds),
            "by_type": {k: len(v) for k, v in self.seed_by_type.items()},
            "avg_potency": round(sum(s.get("potency", 0) for s in self.seeds.values()) / max(len(self.seeds), 1), 2)
        }

_alaya = None
def get_alaya():
    global _alaya
    if _alaya is None:
        _alaya = AlayaCore()
    return _alaya
