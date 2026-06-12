from fastapi import APIRouter
from app.integrations.supabase.client import supabase

router = APIRouter()

@router.get('/health')
def health_check():
    try:
        result = (
            supabase
            .table('users')
            .select('*')
            .limit(1)
            .execute()
        )
        rows = len(result.data) if getattr(result, 'data', None) else 0
        return {
            'status': 'ok',
            'database': 'connected',
            'rows_checked': rows,
        }
    except Exception as e:
        return {
            'status': 'error',
            'message': str(e),
        }
