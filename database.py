from sqlalchemy import Column, Integer, String, Boolean, DateTime
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, declarative_base
from datetime import datetime
import os
import enum

# 支持通过环境变量指定 SQLite 数据库文件路径，便于容器化部署时持久化
DB_PATH = os.environ.get("DB_PATH", "./app.db")
SQLALCHEMY_DATABASE_URL = f"sqlite+aiosqlite:///{DB_PATH}"

# 确保数据库文件所在目录存在
_db_dir = os.path.dirname(DB_PATH)
if _db_dir:
    os.makedirs(_db_dir, exist_ok=True)

engine = create_async_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine, class_=AsyncSession)

Base = declarative_base()

class UserRole(str, enum.Enum):
    ADMIN = "admin"
    USER = "user"

class User(Base):
    __tablename__ = "users"

    id: int = Column(Integer, primary_key=True, index=True)
    username: str = Column(String, unique=True, index=True)
    hashed_password: str = Column(String)
    role: str = Column(String, default=UserRole.USER)
    balance: int = Column(Integer, default=1000)
    created_at: datetime = Column(DateTime, default=datetime.utcnow)

class RegistrationCode(Base):
    __tablename__ = "registration_codes"

    id: int = Column(Integer, primary_key=True, index=True)
    code: str = Column(String, unique=True, index=True)
    is_used: bool = Column(Boolean, default=False)
    points: int = Column(Integer, default=1000)
    created_by: int = Column(Integer) # Admin User ID
    created_at: datetime = Column(DateTime, default=datetime.utcnow)

class EndpointCost(Base):
    __tablename__ = "endpoint_costs"

    id: int = Column(Integer, primary_key=True, index=True)
    path: str = Column(String, unique=True, index=True)
    cost: int = Column(Integer, default=1)
    description: str = Column(String, nullable=True)

async def init_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

async def get_db():
    async with SessionLocal() as db:
        yield db
