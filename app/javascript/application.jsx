// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import React from 'react';
import { createRoot } from 'react-dom/client';

// ▼▼▼ コンポーネントをインポート ▼▼▼
import HeartoryHome from './components/HeartoryHome';
import SantaBookModal from './components/SantaBookModal';
import RescuePanel from './components/admin/RescuePanel';
import RescueCodeForm from './components/RescueCodeForm';
import ProfileSettingsModal from './components/ProfileSettingsModal'; // ★追加: プロフィール設定

console.log("🚀 JS Loaded");

document.addEventListener('turbo:load', () => {
  console.log("🚀 Turbo Load Event Fired");

  // =========================================================
  // メインダッシュボード (HeartoryHome) の表示
  // =========================================================
  const homeContainer = document.getElementById('heartory-home-root');
  
  if (homeContainer) {
    console.log("🏠 Found heartory-home-root, mounting React...");
    if (!homeContainer.hasChildNodes()) {
      const root = createRoot(homeContainer);
      root.render(<HeartoryHome />);
    }
  }

  // =========================================================
  // サンタのガイドブック (SantaBookModal) の表示
  // =========================================================
  const bookContainer = document.getElementById('santa-book-portal');
  
  if (bookContainer) {
    console.log("📖 Found santa-book-portal, mounting SantaBookModal...");
    if (!bookContainer.hasChildNodes()) {
      const root = createRoot(bookContainer);
      root.render(<SantaBookModal />);
    }
  }

  // =========================================================
  // 管理者用救済パネル (RescuePanel) の表示
  // =========================================================
  const rescueContainer = document.getElementById('admin-rescue-root');

  if (rescueContainer) {
    console.log("🚑 Found admin-rescue-root, mounting RescuePanel...");
    if (!rescueContainer.hasChildNodes()) {
      const root = createRoot(rescueContainer);
      root.render(<RescuePanel />);
    }
  }

  // =========================================================
  // ユーザー用救済コード入力フォーム (RescueCodeForm) の表示 
  // =========================================================
  const rescueFormContainer = document.getElementById('rescue-code-form-root');
  
  if (rescueFormContainer) {
    console.log("🆘 Found rescue-code-form-root, mounting RescueCodeForm...");
    if (!rescueFormContainer.hasChildNodes()) {
      const root = createRoot(rescueFormContainer);
      root.render(<RescueCodeForm />);
    }
  }

  // =========================================================
  // プロフィール設定モーダル (ProfileSettingsModal) 
  // =========================================================
  const settingsContainer = document.getElementById('profile-settings-root');
  const openButton = document.getElementById('open-profile-settings');

  if (settingsContainer && openButton) {
    console.log("⚙️ Profile settings setup");
    
    // モーダルを開く関数
    const mountModal = () => {
      // 既に開いていなければマウント（多重起動防止）
      if (!settingsContainer.hasChildNodes()) {
        const root = createRoot(settingsContainer);
        // onCloseプロパティで「閉じる（アンマウント）処理」を渡す
        root.render(<ProfileSettingsModal onClose={() => root.unmount()} />);
      }
    };

    // ボタンクリックイベント
    // Turboによる画面遷移でイベントが重複しないよう、removeしてからaddする
    const clickHandler = (e) => {
      e.preventDefault();
      mountModal();
    };
    
    openButton.removeEventListener('click', clickHandler);
    openButton.addEventListener('click', clickHandler);
  }
});