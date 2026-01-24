# app/main.py
from fastapi import FastAPI
from controllers import finance_agent_controller
from core.db import db

app = FastAPI(title="AI Finance Model Server")

@app.on_event("startup")
async def startup():
    await db.connect()

@app.on_event("shutdown")
async def shutdown():
    await db.disconnect()

app.include_router(finance_agent_controller.router)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=6969, reload=True)