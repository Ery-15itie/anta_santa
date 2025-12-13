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
          // ログイン前なのでAuthorizationヘッダーは不要
        },
        body: JSON.stringify({ code: code }),
      });

      const data = await response.json();

      if (response.ok) {
        // 成功！
        setMessage("認証に成功しました！ログイン処理を行います...");
        
        // ここでJWTトークンを保存して、ダッシュボードへリダイレクト
        localStorage.setItem('token', data.token);
        
        // 少し待ってからリダイレクト（ユーザーに成功メッセージを見せるため）
        setTimeout(() => {
          // Reactのダッシュボード(ルート)へ移動
          window.location.href = '/'; 
        }, 1500);

      } else {
        setError(data.error || 'コードが無効です');
      }
    } catch (err) {
      setError('通信エラーが発生しました');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="mt-4 p-4 border rounded bg-gray-50">
      <h4 className="text-sm font-bold text-gray-700 mb-2">🚑 救済コードをお持ちの方</h4>
      <p className="text-xs text-gray-500 mb-3">
        運営から発行された8桁のコードを入力してください。
      </p>

      <form onSubmit={handleSubmit}>
        <div className="flex gap-2">
          <input
            type="text"
            value={code}
            onChange={(e) => setCode(e.target.value.toUpperCase())} // 自動で大文字に
            placeholder="A1B2C3D4"
            className="flex-1 p-2 border rounded text-sm font-mono uppercase"
            maxLength={8}
            required
          />
          <button
            type="submit"
            disabled={loading || code.length < 8}
            className="bg-blue-600 text-white px-4 py-2 rounded text-sm hover:bg-blue-700 disabled:opacity-50"
          >
            {loading ? '送信...' : '認証'}
          </button>
        </div>
      </form>

      {/* メッセージ表示エリア */}
      {message && (
        <div className="mt-2 text-sm text-green-600 font-bold">
          ✅ {message}
        </div>
      )}
      {error && (
        <div className="mt-2 text-sm text-red-600">
          ⚠️ {error}
        </div>
      )}
    </div>
  );
};

export default RescueCodeForm;