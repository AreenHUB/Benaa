# ملف: app/core/rate_limit.py
from slowapi import Limiter
from slowapi.util import get_remote_address

# تعريف الـ Limiter هنا ليكون مستقلاً تماماً
limiter = Limiter(key_func=get_remote_address)
