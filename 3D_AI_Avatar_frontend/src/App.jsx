import React, { useEffect, useState } from "react";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { Canvas } from "@react-three/fiber";
import { Loader } from "@react-three/drei";
import { Leva } from "leva";

import { Experience as Experience1 } from "./components/Experience";
import { Experience as Experience2 } from "./components/Experience2";
import { Experience as Experience3 } from "./components/Experience3";
import { UI } from "./components/UI";
import { ChatProvider } from "./hooks/useChat";
import { useSearchParams } from "react-router-dom";

function HomeExperience() {
  const [avatarId, setAvatarId] = useState(0);
  const [experienceVersion, setExperienceVersion] = useState(() => {
    return localStorage.getItem("experienceVersion") || "1";
  });
  const [searchParams] = useSearchParams();
  const [langParam, setLangParam] = useState("");
  
  useEffect(() => {
  const lang = searchParams.get("lang");
  if (lang) {
    setLangParam(lang);

    const version =
      lang === "Arabic" ? "1" :
      lang === "Korean" ? "2" :
      lang === "English" ? "3" : "3"; // default to English

    setExperienceVersion(version);
    localStorage.setItem("experienceVersion", version); // Optional if you want to persist
  }
}, [searchParams]);

  
  // const getCharacterName = (version) => {
  //   switch (version) {
  //     case "1":
  //       return "lolwa";
  //     case "2":
  //       return "kieko";
  //     case "3":
  //       return "rami";
  //     default:
  //       return "rami";
  //   }
  // };
  const getCharacterName = (langParam) => {
    switch (langParam) {
      case "Arabic":
        return "lolwa";
      case "Korean":
        return "kieko";
      case "English":
        return "rami";
      default:
        return "lolwa";
    }
  };
  
  const character = getCharacterName(langParam);
  

  const ExperienceComponent = () => {
    if (experienceVersion === "1") return <Experience1 avatarId={avatarId} />;
    if (experienceVersion === "2") return <Experience2 avatarId={avatarId} />;
    return <Experience3 avatarId={avatarId} />;
  };
  
  const handleToggle = () => {
    const next = experienceVersion === "1" ? "2" : experienceVersion === "2" ? "3" : "1";
    setExperienceVersion(next);
    localStorage.setItem("experienceVersion", next);
  
    const nextLang =
      next === "1" ? "Arabic" :
      next === "2" ? "Korean" :
      "English";
  
    setLangParam(nextLang);
    
    const newSearchParams = new URLSearchParams(searchParams);
    newSearchParams.set("lang", nextLang);
    window.history.replaceState(null, "", `?${newSearchParams.toString()}`);
  };
  
  return (
    <ChatProvider character={character}>
      <Loader />
      <Leva hidden />
      <UI setAvatarId={setAvatarId} />

      <div
        style={{
          position: "absolute",
          top: 20,
          right: 20,
          zIndex: 1000,
          background: "white",
          padding: "12px",
          borderRadius: "10px",
          fontFamily: "monospace",
          boxShadow: "0 4px 10px rgba(0,0,0,0.2)",
        }}
      >
        <button
          onClick={handleToggle}
          style={{
            background:
              experienceVersion === "1"
                ? "#f44336"
                : experienceVersion === "2"
                ? "#4CAF50"
                : "#2196F3",
            color: "white",
            border: "none",
            padding: "8px 14px",
            fontWeight: "bold",
            borderRadius: "6px",
            cursor: "pointer",
          }}
        >
          DeepSona: {experienceVersion}
        </button>
      </div>

 <Canvas
  key={experienceVersion}
  shadows
  camera={{ position: [0, 0, 1], fov: 30 }}
  style={{ backgroundColor: "#00ff00" }} // bright green screen
  gl={{ preserveDrawingBuffer: true }}   // optional: helps with screenshots
>

  {ExperienceComponent()}
</Canvas>

    </ChatProvider>
  );
}

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<HomeExperience />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
