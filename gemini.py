import google.generativeai as genai
import pandas as pd

genai.configure(api_key='')
model = genai.GenerativeModel('gemini-pro')

response = model.generate_content("Make me a 20 row long table with the following 2 columns in this exact format - Column 1 formatted exactly as follows with the stuff in parentheses changing each row:  Suppose you are near these two buildings (ANYWHERE BETWEEN 1 AND 3 BUILDINGS NEAR EACH OTHER IN LA) closest being first and furthest away being last, If you had to come up with a vibe of music for the area around this place while taking into account the current time of day which is (a time of ur choice) and weather of the area (a weather of ur choice), what would that vibe be? Please consolidate the recommendations for the type of vibe into a list. At the end, can you combine those into a prompt for a music generation model and begin the prompt with a @ symbol so I know where it starts?. Column 2 should be different each time and basically be the prompt that column 1 asks for - THE RESPONSE IN COLUMN 2 SHOULD BE different each time nd BASED ON THE SPECIFIC VARIABLES THAT ARE GENERATED COLUMN 1 - NAMELY THE PLACES NEARBY, THE TIME OF DAY, WEATHER, AND LOCATION")
print(response.text)





