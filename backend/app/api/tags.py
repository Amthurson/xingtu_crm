from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.models.tag import Tag
from app.schemas.tag import TagCreate, TagUpdate, TagResponse

router = APIRouter()


@router.get("/", response_model=List[TagResponse])
def get_tags(
    search: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """获取标签列表（支持搜索）"""
    query = db.query(Tag)
    
    if search:
        query = query.filter(Tag.name.contains(search))
    
    tags = query.order_by(Tag.name).all()
    return tags


@router.get("/{tag_id}", response_model=TagResponse)
def get_tag(tag_id: int, db: Session = Depends(get_db)):
    """获取单个标签详情"""
    tag = db.query(Tag).filter(Tag.id == tag_id).first()
    if not tag:
        raise HTTPException(status_code=404, detail="标签不存在")
    return tag


@router.post("/", response_model=TagResponse)
def create_tag(tag: TagCreate, db: Session = Depends(get_db)):
    """创建标签"""
    # 检查标签是否已存在
    existing_tag = db.query(Tag).filter(Tag.name == tag.name).first()
    if existing_tag:
        return existing_tag  # 如果已存在，直接返回
    
    db_tag = Tag(**tag.dict())
    db.add(db_tag)
    db.commit()
    db.refresh(db_tag)
    return db_tag


@router.post("/bulk", response_model=List[TagResponse])
def create_tags_bulk(tag_names: List[str], db: Session = Depends(get_db)):
    """批量创建标签（如果不存在）"""
    created_tags = []
    for name in tag_names:
        name = name.strip()
        if not name:
            continue
        
        # 检查是否已存在
        existing_tag = db.query(Tag).filter(Tag.name == name).first()
        if existing_tag:
            created_tags.append(existing_tag)
        else:
            db_tag = Tag(name=name)
            db.add(db_tag)
            created_tags.append(db_tag)
    
    db.commit()
    # 刷新所有标签以获取ID
    for tag in created_tags:
        db.refresh(tag)
    
    return created_tags


@router.put("/{tag_id}", response_model=TagResponse)
def update_tag(
    tag_id: int,
    tag: TagUpdate,
    db: Session = Depends(get_db)
):
    """更新标签信息"""
    db_tag = db.query(Tag).filter(Tag.id == tag_id).first()
    if not db_tag:
        raise HTTPException(status_code=404, detail="标签不存在")
    
    update_data = tag.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_tag, field, value)
    
    db.commit()
    db.refresh(db_tag)
    return db_tag


@router.delete("/{tag_id}")
def delete_tag(tag_id: int, db: Session = Depends(get_db)):
    """删除标签"""
    db_tag = db.query(Tag).filter(Tag.id == tag_id).first()
    if not db_tag:
        raise HTTPException(status_code=404, detail="标签不存在")
    
    db.delete(db_tag)
    db.commit()
    return {"message": "删除成功"}

