from fastapi import FastAPI
from pymongo import MongoClient
from uagents import Model
from uagents.query import query
import time, requests, json, base64, logging
from typing import Optional
import uvicorn

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("uvicorn")
app = FastAPI()

# Connect to MongoDB
client = MongoClient("mongodb://localhost:27017")
db = client["mydatabase"]
collection = db["mycollection"]

AGENT_ADDRESS = "agent1q2vkuxhncyl56rvc6r6zvs3lk3a9fuqet9zgdanysyvusschs6ttq6s07r7"


class NearbyArea(Model):
    latitude: float
    longitude: float
    radius: float


class Message(Model):
    msg: str


async def agent_audio_query(req: Message):
    response = await query(destination=AGENT_ADDRESS, message=req, timeout=15.0)
    return response


async def agent_location_send(req: NearbyArea):
    response = await query(destination=AGENT_ADDRESS, message=req, timeout=15.0)
    return response


@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.get("/api/audio")
async def get_audio():
    logger.info("Handling get request for audio")
    data = await agent_audio_query(Message(msg=""))
    file_path = "music_prompt.txt"
    logger.info("Handled get for audio correctly")
    return file_path


@app.post("/api/location")
@app.post("/api/location/")
async def send_coordinates(body: dict):
    latitude = float(body["latitude"])
    longitude = float(body["longitude"])
    radius = float(body["radius"])
    logger.info("Handling post request for location")
    nearby_area = NearbyArea(latitude=latitude, longitude=longitude, radius=radius)
    data = await agent_location_send(nearby_area)
    logger.info("Handled post for location correctly, grabbing audio now")
    file_path = await get_audio()
    return file_path


if __name__ == "__main__":
    uvicorn.run("main:app", host="192.168.61.134", port=4000, reload=True)
