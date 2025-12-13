import React, { useState } from 'react';

const RescuePanel = () => {
  const [username, setUsername] = useState('');
  const [result, setResult] = useState(null);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);

  // 重要: CSRFトークンをヘッダーに含める（Deviseのセッション維持のため）
  const getCsrfToken = () => document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');

  const handleGenerate = async (e) => {
    e.preventDefault();
    setLoading(true);
    setResult(null);
    setError(null);

    try {
      // ログイン中のCookieを使ってリクエストする
      const response = await fetch('/api/v1/admin/rescue_codes', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': getCsrfToken() 
        },
        body: JSON.stringify({ username: username }),
      });

      const data = await response.json();

      if (response.ok) {
        setResult(data);
      } else {
        setError(data.error || '発行に失敗しました（権限がない可能性があります）');
      }
    } catch (err) {
      setError('通信エラーが発生しました');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="card shadow border-danger" style={{ maxWidth: '500px', margin: '20px auto', padding: '20px' }}>
      <h3 style={{ color: '#dc3545', borderBottom: '2px solid #dc3545', paddingBottom: '10px' }}>
        🚑 救済コード発行 (管理者専用)
      </h3>
      
      <p style={{ fontSize: '0.9rem', color: '#666' }}>
        ログインできないユーザーのために、一時的な救済コードを発行します。<br/>
        ※管理者権限が必要です。
      </p>

      <form onSubmit={handleGenerate}>
        <div style={{ marginBottom: '15px' }}>
          <label style={{ display: 'block', marginBottom: '5px', fontWeight: 'bold' }}>
            対象ユーザー名
          </label>
          <input
            type="text"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            placeholder="例: santa_san"
            style={{ width: '100%', padding: '8px', fontSize: '16px' }}
            required
          />
        </div>

        <button 
          type="submit" 
          disabled={loading}
          style={{
            width: '100%', 
            padding: '10px', 
            backgroundColor: loading ? '#ccc' : '#dc3545', 
            color: 'white', 
            border: 'none', 
            borderRadius: '4px',
            cursor: loading ? 'not-allowed' : 'pointer'
          }}
        >
          {loading ? '発行中...' : 'コードを発行する'}
        </button>
      </form>

      {result && (
        <div style={{ marginTop: '20px', padding: '15px', backgroundColor: '#d4edda', color: '#155724', borderRadius: '4px', textAlign: 'center' }}>
          <strong>発行成功！</strong>
          <p>以下のコードをユーザーに伝えてください</p>
          <div style={{ fontSize: '24px', letterSpacing: '2px', fontWeight: 'bold', margin: '10px 0', background: 'white', padding: '5px' }}>
            {result.rescue_code}
          </div>
          <small>ユーザー: {result.username}</small>
        </div>
      )}

      {error && (
        <div style={{ marginTop: '20px', padding: '15px', backgroundColor: '#f8d7da', color: '#721c24', borderRadius: '4px' }}>
          {error}
        </div>
      )}
    </div>
  );
};

export default RescuePanel;