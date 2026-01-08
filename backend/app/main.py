from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.database import engine, Base
from app.api import influencers, import_excel, crawler, tags

# 创建数据库表
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="达人老师CRM API",
    description="达人老师CRM管理系统API",
    version="1.0.0"
)

# 配置CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 生产环境应配置具体域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 注册路由
app.include_router(influencers.router, prefix="/api/influencers", tags=["达人管理"])
app.include_router(tags.router, prefix="/api/tags", tags=["标签管理"])
app.include_router(import_excel.router, prefix="/api/import", tags=["Excel导入"])
app.include_router(crawler.router, prefix="/api/crawler", tags=["爬虫服务"])


@app.get("/")
async def root():
    return {"message": "达人老师CRM API", "version": "1.0.0"}


@app.get("/health")
async def health():
    return {"status": "ok"}

