from fastapi import FastAPI
from fastapi.responses import JSONResponse


app = FastAPI()

@app.on_event("startup")
async def startup_event():
    print("Starting FastAPI app")

@app.get("/")
async def root():
    return JSONResponse("I am alive")
