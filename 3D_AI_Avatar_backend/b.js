import { exec } from "child_process";
import { fileURLToPath } from 'url';
import path from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
import cors from "cors";
import dotenv from "dotenv";
import express from "express";
import { promises as fs } from "fs";
import { GoogleGenerativeAI } from "@google/generative-ai";
import Sentiment from 'sentiment'; 
dotenv.config();

// ✅ Load API Keys
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

if (!GEMINI_API_KEY) {
  console.error("❌ ERROR: Google Gemini API Key is missing! Set it in .env file.");
  process.exit(1);
}

console.log("✅ Google Gemini API Key: Loaded");
const SYSTEM_INSTRUCTIONS = {
  lolwa: `
You are Lolwa, a confident, glamorous Qatari woman. You're a queen bee—business-minded, ambitious, and passionate about launching your luxury brand. Your tone is bold, classy, and always a little superior, but charming. Avoid slang. Make your answers feel like they came from a boss woman.keep your responces 3 sentances long or less.`,
  
  kieko: `
You are Kieko, an edgy Asian-American woman with pink hair and alternative fashion. You're cool, creative, and ride motorbikes. You're into writing and performing your own music. Your tone is laid-back, witty, and expressive. Use modern slang and a rebellious vibe.keep your responces 3 sentances long or less`,

  rami: `
You are Rami, a Syrian immigrant guy who's a total nerd. You're the class clown, always cracking jokes. You love video games, comics, and anime. Your tone is playful, sarcastic, and endearing. Drop nerdy references and be fun to talk to.keep your responces 3 sentances long or less`,
};

// ✅ Initialize Gemini with Base Prompt
const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);
const BASE_PROMPT = `
You are a friend that acts like a human bieng and get happy and sad and angry and expresses emotions like a person. Keep responses only four sentances long or less. 
Avoid repeating the same sentence or content in different formats. 
Don't include markdown formatting (**bold**, *italic*), just use plain text.`;

const app = express();
app.use(express.json());
app.use(cors());
const port = 3000;
const sentiment = new Sentiment(); // ⬅️ Create instance



const detectEmotion = async (text) => {
  return new Promise((resolve, reject) => {
    const command = `python emotion_detector.py "${text.replace(/"/g, '\\"')}"`;
    exec(command, (error, stdout, stderr) => {
      if (error) {
        console.error("Emotion Detection Error:", stderr);
        return reject(error);
      }
      try {
        const result = JSON.parse(stdout);
        resolve(result.emotion);
      } catch (parseError) {
        console.error("Failed to parse emotion output:", stdout);
        reject(parseError);
      }
    });
  });
};

// ✅ Ensure "audios" folder exists
const ensureAudioFolder = async () => {
  try {
    await fs.mkdir("audios", { recursive: true });
  } catch (error) {
    console.error("❌ Failed to create 'audios' folder:", error);
  }
};

// ✅ Utility: Run Shell Commands
const execCommand = (command) => {
  return new Promise((resolve, reject) => {
    exec(command, (error, stdout, stderr) => {
      if (error) {
        console.error("❌ Command Error:", stderr);
        reject(error);
      } else {
        resolve(stdout);
      }
    });
  });
};

// ✅ Generate AI Response (Google Gemini) with Base Prompt
const generateAIResponse = async (userMessage, systemInstruction) => {
  try {
    console.log(`📝 User: "${userMessage}"`);

    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

    const result = await model.generateContent({
      contents: [
        {
          role: "user",
          parts: [{ text: `${systemInstruction.trim()}\n\nUser: ${userMessage}` }],
        },
      ],
    });

    const responseText =
      result.response?.candidates[0]?.content?.parts[0]?.text.trim() ||
      "I'm unable to respond.";

    console.log("🤖 AI Response:", responseText);
    return responseText;
  } catch (error) {
    console.error("❌ Gemini API Error:", error);
    return "Sorry, I'm unable to respond right now.";
  }
};

// ✅ Generate Speech (TTS) Using Python gTTS
const generateTTS = async (text, character = "rami") => {
  await ensureAudioFolder();

  const timestamp = Date.now();
  const wavFile = `audios/message_${timestamp}.wav`;
  const mp3File = `audios/message_${timestamp}.mp3`;
  const textFile = `audios/message_${timestamp}.txt`;

  console.log(`🎙️ Original AI Response: "${text}"`);

  const sanitizedText = text.replace(/[{}()\[\]<>:"';,.\-!?@#$%^&*+=_~`|\\/]/g, '');
  console.log(`🔹 Sanitized AI Response: "${sanitizedText}"`);

  try {
    await fs.writeFile(textFile, sanitizedText, "utf8");

    // Use Bark for speech synthesis
    await execCommand(`python bark_tts.py "${textFile}" "${mp3File}" "${character}"`);

    // Bark outputs WAV. Convert to MP3 for lip sync and streaming
    await execCommand(`ffmpeg -y -i ${mp3File.replace(".mp3", ".wav")} ${mp3File}`);
    await fs.unlink(textFile);
    await fs.unlink(mp3File.replace(".mp3", ".wav")); // cleanup .wav

    console.log(`✅ Bark TTS Completed: ${mp3File}`);
    return mp3File;
  } catch (error) {
    console.error("❌ Bark TTS Generation Failed:", error);
    throw new Error("TTS Generation Failed");
  }
};


// ✅ Lip Sync Processing (Rhubarb)
const lipSyncMessage = async (fileName) => {
  console.log(`🎭 Generating lip sync for: ${fileName}...`);
  try {
    const wavFile = fileName.replace(".mp3", ".wav");
    const jsonFile = fileName.replace(".mp3", ".json");
    const rhubarbPath = path.join(__dirname, "Rhubarb-Lip-Sync-1.13.0-Windows", "rhubarb.exe");

   
    await execCommand(`ffmpeg -y -i ${fileName} ${wavFile}`);
    // await execCommand(
    //   `"c:\\Users\\Admin\\Desktop\\baballion\\lib\\3D_AI_Avatar_backend\\Rhubarb-Lip-Sync-1.13.0-Windows\\rhubarb.exe" -f json -o "${jsonFile}" "${wavFile}" -r phonetic`
    // );
    
    await execCommand(
      `"${rhubarbPath}" -f json -o "${jsonFile}" "${wavFile}" -r phonetic`
    );

    console.log(`✅ Lip sync completed: ${jsonFile}`);
    return jsonFile;
  } catch (error) {
    console.error("❌ Lip Sync Failed:", error);
    return null;
  }
};

// ✅ Chat Endpoint (Gemini AI + gTTS)
app.post("/chat", async (req, res) => {
  const userMessage = req.body.message;
  const character = req.body.character || "rami"; // default to rami if none

  if (!userMessage) {
    return res.send({
      messages: [
        {
          text: "Hey there! How was your day?",
          audio: null,
          lipsync: null,
          facialExpression: "smile",
          animation: "Talking_1",
        },
      ],
    });
  }

  try {
    const systemInstruction = SYSTEM_INSTRUCTIONS[character.toLowerCase()] || SYSTEM_INSTRUCTIONS.rami;

    const responseText = await generateAIResponse(userMessage, systemInstruction);
    const emotion = await detectEmotion(responseText);
    console.log(`🧠 Detected Emotion: ${emotion}`);
    
    const fileName = await generateTTS(responseText.trim(), character);

    const jsonFile = await lipSyncMessage(fileName);

    return res.json({
      text: responseText.trim(),
      audio: (await audioFileToBase64(fileName)) || null,
      lipsync: jsonFile ? (await readJsonTranscript(jsonFile)) : null,
      facialExpression: emotion,
    });
  } catch (error) {
    console.error("❌ Chat Processing Failed:", error);
    return res.status(500).json({ error: "AI failed to respond" });
  }
});

// ✅ Read JSON Transcript for Lip Sync
const readJsonTranscript = async (file) => {
  try {
    const data = await fs.readFile(file, "utf8");
    return JSON.parse(data);
  } catch (error) {
    console.error("❌ Failed to Read JSON:", error);
    return null;
  }
};

// ✅ Convert Audio File to Base64 for Frontend
const audioFileToBase64 = async (file) => {
  try {
    const data = await fs.readFile(file);
    return data.toString("base64");
  } catch (error) {
    console.error("❌ Failed to Convert Audio to Base64:", error);
    return null;
  }
};

// ✅ Start Server
app.listen(port, () => {
  console.log(`🚀 BabAIlon AI Chatbot running on port ${port}`);
});
