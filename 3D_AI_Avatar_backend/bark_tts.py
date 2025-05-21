import os
import sys
import requests

# Read args: text_file, output_file, character
text_file = sys.argv[1]
output_file = sys.argv[2]
character = sys.argv[3].lower()

# Load ElevenLabs API key from ENV or fallback
api_key = os.getenv("ELEVEN_API_KEY") or "sk_c3b3e1d611b25faa3fc0352c2354ebbd32f9cae4f977e852"
if not api_key:
    print("ERROR: ElevenLabs API key not found.")
    sys.exit(1)

# Read text content
with open(text_file, "r", encoding="utf-8") as f:
    text = f.read().strip()

# Voice selection (ensure voices support multilingual model)
voice_map = {
    "rami": "nPczCjzI2devNBz1zQrb",     # Nerdy male (supports multilingual)
    "lolwa": "Xb7hH8MSUJpSbSDYk0k2",    # Fancy female (supports multilingual)
    "kieko": "Xb7hH8MSUJpSbSDYk0k2"     # Chill female (same voice, can be updated)
}
voice = voice_map.get(character, "Rachel")

print(f"[TTS] Using ElevenLabs voice: {voice}")

# API call
url = f"https://api.elevenlabs.io/v1/text-to-speech/{voice}"
headers = {
    "xi-api-key": api_key,
    "Content-Type": "application/json"
}
payload = {
    "text": text,
    "model_id": "eleven_multilingual_v2",  # ✅ supports Arabic + English
    "voice_settings": {
        "stability": 0.4,
        "similarity_boost": 0.7
    }
}

response = requests.post(url, headers=headers, json=payload)

if response.status_code != 200:
    print(f"ERROR: ElevenLabs API returned {response.status_code}")
    print(response.text)
    sys.exit(1)

# Save as WAV (rename if needed)
wav_file = output_file.replace(".mp3", ".wav")
with open(wav_file, "wb") as f:
    f.write(response.content)

print(f"[TTS] Audio saved to {wav_file}")
