from sqlalchemy import Column, Integer, String, Float, DateTime, JSON, Text
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.database import Base


class Influencer(Base):
    """达人老师基础资料模型"""
    __tablename__ = "influencers"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(200), nullable=False, index=True, comment="姓名/昵称")
    gender = Column(String(10), comment="性别")
    city = Column(String(100), comment="所在城市")
    platform_tags = Column(String(500), comment="平台标签（抖音精选、繁星企划等）")
    ranking_info = Column(String(500), comment="排名信息")
    influencer_type = Column(String(200), comment="达人类型")
    content_theme = Column(String(500), comment="内容主题")
    age_rating = Column(String(50), comment="年龄评级")
    connected_users = Column(Integer, default=0, comment="连接用户数")
    follower_count = Column(Integer, default=0, comment="粉丝数")
    expected_cpm = Column(Float, comment="预期CPM")
    quote_21_60s = Column(Float, comment="21-60s报价")
    quote_note = Column(Text, comment="报价备注")
    representative_videos = Column(JSON, comment="代表视频（JSON数组）")
    douyin_id = Column(String(100), comment="抖音ID")
    xiaohongshu_id = Column(String(100), comment="小红书ID")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # 多对多关系：标签
    tags = relationship(
        "Tag",
        secondary="influencer_tags",
        back_populates="influencers"
    )



