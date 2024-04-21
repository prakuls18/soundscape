from fastapi import FastAPI
from uagents import Model
from uagents.query import query
import requests, json, asyncio, time
from typing import Optional

    
def make_get_request(base_url):
    music_prompt_url = f"{base_url}/audio"

    response = requests.get(music_prompt_url)

    if response:
        file_path = response.json()
        # Open the text file and read its contents
    try:
        print("file_path: " +str(file_path))
        with open(file_path, 'r') as file:
            content = file.read()
    except FileNotFoundError:
        print("Error: The file does not exist.")
    except Exception as e:
        print(f"An error occurred: {e}")

    print(str(content))

    return
    

def make_post_request(base_url):

    
    latitude = 34.0156229728407
    longitude = -118.49441383847054
    radius = 10.0

    
    coord_url = f"{base_url}/location/?latitude={latitude}&longitude={longitude}&radius={radius}"
    

    response = requests.post(coord_url)

    print(response)     
    return

    with open(file_path, 'rb') as audio_file:
        files = {
            'file': (file_path, audio_file, 'audio/wav')
        }
        # Sending a POST request with the file
        response = requests.post(url, files=files)
    
    # Checking if the request was successful
    if response.status_code == 200:
        print("Request successful!")
        print("Response content:")
        print(response.text)  # Printing the content of the response
    else:
        print(f"Request failed with status code: {response.status_code}")

def main():
    base_url = "http://localhost:4000/api"
    file_path = "test.wav"

    while True:
        make_post_request(base_url)
        time.sleep(5)
        make_get_request(base_url)
        time.sleep(5)

if __name__ == "__main__":
    main()