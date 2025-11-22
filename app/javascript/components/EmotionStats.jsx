import React, { useEffect, useState } from 'react';
import { ArrowLeft, Trophy, Sparkles, Scroll, Flame } from 'lucide-react';

// 感情データ定義 (アイコン表示用)
const EMOTIONS = {
  joy: '😊', calm: '😌', love: '🥰', excited: '✨',
  normal: '😐', thinking: '🤔', surprise: '😮',
  sadness: '😔', anxiety: '😰', anger: '😤', empty: '😞'
};

const EmotionStats = ({ onBack }) => {
  const [data, setData] = useState(null);

  // APIからデータを取得
  useEffect(() => {
    fetch('/api/v1/emotion_logs/stats')
      .then(res => res.json())
      .then(data => setData(data))
      .catch(err => console.error(err));
  }, []);

  if (!data) return <div className="min-h-screen bg-[#2c1e1b] flex items-center justify-center text-[#8d6e63]">Loading...</div>;

  const { stats, history } = data;

  return (
    <div className="min-h-screen bg-[#2c1e1b] font-serif text-[#d7ccc8] p-4 pb-20 overflow-y-auto">
      {/* 背景テクスチャ */}
      <div className="fixed inset-0 opacity-20 pointer-events-none" style={{ backgroundImage: 'url("https://www.transparenttextures.com/patterns/wood-pattern.png")' }}></div>

      {/* ヘッダー */}
      <div className="relative z-10 flex items-center gap-4 mb-8 border-b border-[#5d4037] pb-4">
        <button onClick={onBack} className="p-2 bg-[#3e2723] rounded-full border border-[#5d4037] hover:bg-[#4e342e] transition">
          <ArrowLeft size={20} />
        </button>
        <h1 className="text-2xl font-black text-[#ffecb3] tracking-widest uppercase">Fire Keeper's Log</h1>
      </div>

      <div className="max-w-2xl mx-auto space-y-8 relative z-10">
        
        {/* 1. レベル・ステータスカード */}
        <div className="bg-[#3e2723] p-6 rounded-lg border-4 border-[#5d4037] shadow-xl flex flex-col sm:flex-row items-center justify-between relative overflow-hidden gap-4">
          <div className="absolute -right-4 -bottom-4 text-9xl opacity-10 pointer-events-none">🔥</div>
          
          <div className="flex items-center gap-4">
            <div className="w-20 h-20 rounded-full border-4 border-[#d84315] flex items-center justify-center bg-[#2c1e1b] shadow-[0_0_15px_rgba(216,67,21,0.5)]">
               <span className="text-3xl font-black text-[#ffcc80]">{stats.level}</span>
            </div>
            <div>
              <p className="text-xs text-[#8d6e63] font-bold uppercase">Keeper Level</p>
              <h2 className="text-2xl font-bold text-[#ffecb3]">心の火守り人</h2>
            </div>
          </div>

          <div className="w-full sm:w-auto space-y-2">
             <div className="bg-[#2c1e1b] px-4 py-2 rounded border border-[#4e342e] flex justify-between sm:justify-start gap-4 text-sm">
               <span className="text-[#8d6e63]">Total Logs</span>
               <span className="text-[#ffcc80] font-bold">🪵 {stats.total_logs}</span>
             </div>
             <div className="bg-[#2c1e1b] px-4 py-2 rounded border border-[#4e342e] flex justify-between sm:justify-start gap-4 text-sm">
               <span className="text-[#8d6e63]">Magic Used</span>
               <span className="text-[#ce93d8] font-bold">🔮 {stats.magic_powder_count}</span>
             </div>
          </div>
        </div>

        {/* 2. 実績バッジ (条件達成で色がつく) */}
        <div>
          <h3 className="text-lg font-bold text-[#8d6e63] mb-4 flex items-center gap-2"><Trophy size={18}/> Achievements</h3>
          <div className="grid grid-cols-3 gap-4">
            {/* 初点火 */}
            <div className={`p-4 rounded border text-center transition-all ${stats.total_logs > 0 ? 'bg-[#ffecb3]/10 border-[#ffecb3]/30 shadow-lg' : 'bg-[#2c1e1b] border-[#3e2723] opacity-40 grayscale'}`}>
               <div className="text-3xl mb-2">🕯</div>
               <div className="text-[10px] font-bold tracking-wider">初点火</div>
            </div>
            {/* 魔法使い */}
            <div className={`p-4 rounded border text-center transition-all ${stats.magic_powder_count > 0 ? 'bg-[#ce93d8]/10 border-[#ce93d8]/30 shadow-lg' : 'bg-[#2c1e1b] border-[#3e2723] opacity-40 grayscale'}`}>
               <div className="text-3xl mb-2">🔮</div>
               <div className="text-[10px] font-bold tracking-wider">魔法使い</div>
            </div>
            {/* 熟練者 (Lv50以上) */}
            <div className={`p-4 rounded border text-center transition-all ${stats.level >= 50 ? 'bg-[#ffcc80]/10 border-[#ffcc80]/30 shadow-lg' : 'bg-[#2c1e1b] border-[#3e2723] opacity-40 grayscale'}`}>
               <div className="text-3xl mb-2">🔥</div>
               <div className="text-[10px] font-bold tracking-wider">熟練者</div>
            </div>
          </div>
        </div>

        {/* 3. 履歴リスト (羊皮紙風) */}
        <div>
          <h3 className="text-lg font-bold text-[#8d6e63] mb-4 flex items-center gap-2"><Scroll size={18}/> History Logs</h3>
          <div className="bg-[#fdf6e3] rounded-sm shadow-lg border-t-8 border-[#5d4037] text-[#3e2723] overflow-hidden relative">
            {/* 紙の質感 */}
            <div className="absolute inset-0 opacity-20 pointer-events-none" style={{backgroundImage: 'url("https://www.transparenttextures.com/patterns/cream-paper.png")'}}></div>
            
            <div className="divide-y divide-[#d7ccc8] relative z-10">
              {history.map((log) => {
                const date = new Date(log.created_at);
                const dateStr = `${date.getMonth()+1}/${date.getDate()}`;
                return (
                  <div key={log.id} className="p-4 flex items-start gap-4 hover:bg-[#fff8e1] transition">
                    <div className="text-2xl pt-1">{EMOTIONS[log.emotion] || '🔥'}</div>
                    <div className="flex-grow">
                       <div className="flex justify-between items-baseline mb-1">
                          <span className="text-sm font-bold capitalize">{log.emotion}</span>
                          <span className="text-xs text-[#8d6e63] font-mono">{dateStr}</span>
                       </div>
                       <p className="text-sm text-[#4e342e]">{log.body || <span className="opacity-40 italic">No memo</span>}</p>
                       
                       {/* 魔法の粉使用マーク */}
                       {log.magic_powder && log.magic_powder !== 'no_powder' && (
                         <div className="mt-1 inline-flex items-center gap-1 text-[10px] text-purple-700 bg-purple-100 px-2 py-0.5 rounded-full">
                           <Sparkles size={10} /> {log.magic_powder}
                         </div>
                       )}
                    </div>
                  </div>
                );
              })}
              {history.length === 0 && (
                  <div className="p-8 text-center text-[#8d6e63] italic">No logs yet.</div>
              )}
            </div>
          </div>
        </div>

      </div>
    </div>
  );
};

export default EmotionStats;