from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from app.schemas.tag import TagResponse


class InfluencerBase(BaseModel):
    name: str
    gender: Optional[str] = None
    city: Optional[str] = None
    platform_tags: Optional[str] = None
    ranking_info: Optional[str] = None
    influencer_type: Optional[str] = None
    content_theme: Optional[str] = None
    age_rating: Optional[str] = None
    connected_users: Optional[int] = 0
    follower_count: Optional[int] = 0
    expected_cpm: Optional[float] = None
    quote_21_60s: Optional[float] = None
    quote_note: Optional[str] = None
    representative_videos: Optional[List[str]] = None
    douyin_id: Optional[str] = None
    xiaohongshu_id: Optional[str] = None


class InfluencerCreate(InfluencerBase):
    tag_ids: Optional[List[int]] = None  # 标签ID列表
    tag_names: Optional[List[str]] = None  # 标签名称列表（用于创建新标签）


class InfluencerUpdate(BaseModel):
    name: Optional[str] = None
    gender: Optional[str] = None
    city: Optional[str] = None
    platform_tags: Optional[str] = None
    ranking_info: Optional[str] = None
    influencer_type: Optional[str] = None
    content_theme: Optional[str] = None
    age_rating: Optional[str] = None
    connected_users: Optional[int] = None
    follower_count: Optional[int] = None
    expected_cpm: Optional[float] = None
    quote_21_60s: Optional[float] = None
    quote_note: Optional[str] = None
    representative_videos: Optional[List[str]] = None
    douyin_id: Optional[str] = None
    xiaohongshu_id: Optional[str] = None
    tag_ids: Optional[List[int]] = None  # 标签ID列表
    tag_names: Optional[List[str]] = None  # 标签名称列表（用于创建新标签）


class InfluencerResponse(InfluencerBase):
    id: int
    tags: List[TagResponse] = []  # 标签列表
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


