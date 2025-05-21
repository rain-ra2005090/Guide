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

# ✅ Hardcoded voice IDs based on your system
MALE_VOICE_ID = "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Speech\\Voices\\Tokens\\TTS_MS_EN-US_DAVID_11.0"
FEMALE_VOICE_ID = "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Speech\\Voices\\Tokens\\TTS_MS_EN-US_ZIRA_11.0"

# ✅ Set voice based on gender
if gender == "male":
    engine.setProperty("voice", MALE_VOICE_ID)
else:
    engine.setProperty("voice", FEMALE_VOICE_ID)

# Save to WAV
wav_file = output_mp3.replace(".mp3", ".wav")
engine.save_to_file(text, wav_file)
engine.runAndWait()

# Convert WAV to MP3
sound = AudioSegment.from_wav(wav_file)
sound.export(output_mp3, format="mp3")
os.remove(wav_file)
