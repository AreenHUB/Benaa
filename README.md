# Benaa Pro (بناء برو)

تطبيق متكامل لإدارة المشاريع الإنشائية للمهندسين والمقاولين في دولة الإمارات. يوفر التطبيق حاسبات هندسية دقيقة، تقديرات مالية بالدرهم الإماراتي، ومستشار طقس ذكي للعمليات الإنشائية.

## 🚀 التقنيات المستخدمة
- **Frontend:** Flutter & Riverpod
- **Backend:** FastAPI (Python)
- **Database:** PostgreSQL & SQLAlchemy
- **Authentication:** JWT (JSON Web Tokens)

## 📁 هيكلية المشروع
- `/backend`: يحتوي على API الخاص بـ FastAPI ونظام إدارة قواعد البيانات.
- `/frontend`: يحتوي على تطبيق Flutter.

## 🛠️ كيف تبدأ
1. قم بتشغيل قاعدة بيانات PostgreSQL.
2. قم بتثبيت متطلبات السيرفر: `pip install -r backend/requirements.txt`
3. قم بتشغيل السيرفر: `uvicorn app.main:app --reload`
4. افتح مجلد `frontend` وقم بتشغيل التطبيق: `flutter run`

## 🛡️ الإصدارات
- **v1.0.0:** أساسيات الحاسبة والطقس.
- **v2.1.0:** نظام تسجيل دخول آمن، سحابة (Cloud Sync)، و Pagination للسجلات.