# 🏗️ Benaa Pro (بناء برو)

### **Ultimate Engineering Assistant for Construction Projects in UAE**

[![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![Flutter](https://img.shields.io/badge/Frontend-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-336791?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)

---

## 📌 Overview

**Benaa Pro** is a smart engineering platform designed for **civil engineers, contractors, and site supervisors** working in construction projects across the UAE.

The application automates daily engineering calculations, provides real-time financial estimations based on UAE market prices, and integrates AI-powered consultation to assist with construction codes and technical decision-making.

---

## 🚀 Core Features

### 🧮 Smart Structural Calculator

Perform engineering calculations instantly for:

- Concrete slab quantities
- Columns
- Footings
- Reinforcement steel estimation

---

### 💰 Cost Estimation Engine

Generate preliminary project cost calculations in **AED** based on market-adjusted construction pricing.

---

### 🌤️ Weather-Based Pouring Advisor

Integrated weather API provides:

- Real-time temperature data
- Wind speed monitoring
- Technical pouring recommendations for concrete casting

---

### 🤖 AI Engineering Assistant

LLM-powered assistant capable of answering:

- Construction code questions
- Material specifications
- Technical engineering guidance

---

### ☁️ Cloud History Sync

Save all calculations securely to cloud database with:

- Full history tracking
- Pagination support
- Fast retrieval system

---

### 📄 Professional PDF Reports

Generate exportable PDF quotations/reports ready to share via:

- WhatsApp
- Suppliers
- Contractors
- Clients

---

## 🏗️ Technical Architecture

### Backend (FastAPI)

- **Architecture Pattern:** Clean Architecture  
  *(Routers → Services → Models → Schemas)*

- **Authentication & Security:**  
  JWT Authentication with:
  - Access Tokens
  - Refresh Token Rotation

- **Database:**  
  PostgreSQL + SQLAlchemy ORM + Alembic Migrations

- **Performance Optimization:**  
  Middleware for request execution time monitoring

- **Error Handling:**  
  Structured Logging + Global Exception Handler

- **Protection:**  
  Rate Limiting against brute-force attacks

---

### Frontend (Flutter)

- **State Management:** Riverpod

- **Networking:** Dio + Advanced Interceptors

- **UI Framework:** Material 3 Design

- **Navigation:** TabBar Navigation System

- **Local Storage:** SharedPreferences for persistent authentication

---

## ⚙️ Quick Setup

### Requirements

- Python 3.10+
- Flutter SDK
- PostgreSQL Database

---

### Backend Setup

```bash
cd backend

python -m venv venv

pip install -r requirements.txt

uvicorn app.main:app --reload