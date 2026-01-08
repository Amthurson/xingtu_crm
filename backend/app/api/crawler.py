"""
第二阶段：爬虫API接口
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.influencer import Influencer
from app.services.crawler import CrawlerService

router = APIRouter()
crawler_service = CrawlerService()


@router.post("/douyin/{influencer_id}")
def crawl_douyin_data(influencer_id: int, db: Session = Depends(get_db)):
    """爬取达人抖音数据"""
    influencer = db.query(Influencer).filter(Influencer.id == influencer_id).first()
    if not influencer:
        raise HTTPException(status_code=404, detail="达人不存在")
    
    if not influencer.douyin_id:
        raise HTTPException(status_code=400, detail="该达人没有抖音ID")
    
    # 爬取数据
    data = crawler_service.crawl_douyin_data(influencer.douyin_id)
    
    if not data:
        raise HTTPException(status_code=500, detail="爬取数据失败")
    
    # 更新数据库
    if data.get('follower_count'):
        influencer.follower_count = data.get('follower_count')
    
    db.commit()
    db.refresh(influencer)
    
    return {
        "message": "爬取成功",
        "data": data,
        "influencer": influencer
    }


@router.post("/xiaohongshu/{influencer_id}")
def crawl_xiaohongshu_data(influencer_id: int, db: Session = Depends(get_db)):
    """爬取达人小红书数据"""
    influencer = db.query(Influencer).filter(Influencer.id == influencer_id).first()
    if not influencer:
        raise HTTPException(status_code=404, detail="达人不存在")
    
    if not influencer.xiaohongshu_id:
        raise HTTPException(status_code=400, detail="该达人没有小红书ID")
    
    # 爬取数据
    data = crawler_service.crawl_xiaohongshu_data(influencer.xiaohongshu_id)
    
    if not data:
        raise HTTPException(status_code=500, detail="爬取数据失败")
    
    # 更新数据库
    if data.get('follower_count'):
        influencer.follower_count = data.get('follower_count')
    
    db.commit()
    db.refresh(influencer)
    
    return {
        "message": "爬取成功",
        "data": data,
        "influencer": influencer
    }


@router.post("/batch/{platform}")
def batch_crawl(platform: str, db: Session = Depends(get_db)):
    """
    批量爬取数据
    platform: douyin 或 xiaohongshu
    """
    if platform not in ['douyin', 'xiaohongshu']:
        raise HTTPException(status_code=400, detail="平台参数错误，支持: douyin, xiaohongshu")
    
    # 获取需要爬取的达人列表
    if platform == 'douyin':
        influencers = db.query(Influencer).filter(Influencer.douyin_id.isnot(None)).all()
    else:
        influencers = db.query(Influencer).filter(Influencer.xiaohongshu_id.isnot(None)).all()
    
    results = []
    for influencer in influencers:
        try:
            if platform == 'douyin':
                data = crawler_service.crawl_douyin_data(influencer.douyin_id)
            else:
                data = crawler_service.crawl_xiaohongshu_data(influencer.xiaohongshu_id)
            
            if data and data.get('follower_count'):
                influencer.follower_count = data.get('follower_count')
                results.append({
                    "influencer_id": influencer.id,
                    "name": influencer.name,
                    "status": "success"
                })
            else:
                results.append({
                    "influencer_id": influencer.id,
                    "name": influencer.name,
                    "status": "failed",
                    "reason": "无法获取数据"
                })
        except Exception as e:
            results.append({
                "influencer_id": influencer.id,
                "name": influencer.name,
                "status": "error",
                "reason": str(e)
            })
    
    db.commit()
    
    return {
        "message": "批量爬取完成",
        "total": len(influencers),
        "results": results
    }


