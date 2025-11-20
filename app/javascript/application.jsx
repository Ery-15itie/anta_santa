// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import React from 'react';
import { createRoot } from 'react-dom/client';
import HeartoryHome from './components/HeartoryHome';

// 【確認1】JSファイル自体が読み込まれたか？
console.log("🚀 STEP1: JavaScript file is loaded!");

document.addEventListener('turbo:load', () => {
  // 【確認2】画面の読み込み完了イベントが発火したか？
  console.log("🚀 STEP2: Turbo Load Event Fired");

  const container = document.getElementById('heartory-home-root');
  
  // 【確認3】HTMLの中に「受け皿(div)」は見つかったか？
  console.log("🚀 STEP3: Container found?", container);

  if (container) {
    console.log("🚀 STEP4: Mounting React...");
    const root = createRoot(container);
    root.render(<HeartoryHome />);
  } else {
    console.log("⚠️ STEP3 FAILED: Container is null. Are you on the right page?");
  }
});