# Import libraries
import vertexai, googlemaps
from vertexai.generative_models import GenerativeModel, Part
import json, requests
from uagents import Agent, Context, Bureau, Model

from timezonefinder import TimezoneFinder
from datetime import datetime
import pytz
import asyncio


class NearbyArea(Model):
    latitude: float
    longitude: float
    radius: float


class Buildings(Model):
    buildings: dict


class Message(Model):
    msg: str


sound_scape = Agent(name="SoundScape", seed="EnvironmentToMusic")
nearby_buildings = Agent(name="NearbyBuildings", seed="WhatsNearby")
weather_API = Agent(name="WeatherAPI", seed="WeatherWhiz")
time_API = Agent(name="TimeAPI", seed="TimeWhiz")


def generate_response(project_id: str, location: str, query: str) -> str:
    # Initialize Vertex AI
    vertexai.init(project=project_id, location=location)
    # Load the model
    multimodal_model = GenerativeModel("gemini-1.0-pro-vision")

    # Query the model
    response = multimodal_model.generate_content(
        [
            # Add an example query
            query
        ]
    )

    return response


@nearby_buildings.on_message(model=NearbyArea)
async def get_nearby_buildings(ctx: Context, sender: str, msg: NearbyArea):
    ctx.logger.info(f"Building received message")
    # Get stored values and message values
    GOOGLE_MAPS_KEY = ctx.storage.get("GOOGLE_MAPS_KEY")
    latitude = msg.latitude
    longitude = msg.longitude
    radius = msg.radius

    client = googlemaps.Client(key=GOOGLE_MAPS_KEY)

    # Define search request
    search_request = {
        "location": (latitude, longitude),
        "radius": radius,
        # Keyword or category filtering can be added here (optional)
        "type": "point_of_interest",  # Example for category filter
    }

    # Send Nearby Search request
    nearby_places = client.places_nearby(**search_request)

    # Process search results
    if not nearby_places["status"] == "OK":
        print("Error: Nearby search failed")
        await ctx.send(sound_scape.address, None)

    await ctx.send(sound_scape.address, Buildings(buildings=nearby_places))


@weather_API.on_message(model=NearbyArea)
async def get_weather_description(ctx: Context, sender: str, msg: NearbyArea):
    ctx.logger.info(f"Weather received message")
    # Get stored values and message values
    OPEN_WEATHER_KEY = ctx.storage.get("OPEN_WEATHER_KEY")
    latitude = msg.latitude
    longitude = msg.longitude

    # Build the API URL with your API key, coordinates, and units (metric)
    url = f"https://api.openweathermap.org/data/2.5/weather?lat={latitude}&lon={longitude}&appid={OPEN_WEATHER_KEY}&units=metric"

    # Make the API call using requests library
    response = requests.get(url)

    # Check for successful response (status code 200)
    if response.status_code == 200:
        # Parse the JSON response
        weather_data = response.json()

        # Extract relevant weather information
        description = weather_data["weather"][0]["description"]

        await ctx.send(sound_scape.address, Message(msg=description))
    else:
        # Handle error if API call fails
        print(f"Error: API request failed with status code {response.status_code}")
        await ctx.send(sound_scape.address, None)


@time_API.on_message(model=NearbyArea)
async def time_API_message_handler(ctx: Context, sender: str, msg: NearbyArea):
    ctx.logger.info(f"Time received message")
    # Get stored values and message values
    latitude = msg.latitude
    longitude = msg.longitude

    # Get timezone
    tf = TimezoneFinder()
    timezone_str = tf.timezone_at(lat=latitude, lng=longitude)

    # Get current time in the timezone
    tz = pytz.timezone(timezone_str)
    current_time = datetime.now(tz)
    hour_min = str(current_time.hour) + ":"
    mins = str(current_time.minute)
    if current_time.minute < 10:
        mins = "0" + str(current_time.minute)
    hour_min += mins

    if current_time.hour < 12:
        hour_min += " AM"
    else:
        hour_min += " PM"

    await ctx.send(sound_scape.address, Message(msg=hour_min))


def read_variables_from_file(file_path):
    variables = {}
    with open(file_path, "r") as file:
        for line in file:
            line = line.strip()
            if line:
                key, value = line.split("=")
                variables[key.strip()] = value.strip()
    return variables


@nearby_buildings.on_event("startup")
async def nearby_buildings_startup(ctx: Context):

    keys_path = "keys.txt"

    variables = read_variables_from_file(keys_path)

    GOOGLE_MAPS_KEY = variables["MAPSKEY"]

    ctx.storage.set("GOOGLE_MAPS_KEY", GOOGLE_MAPS_KEY)
    ctx.logger.info(f"startup complete for buildings")


@weather_API.on_event("startup")
async def weather_API_startup(ctx: Context):

    keys_path = "keys.txt"

    variables = read_variables_from_file(keys_path)

    OPEN_WEATHER_KEY = variables["WEATHERKEY"]

    ctx.storage.set("OPEN_WEATHER_KEY", OPEN_WEATHER_KEY)
    ctx.logger.info(f"startup complete for weather")


@sound_scape.on_event("startup")
async def sound_scape_startup(ctx: Context):

    keys_path = "keys.txt"

    variables = read_variables_from_file(keys_path)

    GOOGLE_PROJECT_KEY = variables["PROJECTKEY"]

    ctx.storage.set("GOOGLE_PROJECT_KEY", GOOGLE_PROJECT_KEY)

    ctx.storage.set("time_received", False)
    ctx.storage.set("buildings_received", False)
    ctx.storage.set("weather_received", False)
    ctx.logger.info(f"startup complete for soundscape")


@sound_scape.on_interval(20)
async def generate_prompt(ctx: Context):
    ctx.logger.info(f"generating prompt for music")

    GOOGLE_PROJECT_KEY = ctx.storage.get("GOOGLE_PROJECT_KEY")

    latitude = 34.0156229728407
    longitude = -118.49441383847054

    radius = 20.0

    # Location of Gemini Pro server in LA, California
    location = "us-west1"

    nearby_area = NearbyArea(latitude=latitude, longitude=longitude, radius=radius)

    ctx.logger.info(f"Before calls")

    await ctx.send(nearby_buildings.address, nearby_area)

    ctx.logger.info(f"After first call")

    await ctx.send(weather_API.address, nearby_area)

    await ctx.send(time_API.address, nearby_area)

    ctx.logger.info(f"After all calls")

    while (
        ctx.storage.get("time_received") != True
        or ctx.storage.get("buildings_received") != True
        or ctx.storage.get("weather_received") != True
    ):
        await asyncio.sleep(0.5)
        # print(ctx.storage.get('time_received'), ctx.storage.get('buildings_received'), ctx.storage.get('weather_received'))

    ctx.storage.set("time_received", False)
    ctx.storage.set("buildings_received", False)
    ctx.storage.set("weather_received", False)

    nearby_places = ctx.storage.get("nearby_places")
    weather = ctx.storage.get("weather")
    time_of_day = ctx.storage.get("time_of_day")

    ctx.logger.info("time_of_day: " + time_of_day)

    if nearby_places is not None:
        with open("queries.txt", "w") as outfile:
            buildings_found = False
            try:
                vicinity = nearby_places["results"][0]["vicinity"]
                name = []
                for i in range(0, 3):
                    try:
                        name[i] = nearby_places["results"][i]["name"]
                        buildings_found = True
                    except:
                        ctx.logger.error(
                            "Could not process the " + i + " place nearby."
                        )
            except:
                ctx.logger.error(
                    "No such buildings were found nearby, or a failure occurred during the prompt building process."
                )

            prompt = ""

            if buildings_found:
                if len(name) == 1:
                    prompt = (
                        "Suppose you are near the establishment/building "
                        + name[0]
                        + " in "
                        + vicinity
                        + "."
                    )
                elif len(name) == 2:
                    prompt = (
                        "Suppose you are near these two buildings in "
                        + vicinity
                        + ", closest being first and furthest away being last: "
                        + name[0]
                        + " and "
                        + name[1]
                        + "."
                    )
                else:
                    prompt = (
                        "Suppose you are near these three buildings in "
                        + vicinity
                        + ", closest being first and furthest away being last: "
                        + name[0]
                        + ", "
                        + name[1]
                        + ", "
                        + name[2]
                        + "."
                    )

                prompt += (
                    " If you had to come up with a vibe of music for these buildings while taking into account the current time of day ("
                    + time_of_day
                    + ") and weather of the area ("
                    + weather
                    + "), what would that vibe be? Please consolidate the recommendations for the type of vibe into a list. At the end, can you combine those into a prompt for a music generation model and begin the prompt with a @ symbol so I know where it starts?"
                )
                outfile.write(prompt + "\n\n")
            else:
                prompt = (
                    "If you had to come up with a vibe of music for the area around "
                    + vicinity
                    + " while taking into account the current time of day ("
                    + time_of_day
                    + ") and weather of the area ("
                    + weather
                    + "), what would that vibe be? Please consolidate the recommendations for the type of vibe into a list. At the end, can you combine those into a prompt for a music generation model and begin the prompt with a @ symbol so I know where it starts?"
                )

            response = generate_response(GOOGLE_PROJECT_KEY, location, prompt)

            parts = response.text.split("@")

            # Check if there is a "@" symbol and return the second part if it exists
            if len(parts) > 1:
                music_prompt = parts[1]
                with open("music_prompt.txt", "w") as outfile:
                    outfile.write(music_prompt)
            else:
                ctx.logger.error("Failed to get a music prompt")

    with open("buildings.json", "w") as outfile:
        # Use json.dump to write the dictionary to the file
        json.dump(nearby_places, outfile)


@sound_scape.on_message(model=Buildings)
async def building_handler(ctx: Context, sender: str, msg: Buildings):
    # print(msg.buildings)
    ctx.storage.set("nearby_places", msg.buildings)
    ctx.storage.set("buildings_received", True)


@sound_scape.on_message(model=Message)
async def message_handler(ctx: Context, sender: str, msg: Message):
    if sender == weather_API.address:
        ctx.storage.set("weather", msg.msg)
        ctx.storage.set("weather_received", True)
    elif sender == time_API.address:
        ctx.storage.set("time_of_day", msg.msg)
        ctx.storage.set("time_received", True)


bureau = Bureau(port=8006)  # endpoint="http://localhost:8006/submit")
bureau.add(nearby_buildings)
bureau.add(weather_API)
bureau.add(time_API)
bureau.add(sound_scape)

if __name__ == "__main__":
    bureau.run()
