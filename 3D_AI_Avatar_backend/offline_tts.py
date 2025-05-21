import pyttsx3
import sys
import os
from pydub import AudioSegment

# Args: [1]=text_file [2]=output_mp3 [3]=gender
text_path = sys.argv[1]
output_mp3 = sys.argv[2]
gender = sys.argv[3].lower()

with open(text_path, "r", encoding="utf-8") as f:
    text = f.read()

engine = pyttsx3.init()
voices = engine.getProperty("voices")

# Try to find voice by gender
selected_voice = voices[0]  # fallback
for voice in voices:
    if gender in voice.name.lower() or gender in voice.id.lower():
        selected_voice = voice
        break

engine.setProperty("voice", selected_voice.id)

# Output to WAV temporarily
wav_file = output_mp3.replace(".mp3", ".wav")
engine.save_to_file(text, wav_file)
engine.runAndWait()

# Convert to MP3 using pydub
sound = AudioSegment.from_wav(wav_file)
sound.export(output_mp3, format="mp3")
os.remove(wav_file)
