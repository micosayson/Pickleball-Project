from fastapi import FastAPI
from fastapi import Request
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1.router import api_router
from app.core.config import settings
from app.api.health import router as health_router, health_check



def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.project_name,
        version=settings.version,
        debug=settings.debug,
    )
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=False,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    app.include_router(api_router, prefix=settings.api_v1_prefix)
    app.include_router(health_router, prefix="/api")

    @app.middleware("http")
    async def log_requests(request: Request, call_next):
        print(f"{request.method} {request.url.path} -> incoming")
        response = await call_next(request)
        print(f"{request.method} {request.url.path} -> {response.status_code}")
        return response

    @app.get("/health")
    def root_health_check():
        return health_check()

    return app


app = create_app()

