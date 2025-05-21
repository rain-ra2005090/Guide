

// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { doc, updateDoc, arrayUnion, getDoc } from "firebase/firestore"; // For updating Firestore
import React, { useState, useRef, useEffect } from "react";
import { useChat } from "../hooks/useChat";
import { FaEllipsisV } from "react-icons/fa";  // Import the 3-dot icon
import { FaRegFutbol, FaEdit, FaBook } from "react-icons/fa";  // Game icons
import { Link } from "react-router-dom";
import { getFirestore } from "firebase/firestore"; // <-- Ensure this is imported
import { query, where, getDocs, collection } from "firebase/firestore";

// Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyDf1xpgc1in-bzrJa7eETjJGJ8nZQxAWfQ",
  authDomain: "babailon.firebaseapp.com",
  projectId: "babailon",
  storageBucket: "babailon.firebasestorage.app",
  messagingSenderId: "243712887789",
  appId: "1:243712887789:web:a4e1a2b05cc06ac16eb5e4",
  measurementId: "G-X90Y9QS3PQ"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);  // Ensure `db` is initialized correctly

const analytics = getAnalytics(app);

export const UI = ({ hidden, ...props }) => {
  const input = useRef();
  const { chat, loading, cameraZoomed, setCameraZoomed, message, startListening } = useChat();
  const [originParam, setOriginParam] = useState("");
  const [langParam, setLangParam] = useState("");
  const [emailParam, setEmailParam] = useState("");
  const [vocabScore, setVocabScore] = useState("");
  const [pronScore, setPronScore] = useState("");
  const [grammarScore, setGrammarScore] = useState("");

  // New state for storing the scores
  const [scoreData, setScoreData] = useState({
    fluency_score: 0,
    grammar_score: 0,
    pronunciation_score: 0,
    vocabulary_score: 0,
  });

  // Send message to chat
  const sendMessage = () => {
    const text = input.current.value;
    if (!loading && !message) {
      chat(text);
      input.current.value = "";
    }
  };

  const buildGameURL = (path) => {
    const origin = window.location.origin;
    const base = `${originParam}/#/${path}?email=${emailParam}&lang=${langParam}&origin=${origin}`;
    const extraParams = [];
      if (vocabScore) extraParams.push(`vocabulary_score=${vocabScore}`);
    if (pronScore) extraParams.push(`pronounciation_score=${pronScore}`);
    if (grammarScore) extraParams.push(`grammer_score=${grammarScore}`);
  
    return extraParams.length ? `${base}&${extraParams.join("&")}` : base;
  };
  
  
  const saveScoreToFirebase = async () => {
    try {
      // Ensure scores are correctly populated with URL params or default to 0
      const currentDate = new Date().toISOString().split('T')[0]; // YYYY-MM-DD format
      const updatedScore = {
        date: currentDate,
        fluency_score: Math.round(
          ((scoreData.grammar_score || 0) +
           (scoreData.pronunciation_score || 0) +
           (scoreData.vocabulary_score || 0)) / 3
        ),        grammar_score: scoreData.grammar_score || 0,
        pronunciation_score: scoreData.pronunciation_score || 0,
        vocabulary_score: scoreData.vocabulary_score || 0,
      };
  
      // Query the Firestore collection to find the document where `user_email` matches
      const q = query(
        collection(db, "dashboards"),
        where("user_email", "==", emailParam)
      );
      
      // Get the user document
      const querySnapshot = await getDocs(q);
      if (!querySnapshot.empty) {
        // Assuming there is only one document that matches the email
        const userDoc = querySnapshot.docs[0];
        const userData = userDoc.data();
  
        const languageIndex = userData.languages.findIndex(
          (lang) => lang.language === langParam
        );
  
        if (languageIndex >= 0) {
          userData.languages[languageIndex].scores.push(updatedScore);
        }
        // Update the document with the new scores
        await updateDoc(userDoc.ref, {
          languages: userData.languages,
        });
  
        console.log("Score added successfully!");
      } else {
        console.log("User not found in Firestore.");
      }
    } catch (error) {
      console.error("Error saving score to Firebase:", error);
    }
  };

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const origin = params.get("origin");
    const lang = params.get("lang");
    const email = params.get("email");
    const vocab = params.get("vocabulary_score");
    const pron = params.get("pronounciation_score");
    const grammar = params.get("grammer_score");
  
    if (origin) {
      console.log("Origin from URL:", origin);
      setOriginParam(origin);
    }
    if (lang) {
      console.log("Language from URL:", lang);
      setLangParam(lang);
    }
    if (email) {
      const decodedEmail = decodeURIComponent(email);  // Decode the email
      console.log("Email from URL:", decodedEmail);
      setEmailParam(decodedEmail);
    }
  
    // Set the score data in the state object
    if (vocab) {
      setScoreData((prev) => ({ ...prev, vocabulary_score: parseInt(vocab) }));
      setVocabScore(vocab); 
    }
    if (pron) {
      setScoreData((prev) => ({ ...prev, pronunciation_score: parseInt(pron) }));
      setPronScore(pron); 
    }
    if (grammar) {
      setScoreData((prev) => ({ ...prev, grammar_score: parseInt(grammar) }));
      setGrammarScore(grammar);  
    }

    
  }, []);
  

  // Menu and button functionality
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const toggleMenu = () => setIsMenuOpen(!isMenuOpen);

  if (hidden) {
    return null;
  }

  return (
    <div className="fixed top-0 left-0 right-0 bottom-0 z-10 flex justify-between p-4 flex-col">
      <div className="self-start">
        
      </div>

      {/* Menu button (top-right) */}
    
      {/* Controls */}
      <div className="w-full flex flex-col items-end justify-center gap-4">
       
        {/* Zoom Camera Button */}
        <button
          onClick={() => setCameraZoomed(!cameraZoomed)}
          className="pointer-events-auto bg-[#f9be1a] hover:bg-[#e0a816] text-white p-4 rounded-md"
        >
          {cameraZoomed ? (
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-6 h-6">
              <path strokeLinecap="round" strokeLinejoin="round" d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607zM13.5 10.5h-6" />
            </svg>
          ) : (
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-6 h-6">
              <path strokeLinecap="round" strokeLinejoin="round" d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607zM10.5 7.5v6m3-3h-6" />
            </svg>
          )}
        </button>
{/* Exit Button */}


        {/* Green Screen Toggle Button */}
        {/* <button
          onClick={() => {
            const body = document.querySelector("body");
            if (body.classList.contains("greenScreen")) {
              body.classList.remove("greenScreen");
            } else {
              body.classList.add("greenScreen");
            }
          }}
          className="pointer-events-auto bg-[#f9be1a] hover:bg-[#e0a816] text-white p-4 rounded-md"
        >
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-6 h-6">
            <path strokeLinecap="round" d="M15.75 10.5l4.72-4.72a.75.75 0 011.28.53v11.38a.75.75 0 01-1.28.53l-4.72-4.72M4.5 18.75h9a2.25 2.25 0 002.25-2.25v-9a2.25 2.25 0 00-2.25-2.25h-9A2.25 2.25 0 002.25 7.5v9a2.25 2.25 0 002.25 2.25z" />
          </svg>
        </button> */}

        {/* Message Input */}
        <div className="flex items-center gap-2 pointer-events-auto max-w-screen-sm w-full mx-auto">
        <button
    disabled={loading || message}
    onClick={startListening}
    className={`bg-[#f9be1a] hover:bg-[#e0a816] text-white p-4 rounded-md ${
      loading || message ? "cursor-not-allowed opacity-30" : ""
    }`}
  >
    🎤
  </button>
          <input
            className="w-full placeholder:text-gray-800 placeholder:italic p-4 rounded-md bg-opacity-50 bg-white backdrop-blur-md"
            placeholder="Type a message..."
            ref={input}
            onKeyDown={(e) => {
              if (e.key === "Enter") {
                sendMessage();
              }
            }}
          />
          <button
            disabled={loading || message}
            onClick={sendMessage}
            className={`bg-[#f9be1a] hover:bg-[#e0a816] text-white p-4 px-10 font-semibold uppercase rounded-md ${
              loading || message ? "cursor-not-allowed opacity-30" : ""
            }`}
          >
            Send
          </button>
        </div>
      </div>
    </div>
  );
};

// Inline styles for positioning the menu and game buttons
const menuStyles = {
  position: "absolute",
  top: "20px",
  right: "160px",
  zIndex: 10,
};

const buttonStyles = {
  display: "flex",
  alignItems: "center",
  backgroundColor: "a6790e",
  padding: "10px",
  borderRadius: "10px",
  border: "none",
  cursor: "pointer",
};

const gamesMenuStyles = {
  display: "flex",
  flexDirection: "column",
  marginTop: "10px",
  backgroundColor: "white",
  borderRadius: "10px",
  padding: "10px",
  boxShadow: "0px 4px 10px rgba(0, 0, 0, 0.2)",
};

const gameButtonStyles = {
  display: "flex",
  alignItems: "center",
  backgroundColor: "transparent",
  border: "none",
  padding: "10px",
  cursor: "pointer",
  borderRadius: "8px",
  marginBottom: "10px",
  fontSize: "14px",
};
