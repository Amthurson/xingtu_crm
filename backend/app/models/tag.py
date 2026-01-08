from sqlalchemy import Column, Integer, String, DateTime, Table, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.database import Base


# 达人和标签的多对多关联表
influencer_tags = Table(
    'influencer_tags',
    Base.metadata,
    Column('influencer_id', Integer, ForeignKey('influencers.id', ondelete='CASCADE'), primary_key=True),
    Column('tag_id', Integer, ForeignKey('tags.id', ondelete='CASCADE'), primary_key=True)
)


class Tag(Base):
    """标签模型"""
    __tablename__ = "tags"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False, unique=True, index=True, comment="标签名称")
    color = Column(String(20), comment="标签颜色（可选）")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # 多对多关系
    influencers = relationship(
        "Influencer",
        secondary="influencer_tags",
        back_populates="tags"
    )

