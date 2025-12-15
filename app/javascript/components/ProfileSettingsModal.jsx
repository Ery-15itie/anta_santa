import React, { useState, useEffect } from 'react';

const ProfileSettingsModal = ({ onClose }) => {
  const [user, setUser] = useState({
    username: '',
    public_id: '',
    email: '',
    is_google_linked: false
  });
  
  // パスワード変更用
  const [passwords, setPasswords] = useState({
    password: '',
    password_confirmation: '',
    current_password: '' // 重要: メール/パスワード変更時は必須
  });

  const [loading, setLoading] = useState(true);
  const [message, setMessage] = useState(null);
  const [error, setError] = useState(null);

  // CSRFトークン取得
  const getCsrfToken = () => document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');

  // --- 1. データ取得 ---
  useEffect(() => {
    const fetchProfile = async () => {
      try {
        const res = await fetch('/api/v1/profile');
        if (res.ok) {
          const data = await res.json();
          setUser(data.user);
        } else {
          setError('情報の取得に失敗しました');
        }
      } catch (err) {
        setError('通信エラーが発生しました');
      } finally {
        setLoading(false);
      }
    };
    fetchProfile();
  }, []);

  // --- 2. プロフィール更新 ---
  const handleUpdate = async (e) => {
    e.preventDefault();
    setMessage(null);
    setError(null);
    setLoading(true);

    const body = {
      user: {
        username: user.username,
        public_id: user.public_id,
        email: user.email,
        ...passwords // パスワード入力があればマージされる
      }
    };

    try {
      const res = await fetch('/api/v1/profile', {
        method: 'PUT', // または PATCH
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': getCsrfToken()
        },
        body: JSON.stringify(body)
      });

      const data = await res.json();

      if (res.ok) {
        setMessage(data.message);
        setUser(prev => ({ ...prev, ...data.user }));
        // パスワード欄をクリア
        setPasswords({ password: '', password_confirmation: '', current_password: '' });
      } else {
        // エラー配列を文字列に結合
        setError(Array.isArray(data.errors) ? data.errors.join(' / ') : '更新に失敗しました');
      }
    } catch (err) {
      setError('通信エラーが発生しました');
    } finally {
      setLoading(false);
    }
  };

  // --- 3. Google連携解除 ---
  const handleUnlinkGoogle = async () => {
    if (!window.confirm('本当にGoogle連携を解除しますか？')) return;
    
    try {
      const res = await fetch('/api/v1/social_provider', {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': getCsrfToken()
        }
      });
      
      if (res.ok) {
        setMessage("Google連携を解除しました");
        setUser(prev => ({ ...prev, is_google_linked: false }));
      } else {
        setError("解除に失敗しました");
      }
    } catch (err) {
      setError("通信エラー");
    }
  };

  if (loading && !user.username) return <div className="p-4 text-center bg-white rounded">読み込み中...</div>;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50 p-4">
      <div className="bg-white w-full max-w-lg rounded-lg shadow-xl overflow-hidden max-h-[90vh] overflow-y-auto">
        
        {/* ヘッダー */}
        <div className="bg-[#5d4037] text-[#ffecb3] p-4 flex justify-between items-center">
          <h3 className="font-bold text-lg">⚙️ プロフィール設定</h3>
          <button onClick={onClose} className="text-2xl hover:text-white">&times;</button>
        </div>

        <div className="p-6 space-y-6">
          {/* メッセージ表示エリア */}
          {message && <div className="bg-green-100 text-green-800 p-3 rounded text-sm mb-4">✅ {message}</div>}
          {error && <div className="bg-red-100 text-red-800 p-3 rounded text-sm mb-4">⚠️ {error}</div>}

          <form onSubmit={handleUpdate} className="space-y-6">
            
            {/* 基本情報 */}
            <section>
              <h4 className="text-[#3e2723] font-bold border-b border-[#d7ccc8] mb-3 pb-1">基本情報</h4>
              <div className="grid gap-4">
                <div>
                  <label className="block text-xs font-bold text-gray-600 mb-1">名前 (Username)</label>
                  <input 
                    type="text" 
                    value={user.username} 
                    onChange={e => setUser({...user, username: e.target.value})}
                    className="w-full p-2 border rounded" required 
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-gray-600 mb-1">公開ID (Public ID)</label>
                  <input 
                    type="text" 
                    value={user.public_id} 
                    onChange={e => setUser({...user, public_id: e.target.value})}
                    className="w-full p-2 border rounded bg-gray-50" 
                    pattern="^[a-zA-Z0-9_]+$"
                    title="半角英数字とアンダースコアのみ"
                    required 
                  />
                  <p className="text-[10px] text-gray-500 mt-1">※フレンドからの検索に使われます (半角英数のみ)</p>
                </div>
              </div>
            </section>

            {/* アカウント設定 */}
            <section>
              <h4 className="text-[#3e2723] font-bold border-b border-[#d7ccc8] mb-3 pb-1">アカウント設定</h4>
              <div className="grid gap-4">
                <div>
                  <label className="block text-xs font-bold text-gray-600 mb-1">メールアドレス</label>
                  <input 
                    type="email" 
                    value={user.email} 
                    onChange={e => setUser({...user, email: e.target.value})}
                    className="w-full p-2 border rounded" required 
                  />
                </div>
                
                <div className="bg-orange-50 p-3 rounded border border-orange-100">
                  <p className="text-xs text-orange-800 font-bold mb-2">パスワードを変更する場合のみ入力</p>
                  <input 
                    type="password" 
                    placeholder="新しいパスワード (6文字以上)"
                    value={passwords.password} 
                    onChange={e => setPasswords({...passwords, password: e.target.value})}
                    className="w-full p-2 border rounded mb-2 text-sm"
                  />
                  <input 
                    type="password" 
                    placeholder="新しいパスワード (確認)"
                    value={passwords.password_confirmation} 
                    onChange={e => setPasswords({...passwords, password_confirmation: e.target.value})}
                    className="w-full p-2 border rounded text-sm"
                  />
                </div>

                {/* 重要項目変更時の確認用 */}
                {(user.email !== '' || passwords.password !== '') && (
                  <div>
                    <label className="block text-xs font-bold text-red-600 mb-1">現在のパスワード (必須)</label>
                    <input 
                      type="password" 
                      placeholder="変更を保存するには現在のパスワードが必要です"
                      value={passwords.current_password} 
                      onChange={e => setPasswords({...passwords, current_password: e.target.value})}
                      className="w-full p-2 border-2 border-red-100 rounded bg-red-50 focus:bg-white transition"
                    />
                    <p className="text-[10px] text-gray-500 mt-1">※名前/IDのみの変更なら空欄でOKです</p>
                  </div>
                )}
              </div>
            </section>

            <div className="text-center pt-2">
              <button 
                type="submit" 
                disabled={loading}
                className="bg-[#3e2723] text-white px-8 py-2 rounded-full hover:bg-[#5d4037] font-bold shadow disabled:opacity-50"
              >
                {loading ? '保存中...' : '変更を保存する'}
              </button>
            </div>

          </form>

          {/* ソーシャル連携 */}
          <section className="mt-8 pt-6 border-t border-dashed border-gray-300">
            <h4 className="text-[#3e2723] font-bold mb-3 text-sm">ソーシャル連携</h4>
            <div className="flex items-center justify-between bg-gray-50 p-3 rounded border">
              <div className="flex items-center gap-2">
                <span className="text-xl">G</span>
                <span className="text-sm font-bold text-gray-700">Googleアカウント</span>
              </div>
              
              {user.is_google_linked ? (
                <div className="flex items-center gap-3">
                  <span className="text-xs text-green-600 font-bold">連携済み</span>
                  <button 
                    onClick={handleUnlinkGoogle}
                    className="text-xs text-red-500 hover:underline border border-red-200 px-2 py-1 rounded bg-white"
                  >
                    解除
                  </button>
                </div>
              ) : (
                <a 
                  href="/users/auth/google_oauth2" 
                  data-turbo="false" // 重要: RailsのTurboを無効化して通常遷移
                  className="text-xs bg-white border border-gray-300 px-3 py-1 rounded shadow-sm hover:bg-gray-100 font-bold text-gray-700"
                >
                  連携する
                </a>
              )}
            </div>
          </section>
        </div>
      </div>
    </div>
  );
};

export default ProfileSettingsModal;