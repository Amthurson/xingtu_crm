# 爬虫服务开发指南

## 概述

第二阶段的爬虫服务架构已经设计完成，提供了统一的接口和扩展点。由于抖音和小红书平台都有严格的反爬虫机制，建议优先使用官方API。

## 架构设计

### 服务结构

```
app/services/crawler.py
├── DouyinCrawler      # 抖音爬虫服务
├── XiaohongshuCrawler # 小红书爬虫服务
└── CrawlerService     # 统一接口服务
```

### API接口

```
app/api/crawler.py
├── POST /api/crawler/douyin/{influencer_id}      # 爬取单个达人抖音数据
├── POST /api/crawler/xiaohongshu/{influencer_id} # 爬取单个达人小红书数据
└── POST /api/crawler/batch/{platform}           # 批量爬取数据
```

## 实现方案

### 方案一：使用官方API（推荐）

#### 抖音开放平台

1. **注册开发者账号**
   - 访问：https://open.douyin.com/
   - 创建应用，获取AppID和AppSecret

2. **获取Access Token**
   ```python
   # 在 DouyinCrawler 中实现
   def get_access_token(self):
       url = "https://open.douyin.com/oauth/access_token/"
       params = {
           "client_key": self.app_id,
           "client_secret": self.app_secret,
           "grant_type": "client_credential"
       }
       response = requests.post(url, params=params)
       return response.json()["access_token"]
   ```

3. **调用API获取达人数据**
   ```python
   def get_influencer_data(self, douyin_id: str):
       access_token = self.get_access_token()
       url = "https://open.douyin.com/star/author/list/"
       headers = {"access-token": access_token}
       params = {"author_id": douyin_id}
       response = requests.get(url, headers=headers, params=params)
       return self._parse_douyin_data(response.json())
   ```

#### 小红书开放平台

1. **注册开发者账号**
   - 访问：https://open.xiaohongshu.com/
   - 创建应用，获取Client ID和Client Secret

2. **实现OAuth认证和数据获取**
   ```python
   def get_influencer_data(self, xiaohongshu_id: str):
       # 实现小红书API调用
       pass
   ```

### 方案二：使用第三方服务

可以使用一些合法的第三方数据服务：
- 新榜API
- 卡思数据API
- 飞瓜数据API

### 方案三：自定义爬虫（不推荐）

如果需要自己实现爬虫，需要注意：

1. **反爬虫机制**
   - IP代理池
   - User-Agent轮换
   - Cookie管理
   - 验证码识别
   - 请求频率限制

2. **技术栈**
   ```python
   # 使用Selenium/Playwright进行浏览器自动化
   from selenium import webdriver
   from selenium.webdriver.common.by import By
   
   # 或使用Scrapy框架
   import scrapy
   ```

3. **注意事项**
   - 遵守robots.txt
   - 控制请求频率
   - 处理反爬虫检测
   - 数据去重和清洗

## 实现步骤

### 1. 配置环境变量

在 `.env` 文件中添加API密钥：

```env
# 抖音开放平台
DOUYIN_APP_ID=your_app_id
DOUYIN_APP_SECRET=your_app_secret

# 小红书开放平台
XIAOHONGSHU_CLIENT_ID=your_client_id
XIAOHONGSHU_CLIENT_SECRET=your_client_secret
```

### 2. 实现爬虫逻辑

修改 `backend/app/services/crawler.py`：

```python
import os
from dotenv import load_dotenv

load_dotenv()

class DouyinCrawler:
    def __init__(self):
        self.app_id = os.getenv("DOUYIN_APP_ID")
        self.app_secret = os.getenv("DOUYIN_APP_SECRET")
        # ... 实现具体逻辑
```

### 3. 数据映射

将API返回的数据映射到数据库字段：

```python
def _parse_douyin_data(self, api_data):
    return {
        'douyin_id': api_data.get('author_id'),
        'follower_count': api_data.get('follower_count', 0),
        'video_count': api_data.get('video_count', 0),
        'like_count': api_data.get('like_count', 0),
        'avg_play_count': api_data.get('avg_play_count', 0),
        # ... 其他字段
    }
```

### 4. 错误处理

添加完善的错误处理：

```python
def get_influencer_data(self, douyin_id: str):
    try:
        # API调用
        data = self._call_api(douyin_id)
        return self._parse_douyin_data(data)
    except requests.exceptions.RequestException as e:
        logger.error(f"API请求失败: {str(e)}")
        return None
    except KeyError as e:
        logger.error(f"数据解析失败: {str(e)}")
        return None
```

## 定时任务（可选）

可以使用Celery或APScheduler实现定时爬取：

### 使用APScheduler

```python
from apscheduler.schedulers.background import BackgroundScheduler

scheduler = BackgroundScheduler()

@scheduler.scheduled_job('cron', hour=2)  # 每天凌晨2点执行
def update_all_influencers():
    # 批量更新所有达人数据
    pass

scheduler.start()
```

### 使用Celery

```python
from celery import Celery

celery_app = Celery('crawler')

@celery_app.task
def update_influencer_data(influencer_id):
    # 更新单个达人数据
    pass
```

## 数据存储

可以考虑创建爬虫数据表：

```python
class CrawlerData(Base):
    __tablename__ = "crawler_data"
    
    id = Column(Integer, primary_key=True)
    influencer_id = Column(Integer, ForeignKey('influencers.id'))
    platform = Column(String(50))  # 'douyin' or 'xiaohongshu'
    data = Column(JSON)  # 原始爬取数据
    crawl_time = Column(DateTime)
```

## 测试

编写测试用例：

```python
def test_douyin_crawler():
    crawler = DouyinCrawler()
    data = crawler.get_influencer_data("test_id")
    assert data is not None
    assert 'follower_count' in data
```

## 注意事项

1. **法律合规**
   - 遵守平台服务条款
   - 不要过度爬取
   - 尊重数据所有权

2. **性能优化**
   - 使用异步请求
   - 实现请求缓存
   - 批量处理

3. **监控和日志**
   - 记录爬取日志
   - 监控API调用次数
   - 设置告警机制

4. **数据更新策略**
   - 增量更新
   - 数据版本控制
   - 历史数据保留

## 参考资源

- [抖音开放平台文档](https://open.douyin.com/platform/doc)
- [小红书开放平台文档](https://open.xiaohongshu.com/document/developer/home)
- [FastAPI异步编程](https://fastapi.tiangolo.com/async/)
- [SQLAlchemy文档](https://docs.sqlalchemy.org/)


