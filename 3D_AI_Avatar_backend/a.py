from bark import generate_audio, SAMPLE_RATE, preload_models
from scipy.io.wavfile import write as write_wav
import torch

try:
    print("Starting Bark TTS test...")

    # Optional but helps on first run
    print("Preloading Bark models...")
    preload_models()

    # Input text
    text = "Hello there! This is a test of Bark Text to Speech. How do I sound?"

    # Use GPU if available
    device = "cuda" if torch.cuda.is_available() else "cpu"
    print(f"Using device: {device}")

    print("Generating audio...")
    audio_array = generate_audio(text, device=device)

    print("Saving output to 'bark_test.wav'...")
    write_wav("bark_test.wav", SAMPLE_RATE, audio_array)

    print("Bark TTS test completed successfully. Check 'bark_test.wav'.")

except Exception as e:
    print(f"Error occurred: {e}")
