import React, { useState } from 'react';

const RescueCodeForm = () => {
  const [code, setCode] = useState('');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState(null);
  const [error, setError] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setMessage(null);

    try {
      const response = await fetch('/api/v1/rescue_session', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ code: code }),
      });

      const data = await response.json();

      if (response.ok) {
        // --- 成功時の処理 ---
        setMessage(data.message || "認証に成功しました！移動します...");
        
        // もしAPIがトークンを返しているなら保存（セッションCookieがあれば必須ではありませんが一応）
        if (data.token) {
          localStorage.setItem('token', data.token);
        }
        
        // ユーザーにメッセージを見せるため少し待ってから移動
        setTimeout(() => {
          // ★サーバーから指定されたURL（プロフィール編集画面）へ移動
          // fallbackとして '/users/edit' を指定
          window.location.href = data.redirect_url || '/users/edit'; 
        }, 1500);

      } else {
        // --- エラー時の処理 ---
        setError(data.error || 'コードが無効です');
      }
    } catch (err) {
      setError('通信エラーが発生しました。もう一度お試しください。');
    } finally {
      setLoading(false);
    }
  };

  return (
    // デザインをログイン画面（Anta-Santa Village）に合わせて調整
    <div className="mt-4 p-5 border-2 border-[#ffcc80] rounded-xl bg-[#fff8e1]">
      <div className="flex items-center gap-2 mb-2">
        <span className="text-xl">🚑</span>
        <h4 className="text-sm font-bold text-[#e65100]">救済コードをお持ちの方</h4>
      </div>
      
      <p className="text-xs text-[#8d6e63] mb-4 font-medium leading-relaxed">
        ログインできない場合、運営から発行された<br/>8桁の救済コードを入力してください。
      </p>

      <form onSubmit={handleSubmit}>
        <div className="flex gap-2">
          <input
            type="text"
            value={code}
            onChange={(e) => setCode(e.target.value.toUpperCase())} // 入力時に自動で大文字へ
            placeholder="A1B2C3D4"
            className="flex-1 p-3 border border-[#ffcc80] rounded-lg text-sm font-mono uppercase text-[#3e2723] focus:outline-none focus:ring-2 focus:ring-[#ef6c00] placeholder-orange-200"
            maxLength={8}
            required
            disabled={loading} // 送信中は入力不可
          />
          <button
            type="submit"
            disabled={loading || code.length < 8}
            className="bg-[#ef6c00] text-white px-5 py-2 rounded-lg text-sm font-bold hover:bg-[#d84315] disabled:opacity-50 disabled:cursor-not-allowed transition-colors shadow-sm"
          >
            {loading ? '送信中...' : '認証'}
          </button>
        </div>
      </form>

      {/* メッセージ表示エリア */}
      {message && (
        <div className="mt-3 p-2 bg-green-50 text-green-700 text-sm font-bold rounded text-center border border-green-200 animate-pulse">
          ✅ {message}
        </div>
      )}
      {error && (
        <div className="mt-3 p-2 bg-red-50 text-red-600 text-sm font-bold rounded text-center border border-red-200">
          ⚠️ {error}
        </div>
      )}
    </div>
  );
};

export default RescueCodeForm;