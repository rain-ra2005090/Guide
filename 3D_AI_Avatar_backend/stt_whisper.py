# stt_whisper.py
import whisper
import sys
import json
import os
import subprocess

input_path = sys.argv[1]
wav_path = input_path + ".wav"

subprocess.run(["ffmpeg", "-y", "-i", input_path, wav_path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

model = whisper.load_model("base")
result = model.transcribe(wav_path, language=None)  # Auto-detects Arabic or English

print(json.dumps({"text": result["text"]}, ensure_ascii=False))
os.remove(wav_path)
