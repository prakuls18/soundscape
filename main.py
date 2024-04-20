from fastapi import FastAPI
from pymongo import MongoClient
import os

app = FastAPI()

# Connect to MongoDB
mongodb_url = os.environ.get("MONGODB_URL", "mongodb://localhost:27017")
client = MongoClient(mongodb_url)
db = client["mydatabase"]
collection = db["mycollection"]


@app.get("/")
def read_root():
    return {"Hello": "World"}

@app.get("/items/{item_id}")
def read_item(item_id: int):
    item = collection.find_one({"_id": item_id})
    return item

@app.post("/items")
def create_item(item: dict):
    result = collection.insert_one(item)
    return {"item_id": str(result.inserted_id)}