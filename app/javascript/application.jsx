// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import React from 'react';
import { createRoot } from 'react-dom/client';

// ▼▼▼ コンポーネントをインポート ▼▼▼
import HeartoryHome from './components/HeartoryHome';
import SantaBookModal from './components/SantaBookModal'; // ← 追加！

console.log("🚀 JS Loaded");

document.addEventListener('turbo:load', () => {
  console.log("🚀 Turbo Load Event Fired");

  // =========================================================
  // 【処理1】メインダッシュボード (HeartoryHome) の表示
  // =========================================================
  const homeContainer = document.getElementById('heartory-home-root');
  
  if (homeContainer) {
    // コンソールで確認（デバッグ用）
    console.log("🏠 Found heartory-home-root, mounting React...");
    
    // 二重表示防止：中身が空の時だけレンダリング
    if (!homeContainer.hasChildNodes()) {
      const root = createRoot(homeContainer);
      root.render(<HeartoryHome />);
    }
  }

  // =========================================================
  // 【処理2】サンタのガイドブック (SantaBookModal) の表示
  // =========================================================
  // layout/application.html.erb に設置した <div id="santa-book-portal"> を探す
  const bookContainer = document.getElementById('santa-book-portal');
  
  if (bookContainer) {
    console.log("📖 Found santa-book-portal, mounting SantaBookModal...");
    
    // 二重表示防止
    if (!bookContainer.hasChildNodes()) {
      const root = createRoot(bookContainer);
      root.render(<SantaBookModal />);
    }
  } else {
    // ギフトホールなどの画面でも出るはずなので、もし出なければここがログに出ます
    console.log("⚠️ santa-book-portal container not found.");
  }
});