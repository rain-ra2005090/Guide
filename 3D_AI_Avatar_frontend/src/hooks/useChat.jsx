import { createContext, useContext, useEffect, useState } from "react";

const backendUrl = import.meta.env.VITE_API_URL || "http://localhost:3000";

const ChatContext = createContext();

export const ChatProvider = ({ children, character }) => {
  const [messages, setMessages] = useState([]);
  const [message, setMessage] = useState(null);
  const [loading, setLoading] = useState(false);
  const [cameraZoomed, setCameraZoomed] = useState(true);
  const startListening = () => {
    const recognition = new window.webkitSpeechRecognition() || new window.SpeechRecognition();
    recognition.continuous = false;
const langMap = {
  rami: "ar-SA",
  lolwa: "ar-SA",
  kieko: "en-US"
};

recognition.lang = langMap[character?.toLowerCase()] || "en-US";

  
    recognition.onstart = () => {
      console.log("🎙️ Listening...");
      setLoading(true);
    };
  
    recognition.onerror = (e) => {
      console.error("❌ STT Error:", e.error);
      setLoading(false);
    };
  
    recognition.onresult = (event) => {
      const transcript = event.results[0][0].transcript;
      console.log("🗣️ Transcribed:", transcript);
      chat(transcript);
    };
  
    recognition.onend = () => {
      setLoading(false);
    };
  
    recognition.start();
  };
  
  const chat = async (messageText) => {
    setLoading(true);
    try {
      const response = await fetch(`${backendUrl}/chat`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: messageText,
          character, // ✅ Pass character to backend
        }),
      });

      const data = await response.json();

      if (data.audio && data.lipsync) {
        console.log("✅ Received New Audio & Lip Sync:", data.audio, data.lipsync);
      } else {
        console.warn("⚠️ No audio or lip sync received from backend!");
      }

      const newMessage = {
        text: data.text,
        audio: data.audio || null,
        lipsync: data.lipsync || null,
        facialExpression: data.facialExpression || "smile",
        animation: "Talking_1",
      };

      setMessages((prevMessages) => [...prevMessages, newMessage]);
    } catch (error) {
      console.error("❌ Chat Error:", error);
    }
    setLoading(false);
  };

  const onMessagePlayed = () => {
    setTimeout(() => {
      setMessages((prevMessages) => prevMessages.slice(1));
    }, 1000);
  };

  useEffect(() => {
    if (messages.length > 0) {
      setMessage(messages[0]);
    } else {
      setMessage(null);
    }
  }, [messages]);

  return (
    <ChatContext.Provider
      value={{
        chat,
        message,
        onMessagePlayed,
        loading,
        cameraZoomed,
        setCameraZoomed,
        startListening,
      }}
    >
      {children}
    </ChatContext.Provider>
  );
};

export const useChat = () => {
  const context = useContext(ChatContext);
  if (!context) {
    throw new Error("useChat must be used within a ChatProvider");
  }
  return context;
};
