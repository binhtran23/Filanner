# Filanner

## Automating Financial Clarity with AI Agents.

Filanner is an AI-powered financial planning assistant designed to help users bridge the gap between their financial goals and daily habits. Built for the Encode "Commit To Change" Hackathon, this system utilizes autonomous agents to analyze user data, provide actionable financial insights, and track progress toward New Year's resolutions.

## Project Status

- Frontend and backend are currently being connected (integration in progress).
- AI agent logic (`planner_agent/`) is experimental and under active iteration.
- Expect breaking changes while the API contracts and agent workflows stabilize.

## Tech Stack

- Frontend: Flutter (mobile + web)
- Backend: FastAPI
- Database: PostgreSQL (pgvector image used in Docker)

## Repository Structure

- `finance_health_app/`: Flutter frontend
- `backend_lite/`: FastAPI backend (REST API)
- `docker-compose.yaml`: Local dev stack (Postgres + backend + frontend)
- `planner_agent/`: **Experimental /Core AI Agent Service** (Logic & Reasoning Engine)

## Quick Start (Docker)

1) Create env file:

```bash
cp .env.example .env
```

2) Start services:

```bash
docker compose up --build
```

## Local URLs

- Frontend (web): http://localhost:3000
- Backend API: http://localhost:8000/api
- Backend health: http://localhost:8000/health

## Development (Without Docker)

Backend:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r backend_lite/requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Frontend:

```bash
cd finance_health_app
flutter pub get
flutter run
```

## Notes

- Configuration lives in `.env` (see `.env.example`). Do not commit real secrets.
- The backend enables permissive CORS for development; lock this down for production.
