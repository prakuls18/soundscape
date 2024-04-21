from audiocraft.models import MusicGen
from audiocraft.data.audio import audio_write
import time 

start_time = time.time()
model = MusicGen.get_pretrained("large")
model.set_generation_params(duration=300)  # generate 8 seconds.

descriptions = ["create music that has smooth TRANSITION BETWEEN GENRES EVERY 60 SECONDS the 5 minutes structured as follows - FIRSTLY Sunny afternoon transitioning into a warm Californian sunset. Uplifting and chill vibes with a touch of sophistication. Imagine cruising down Hollywood streets with the windows down, feeling the warm breeze and the golden light. Genre: Electronic / Downtempo / Nu-Jazz (choose one or blend as you see fit)., SECOND : Chill, instrumental, ambient classical music reminiscent of a rainy day spent wandering through the Los Angeles County Museum of Art (LACMA) in Westwood.  **, THIRD: Genre: Upbeat Indie Rock with Skate Punk influences and a California beach vibe. Instruments: Electric guitars, drums, prominent bass line. Maybe a laid-back saxophone solo for a touch of coolness. Tempo: Medium to fast, energetic but with a groove. FOURTH: Generate a piece of ambient music with a serene and reflective vibe.  Incorporate the gentle hum of the city at night with sparse, twinkling sounds to represent the clear sky.  As the music progresses, introduce a subtle hint of hopeful anticipation for the coming day. FIFTH: Upbeat and energetic lo-fi beats with a cool and refreshing Californian feel.  Confident and stylish melody that reflects the midday heat at the Hollywood Sign"]
descriptions2 = ["create music that has smooth TRANSITION BETWEEN GENRES EVERY 60 SECONDS the 5 minutes structured as follows - FIRSTLY A triumphant, orchestral piece that captures the legacy of athletic greatness and numerous historic victories that have taken place in Pauley Pavilion., SECONDLY - An upbeat, energetic track that mirrors the excitement and adrenaline of a UCLA basketball game, incorporating elements of collegiate band music and cheer chants. THIRDLY -  A reflective, ambient piece that evokes the feeling of an empty arena after a game, highlighting the quiet moments of reflection beneath the bright lights of the court. FOURTHLY -  A vibrant, electronic dance music (EDM) track that encapsulates the spirit of UCLA student life and the dynamic energy of youth and innovation. FIFTH -  A motivational, uplifting song that inspires the listener to strive for excellence and perseverance, much like the athletes who have competed on this famous court. A funky, groove-oriented piece that could represent the anticipation and excitement of basketball season kick-offs, capturing the spirit of new beginnings each season."]
wav = model.generate(descriptions2)  # generates 2 samples.

for idx, one_wav in enumerate(wav):
    # Will save under {idx}.wav, with loudness normalization at -14 db LUFS.
    audio_write(f'{idx}', one_wav.cpu(), model.sample_rate, strategy="loudness")

end_time = time.time()
diff_time = end_time - start_time

print(diff_time)