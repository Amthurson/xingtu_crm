from fastapi import APIRouter, UploadFile, File, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.influencer import Influencer
from app.schemas.influencer import InfluencerCreate
import pandas as pd
import io
from typing import List
from urllib.parse import quote

router = APIRouter()


def parse_excel_to_influencers(file_content: bytes) -> List[dict]:
    """解析Excel文件为达人数据列表"""
    try:
        # 读取Excel文件
        df = pd.read_excel(io.BytesIO(file_content))
        
        # 标准化列名（支持多种可能的列名）
        column_mapping = {
            '姓名': 'name',
            '昵称': 'name',
            'name': 'name',
            '性别': 'gender',
            'gender': 'gender',
            '城市': 'city',
            '所在城市': 'city',
            'city': 'city',
            '平台标签': 'platform_tags',
            'platform_tags': 'platform_tags',
            '排名信息': 'ranking_info',
            'ranking_info': 'ranking_info',
            '达人类型': 'influencer_type',
            'influencer_type': 'influencer_type',
            '内容主题': 'content_theme',
            'content_theme': 'content_theme',
            '年龄评级': 'age_rating',
            'age_rating': 'age_rating',
            '连接用户数': 'connected_users',
            'connected_users': 'connected_users',
            '粉丝数': 'follower_count',
            '粉丝数量': 'follower_count',
            'follower_count': 'follower_count',
            '预期CPM': 'expected_cpm',
            'expected_cpm': 'expected_cpm',
            '21-60s报价': 'quote_21_60s',
            '报价': 'quote_21_60s',
            'quote_21_60s': 'quote_21_60s',
            '报价备注': 'quote_note',
            'quote_note': 'quote_note',
            '抖音ID': 'douyin_id',
            'douyin_id': 'douyin_id',
            '小红书ID': 'xiaohongshu_id',
            'xiaohongshu_id': 'xiaohongshu_id',
        }
        
        # 重命名列
        df.columns = df.columns.str.strip()
        df = df.rename(columns=column_mapping)
        
        # 处理数值列
        numeric_columns = ['connected_users', 'follower_count', 'expected_cpm', 'quote_21_60s']
        for col in numeric_columns:
            if col in df.columns:
                # 处理包含"万"、"w"等单位的数值
                if df[col].dtype == 'object':
                    df[col] = df[col].astype(str).str.replace('万', '').str.replace('w', '').str.replace('W', '')
                    df[col] = df[col].str.replace(',', '').str.replace('，', '')
                    df[col] = pd.to_numeric(df[col], errors='coerce')
                    # 如果原始值包含"万"或"w"，乘以10000
                    mask = df[col].notna()
                    df.loc[mask, col] = df.loc[mask, col] * 10000
        
        # 转换为字典列表
        influencers = df.to_dict('records')
        
        # 过滤掉name为空的记录
        influencers = [inf for inf in influencers if inf.get('name') and pd.notna(inf.get('name'))]
        
        return influencers
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Excel解析失败: {str(e)}")


@router.post("/excel")
async def import_excel(
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    """导入Excel文件"""
    if not file.filename.endswith(('.xlsx', '.xls')):
        raise HTTPException(status_code=400, detail="仅支持Excel文件 (.xlsx, .xls)")
    
    # 读取文件内容
    contents = await file.read()
    
    # 解析Excel
    influencers_data = parse_excel_to_influencers(contents)
    
    if not influencers_data:
        raise HTTPException(status_code=400, detail="Excel文件中没有有效数据")
    
    # 批量插入数据库
    created_count = 0
    updated_count = 0
    errors = []
    
    for idx, inf_data in enumerate(influencers_data, 1):
        try:
            # 检查是否已存在（根据name判断）
            existing = db.query(Influencer).filter(Influencer.name == inf_data.get('name')).first()
            
            if existing:
                # 更新现有记录
                for key, value in inf_data.items():
                    if value is not None and pd.notna(value):
                        setattr(existing, key, value)
                updated_count += 1
            else:
                # 创建新记录
                # 清理数据，移除None和NaN值
                clean_data = {k: v for k, v in inf_data.items() if v is not None and pd.notna(v)}
                db_influencer = Influencer(**clean_data)
                db.add(db_influencer)
                created_count += 1
        except Exception as e:
            errors.append(f"第{idx}行: {str(e)}")
    
    db.commit()
    
    return {
        "message": "导入完成",
        "total": len(influencers_data),
        "created": created_count,
        "updated": updated_count,
        "errors": errors if errors else None
    }


@router.get("/template")
async def download_template():
    """下载Excel模板"""
    # 创建模板数据
    template_data = {
        '姓名': ['示例达人1', '示例达人2'],
        '性别': ['男', '女'],
        '所在城市': ['北京', '上海'],
        '平台标签': ['抖音精选', '繁星企划'],
        '达人类型': ['美食', '美妆'],
        '内容主题': ['美食探店', '美妆教程'],
        '粉丝数': [1000000, 2000000],
        '预期CPM': [25.5, 30.2],
        '21-60s报价': [50000, 80000],
        '抖音ID': ['douyin123', 'douyin456'],
    }
    
    df = pd.DataFrame(template_data)
    
    # 转换为Excel字节流
    output = io.BytesIO()
    with pd.ExcelWriter(output, engine='openpyxl') as writer:
        df.to_excel(writer, index=False, sheet_name='达人数据')
    
    output.seek(0)
    
    from fastapi.responses import StreamingResponse
    # 使用 RFC 5987 格式编码中文文件名
    filename = "达人导入模板.xlsx"
    encoded_filename = quote(filename, safe='')
    headers = {
        "Content-Disposition": f"attachment; filename*=UTF-8''{encoded_filename}"
    }
    
    return StreamingResponse(
        io.BytesIO(output.read()),
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers=headers
    )


