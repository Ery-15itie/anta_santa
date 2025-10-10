(function() {
  function createParticles() {
    const container = document.getElementById('particles-container');
    if (!container) {
      // コンテナ要素がない場合は処理を中断（DOMがまだロードされていない、またはTurboのレンダリング途中）
      return; 
    }
    
    // 既存の粒子をクリア (Turboがページを再描画した場合の重複生成を防ぐ)
    container.innerHTML = '';
    
    const particleCount = 25; // 生成する粒子の数
    
    for(let i = 0; i < particleCount; i++) {
      const particle = document.createElement('div');
      particle.className = 'light-particle';
      
      // 粒子を画面内のランダムな位置に配置 (CSSアニメーションが始まる基準点)
      particle.style.left = Math.random() * 100 + '%';
      particle.style.top = Math.random() * 100 + '%'; 
      
      // 粒子のサイズをランダムに決定
      const size = Math.random() * 12 + 6;
      particle.style.width = size + 'px';
      particle.style.height = size + 'px';
      
      // アニメーション開始時間をランダムに遅らせる (規則性を排除)
      particle.style.animationDelay = Math.random() * 10 + 's';
      
      // アニメーションの速度（duration）をランダムに決定し、CSSカスタムプロパティとして設定
      const duration = Math.random() * 10 + 15;
      particle.style.setProperty('--float-duration', duration + 's');
      particle.style.setProperty('--drift-duration', (duration + 5) + 's');
      
      container.appendChild(particle);
    }
  }
  
  // ページロード時とTurboのナビゲーション完了時に粒子を生成
  // DOMContentLoadedを待つことで確実にコンテナ要素を取得
  document.addEventListener('DOMContentLoaded', createParticles);
  document.addEventListener('turbo:load', createParticles);
})();