from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session, joinedload
from typing import List, Optional
from app.database import get_db
from app.models.influencer import Influencer
from app.models.tag import Tag
from app.schemas.influencer import InfluencerCreate, InfluencerUpdate, InfluencerResponse

router = APIRouter()


@router.get("/")
def get_influencers(
    skip: int = 0,
    limit: int = 100,
    search: Optional[str] = None,
    tag_ids: Optional[List[int]] = Query(None),
    sort_by: Optional[str] = None,  # 排序字段：connected_users, follower_count, expected_cpm, quote_21_60s
    sort_order: Optional[str] = "asc",  # 排序方向：asc, desc
    db: Session = Depends(get_db)
):
    """获取达人列表（支持标签筛选和排序）"""
    query = db.query(Influencer).options(joinedload(Influencer.tags))
    
    if search:
        query = query.filter(
            Influencer.name.contains(search) |
            Influencer.city.contains(search) |
            Influencer.influencer_type.contains(search)
        )
    
    # 标签筛选
    if tag_ids:
        query = query.join(Influencer.tags).filter(Tag.id.in_(tag_ids)).distinct()
    
    # 排序
    allowed_sort_fields = ['connected_users', 'follower_count', 'expected_cpm', 'quote_21_60s']
    if sort_by and sort_by in allowed_sort_fields:
        sort_column = getattr(Influencer, sort_by)
        if sort_order and sort_order.lower() == 'desc':
            query = query.order_by(sort_column.desc())
        else:
            query = query.order_by(sort_column.asc())
    else:
        # 默认按ID倒序
        query = query.order_by(Influencer.id.desc())
    
    total = query.count()
    influencers = query.offset(skip).limit(limit).all()
    
    return {
        "items": influencers,
        "total": total,
        "skip": skip,
        "limit": limit
    }


@router.get("/{influencer_id}", response_model=InfluencerResponse)
def get_influencer(influencer_id: int, db: Session = Depends(get_db)):
    """获取单个达人详情"""
    influencer = db.query(Influencer).options(joinedload(Influencer.tags)).filter(Influencer.id == influencer_id).first()
    if not influencer:
        raise HTTPException(status_code=404, detail="达人不存在")
    return influencer


@router.post("/", response_model=InfluencerResponse)
def create_influencer(influencer: InfluencerCreate, db: Session = Depends(get_db)):
    """创建达人（支持标签）"""
    influencer_data = influencer.dict(exclude={'tag_ids', 'tag_names'})
    db_influencer = Influencer(**influencer_data)
    db.add(db_influencer)
    db.flush()  # 获取ID但不提交
    
    # 处理标签
    tag_ids_to_add = set()
    
    # 添加已存在的标签
    if influencer.tag_ids:
        existing_tags = db.query(Tag).filter(Tag.id.in_(influencer.tag_ids)).all()
        tag_ids_to_add.update([tag.id for tag in existing_tags])
    
    # 创建新标签
    if influencer.tag_names:
        for tag_name in influencer.tag_names:
            tag_name = tag_name.strip()
            if not tag_name:
                continue
            # 检查是否已存在
            existing_tag = db.query(Tag).filter(Tag.name == tag_name).first()
            if existing_tag:
                tag_ids_to_add.add(existing_tag.id)
            else:
                new_tag = Tag(name=tag_name)
                db.add(new_tag)
                db.flush()
                tag_ids_to_add.add(new_tag.id)
    
    # 设置标签关系
    if tag_ids_to_add:
        tags = db.query(Tag).filter(Tag.id.in_(list(tag_ids_to_add))).all()
        db_influencer.tags = tags
    
    db.commit()
    db.refresh(db_influencer)
    # 重新加载标签关系
    db.refresh(db_influencer)
    return db_influencer


@router.put("/{influencer_id}", response_model=InfluencerResponse)
def update_influencer(
    influencer_id: int,
    influencer: InfluencerUpdate,
    db: Session = Depends(get_db)
):
    """更新达人信息（支持标签）"""
    db_influencer = db.query(Influencer).options(joinedload(Influencer.tags)).filter(Influencer.id == influencer_id).first()
    if not db_influencer:
        raise HTTPException(status_code=404, detail="达人不存在")
    
    update_data = influencer.dict(exclude_unset=True, exclude={'tag_ids', 'tag_names'})
    for field, value in update_data.items():
        setattr(db_influencer, field, value)
    
    # 处理标签更新
    if 'tag_ids' in influencer.dict(exclude_unset=True) or 'tag_names' in influencer.dict(exclude_unset=True):
        tag_ids_to_set = set()
        
        # 添加已存在的标签
        if influencer.tag_ids:
            existing_tags = db.query(Tag).filter(Tag.id.in_(influencer.tag_ids)).all()
            tag_ids_to_set.update([tag.id for tag in existing_tags])
        
        # 创建新标签
        if influencer.tag_names:
            for tag_name in influencer.tag_names:
                tag_name = tag_name.strip()
                if not tag_name:
                    continue
                # 检查是否已存在
                existing_tag = db.query(Tag).filter(Tag.name == tag_name).first()
                if existing_tag:
                    tag_ids_to_set.add(existing_tag.id)
                else:
                    new_tag = Tag(name=tag_name)
                    db.add(new_tag)
                    db.flush()
                    tag_ids_to_set.add(new_tag.id)
        
        # 更新标签关系
        tags = db.query(Tag).filter(Tag.id.in_(list(tag_ids_to_set))).all()
        db_influencer.tags = tags
    
    db.commit()
    db.refresh(db_influencer)
    # 重新加载标签关系
    db.refresh(db_influencer)
    return db_influencer


@router.delete("/{influencer_id}")
def delete_influencer(influencer_id: int, db: Session = Depends(get_db)):
    """删除达人"""
    db_influencer = db.query(Influencer).filter(Influencer.id == influencer_id).first()
    if not db_influencer:
        raise HTTPException(status_code=404, detail="达人不存在")
    
    db.delete(db_influencer)
    db.commit()
    return {"message": "删除成功"}

