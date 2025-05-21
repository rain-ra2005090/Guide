import sys
import json
import torch
from sentence_transformers import SentenceTransformer, util

# ✅ Read user input from command line
question = sys.argv[1]

# ✅ Load predefined script
with open("presentation_script.json", "r", encoding="utf-8") as f:
    script = json.load(f)

# ✅ Use GPU if available
device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"🔧 Using device: {device}", file=sys.stderr)

# ✅ Load lighter multilingual model
model = SentenceTransformer("paraphrase-multilingual-MiniLM-L12-v2", device=device)

# ✅ Encode with GPU or CPU
script_questions = list(script.keys())
script_embeddings = model.encode(script_questions, convert_to_tensor=True, device=device)
user_embedding = model.encode(question, convert_to_tensor=True, device=device)

# ✅ Compute cosine similarity
cosine_scores = util.cos_sim(user_embedding, script_embeddings)[0]
best_score, best_idx = float(cosine_scores.max()), int(cosine_scores.argmax())

# ✅ Match output
if best_score > 0.8:
    best_question = script_questions[best_idx]
    response = {
        "match": True,
        "question": best_question,
        "answer": script[best_question]
    }
else:
    response = {"match": False}

# ✅ Output response as UTF-8 (for Windows compatibility)
sys.stdout.buffer.write(json.dumps(response, ensure_ascii=False).encode('utf-8'))
sys.stdout.buffer.flush()
