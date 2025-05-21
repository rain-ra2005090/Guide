import sys
import json
import joblib

# Load the trained model
model = joblib.load('emotion_classifier_pipe_lr.pkl')

def predict_emotion(text):
    prediction = model.predict([text])[0]
    return prediction

if __name__ == "__main__":
    input_text = sys.argv[1]
    emotion = predict_emotion(input_text)
    print(json.dumps({"emotion": emotion}))
