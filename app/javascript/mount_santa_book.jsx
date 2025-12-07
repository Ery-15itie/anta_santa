import React from 'react';
import { createRoot } from 'react-dom/client';
import SantaBookModal from './components/SantaBookModal';

// ページが読み込まれるたびに実行される処理
document.addEventListener('turbo:load', () => {
  // 1. レイアウトファイルに置いた <div id="santa-book-portal"> を探す
  const mountPoint = document.getElementById('santa-book-portal');

  // 2. 見つかったら、そこに Reactコンポーネントを描画する
  if (mountPoint) {
    // 既に描画済みでなければ描画（重複防止）
    if (!mountPoint.hasChildNodes()) {
      const root = createRoot(mountPoint);
      root.render(<SantaBookModal />);
    }
  }
});