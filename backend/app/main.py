from fastapi import FastAPI

from app.api.v1.router import api_router
from app.core.config import settings
from app.api.health import router as health_router, health_check



def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.project_name,
        version=settings.version,
        debug=settings.debug,
    )
    app.include_router(api_router, prefix=settings.api_v1_prefix)
    app.include_router(health_router, prefix="/api")

    @app.get("/health")
    def root_health_check():
        return health_check()

    return app


app = create_app()

@app.on_event("startup")
def _log_routes():
    print("Registered routes:")
    for route in app.routes:
        path = getattr(route, "path", None)
        methods = getattr(route, "methods", None)
        print(f"{path}  methods={methods}")
