from fastapi import FastAPI
from pymongo import MongoClient

app = FastAPI()

# Connect to MongoDB
client = MongoClient("mongodb://localhost:27017")
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