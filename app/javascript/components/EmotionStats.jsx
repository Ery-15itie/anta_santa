import React, { useEffect, useState } from 'react';
import { ArrowLeft, Trophy, Sparkles, Scroll, X } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

// 感情データ定義
const EMOTIONS_MAP = {
  joy: { label: '😊 嬉しい', color: '#fbbf24' },
  calm: { label: '😌 穏やか', color: '#4ade80' },
  love: { label: '🥰 愛おしい', color: '#f472b6' },
  excited: { label: '✨ ワクワク', color: '#fb923c' },
  normal: { label: '😐 普通', color: '#e5e7eb' },
  thinking: { label: '🤔 考え中', color: '#67e8f9' },
  surprise: { label: '😮 驚き', color: '#c084fc' },
  sadness: { label: '😔 悲しい', color: '#60a5fa' },
  anxiety: { label: '😰 不安', color: '#818cf8' },
  anger: { label: '😤 怒り', color: '#ef4444' },
  empty: { label: '😞 虚しい', color: '#9ca3af' }
};

const EmotionStats = ({ onBack, onLogout }) => {
  const [data, setData] = useState(null);
  const [selectedBadge, setSelectedBadge] = useState(null); // 選択されたバッジ

  useEffect(() => {
    fetch('/api/v1/emotion_logs/stats')
      .then(res => res.json())
      .then(data => setData(data))
      .catch(err => console.error(err));
  }, []);

  if (!data) return <div className="min-h-screen bg-[#1a100e] flex items-center justify-center text-[#8d6e63]">Loading...</div>;

  const { stats, badges, history } = data;

  return (
    <div className="min-h-screen bg-[#1a100e] font-serif text-[#d7ccc8] p-2 sm:p-4 pb-20 overflow-y-auto relative">
      
      {/* スクロールバーのスタイル定義 */}
      <style>{`
        .wood-scroll::-webkit-scrollbar {
          width: 8px;
        }
        .wood-scroll::-webkit-scrollbar-track {
          background: #efebe9; 
          border-radius: 4px;
        }
        .wood-scroll::-webkit-scrollbar-thumb {
          background: #8d6e63; 
          border-radius: 4px;
        }
        .wood-scroll {
          scrollbar-width: thin;
          scrollbar-color: #8d6e63 #efebe9;
        }
      `}</style>

      <div className="fixed inset-0 opacity-40 pointer-events-none" style={{ backgroundImage: 'url("https://www.transparenttextures.com/patterns/wood-pattern.png")' }}></div>
      <div className="fixed inset-0 bg-black opacity-20 pointer-events-none"></div>

      {/* ヘッダー (スマホ: 縦並び / PC: 横並び) */}
      <div className="relative z-10 flex flex-col md:flex-row items-center justify-between mb-6 sm:mb-8 gap-4 md:gap-0">
        
        {/* スマホ用トップバー（戻る・EXIT） */}
        <div className="w-full flex justify-between md:hidden px-2">
            <button onClick={onBack} className="flex items-center gap-2 bg-[#4e342e] px-4 py-2 rounded-sm border border-[#5d4037] shadow-lg hover:bg-[#5d4037] transition text-xs font-bold text-[#ffecb3]">
              <ArrowLeft size={16} /> BACK
            </button>
            <button onClick={onLogout} className="flex items-center gap-2 bg-[#3e2723] px-4 py-2 rounded-sm border border-[#5d4037] shadow hover:bg-[#b71c1c] transition text-[#ffcdd2] text-xs font-bold">
              EXIT
            </button>
        </div>

        {/* PC用 BACKボタン */}
        <button onClick={onBack} className="hidden md:flex items-center gap-2 bg-[#4e342e] px-4 py-2 rounded-sm border border-[#5d4037] shadow-lg hover:bg-[#5d4037] transition group">
          <ArrowLeft size={18} className="group-hover:-translate-x-1 transition-transform" /> 
          <span className="font-bold text-xs tracking-widest">BACK</span>
        </button>
        
        {/* タイトル */}
        <h1 className="text-2xl sm:text-3xl font-black text-[#ffecb3] tracking-[0.2em] uppercase drop-shadow-md text-center" style={{ fontFamily: 'Georgia, serif' }}>
          灯火のあしあと
        </h1>
        
        {/* PC用 EXITボタン */}
        <button onClick={onLogout} className="hidden md:flex items-center gap-2 bg-[#3e2723] px-3 py-2 rounded-sm border border-[#5d4037] shadow hover:bg-[#b71c1c] transition text-[#ffcdd2] text-xs font-bold">EXIT</button>
      </div>

      <div className="max-w-4xl mx-auto relative z-10">
        
        {/* 1. ステータスパネル */}
        <div className="bg-[#3e2723] p-4 sm:p-8 rounded-t-lg border-4 border-[#5d4037] shadow-2xl relative overflow-hidden mb-1">
          <div className="absolute -right-10 -bottom-10 text-9xl opacity-10 text-[#ffcc80]">🔥</div>
          
          {/* フレックス調整: スマホは縦積み、PCは横並び */}
          <div className="flex flex-col md:flex-row items-center justify-between gap-4 md:gap-6 relative z-10">
            <div className="flex items-center gap-4 sm:gap-6 w-full md:w-auto justify-center md:justify-start">
              {/* レベルエンブレム */}
              <div className="relative w-20 h-20 sm:w-24 sm:h-24 flex items-center justify-center flex-shrink-0">
                <div className="absolute inset-0 bg-[#bf360c] rounded-full blur-md opacity-60 animate-pulse"></div>
                <div className="relative w-full h-full rounded-full border-4 border-[#ffcc80] bg-[#271c19] flex flex-col items-center justify-center shadow-[inset_0_0_20px_rgba(0,0,0,0.8)]">
                   <span className="text-[8px] sm:text-[10px] text-[#8d6e63] font-bold uppercase tracking-wider -mb-1">LEVEL</span>
                   <span className="text-3xl sm:text-4xl font-black text-[#ffcc80] drop-shadow-md">{stats.level}</span>
                </div>
              </div>
              {/* 称号 */}
              <div className="text-left">
                <p className="text-[10px] sm:text-xs text-[#ffcc80] font-bold uppercase tracking-widest mb-1">KEEPER TITLE</p>
                <h2 className="text-xl sm:text-3xl font-black text-[#fff8e1] font-serif leading-tight">{stats.title}</h2>
              </div>
            </div>

            {/* スタッツボックス */}
            <div className="flex flex-row md:flex-col gap-2 sm:gap-4 w-full md:w-auto justify-between">
               <div className="bg-[#271c19]/60 px-3 py-2 sm:px-4 sm:py-2 rounded border border-[#5d4037] flex flex-col sm:flex-row justify-center sm:justify-start gap-1 sm:gap-4 text-sm items-center flex-1">
                 <span className="text-[#8d6e63] text-[10px] sm:text-xs font-bold uppercase whitespace-nowrap">Total Logs</span>
                 <span className="text-[#ffcc80] font-bold font-mono text-base sm:text-lg">🪵 {stats.total_logs}</span>
               </div>
               <div className="bg-[#271c19]/60 px-3 py-2 sm:px-4 sm:py-2 rounded border border-[#5d4037] flex flex-col sm:flex-row justify-center sm:justify-start gap-1 sm:gap-4 text-sm items-center flex-1">
                 <span className="text-[#8d6e63] text-[10px] sm:text-xs font-bold uppercase whitespace-nowrap">Magic Used</span>
                 <span className="text-[#ce93d8] font-bold font-mono text-base sm:text-lg">🔮 {stats.magic_powder_count}</span>
               </div>
            </div>
          </div>
        </div>

        {/* 2. 実績・履歴エリア */}
        <div className="bg-[#fdf6e3] p-4 sm:p-10 rounded-b-lg shadow-[0_20px_50px_rgba(0,0,0,0.5)] border-x-4 sm:border-x-8 border-b-4 sm:border-b-8 border-[#fdf6e3] relative text-[#3e2723]">
          <div className="absolute inset-0 opacity-20 pointer-events-none" style={{backgroundImage: 'url("https://www.transparenttextures.com/patterns/cream-paper.png")'}}></div>
          
          {/* 実績カードコレクション */}
          <div className="mb-8 sm:mb-12 relative z-10">
            <h3 className="text-base sm:text-lg font-bold text-[#5d4037] mb-4 sm:mb-6 flex items-center gap-2 border-b-2 border-dashed border-[#8d6e63] pb-2">
              <Trophy size={18} className="sm:w-5 sm:h-5" /> 実績カード
              <span className="text-[10px] sm:text-xs font-normal ml-auto text-[#8d6e63]">Click for details</span>
            </h3>
            
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 sm:gap-4">
              {badges.map((badge) => (
                <motion.button 
                     key={badge.id}
                     whileHover={{ scale: 1.05 }}
                     whileTap={{ scale: 0.95 }}
                     onClick={() => setSelectedBadge(badge)}
                     className={`relative p-2 sm:p-3 rounded border transition-all duration-300 flex flex-col items-center text-center h-full cursor-pointer min-h-[100px] justify-center
                     ${badge.earned 
                       ? 'bg-[#fff8e1] border-[#ffb300] shadow-md opacity-100' 
                       : 'bg-[#efebe9] border-[#d7ccc8] opacity-50 grayscale'}`}>
                   
                   {badge.earned && <div className="absolute -top-2 -right-2 bg-[#d32f2f] text-white text-[8px] px-1.5 py-0.5 rounded-full shadow-sm font-bold">GET</div>}
                   
                   <div className="text-2xl sm:text-3xl mb-1 sm:mb-2">{badge.name.split(' ')[0]}</div>
                   <div className="text-[10px] sm:text-xs font-black text-[#3e2723] leading-tight flex items-center justify-center h-8">
                     {badge.name.split(' ').slice(1).join(' ')}
                   </div>
                </motion.button>
              ))}
            </div>
          </div>

        {/* 記録の書 (履歴リスト) */}
          <div className="relative z-10">
            <h3 className="text-base sm:text-lg font-bold text-[#5d4037] mb-4 sm:mb-6 flex items-center gap-2 border-b-2 border-dashed border-[#8d6e63] pb-2">
              <Scroll size={18} className="sm:w-5 sm:h-5" /> 記録の書
            </h3>

            {/* スクロールバー装飾の適用 & 高さ制限の調整 */}
            <div className="space-y-0 max-h-[50vh] sm:max-h-[600px] overflow-y-auto wood-scroll border-t border-b border-[#d7ccc8]">
              {history.map((log) => {
                const date = new Date(log.created_at);
                const dateStr = `${date.getMonth()+1}/${date.getDate()} ${date.getHours()}:${String(date.getMinutes()).padStart(2, '0')}`;
                const emoData = EMOTIONS_MAP[log.emotion] || { label: '不明', color: '#ccc' };
                
                return (
                  <div key={log.id} className="p-3 sm:p-4 flex items-start gap-3 sm:gap-4 border-b border-[#d7ccc8] last:border-0 hover:bg-[#fff8e1] transition">
                    <div className="text-xl sm:text-2xl pt-1 filter drop-shadow-sm">{emoData.label.split(' ')[0]}</div>
                    <div className="flex-grow min-w-0">
                       <div className="flex justify-between items-baseline mb-1 flex-wrap">
                          <span className="text-xs sm:text-sm font-bold text-[#3e2723]">{emoData.label.split(' ')[1]}</span>
                          <span className="text-[10px] sm:text-xs text-[#8d6e63] font-mono">{dateStr}</span>
                       </div>
                       <p className="text-xs sm:text-sm text-[#4e342e] font-medium mb-1 break-words">
                         {log.body || <span className="opacity-40 italic text-[#a1887f]">No memo</span>}
                       </p>
                       <div className="flex gap-2 sm:gap-3 items-center flex-wrap">
                          <span className="text-[10px] text-[#8d6e63] bg-[#efebe9] px-2 py-0.5 rounded border border-[#d7ccc8]">
                            強さ: {log.intensity}
                          </span>
                          {log.magic_powder && log.magic_powder !== 'no_powder' && (
                            <span className="inline-flex items-center gap-1 text-[10px] font-bold text-purple-800 bg-purple-100 px-2 py-0.5 rounded-full border border-purple-200">
                              <Sparkles size={10} /> {log.magic_powder}
                            </span>
                          )}
                       </div>
                    </div>
                  </div>
                );
              })}
              {history.length === 0 && <div className="p-12 text-center text-[#8d6e63] italic">まだ記録はありません。</div>}
            </div>
          </div>
          
          <div className="h-4 mx-4 bg-[#3e2723] opacity-10 rounded-full filter blur-md mt-8"></div>
        </div>
      </div>

      {/* --- カード詳細モーダル --- */}
      <AnimatePresence>
        {selectedBadge && (
          <div className="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 flex items-center justify-center p-4" onClick={() => setSelectedBadge(null)}>
            <motion.div 
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.9, opacity: 0 }}
              className="bg-[#fdf6e3] border-4 border-[#5d4037] p-6 sm:p-8 rounded shadow-2xl max-w-sm w-full relative text-center"
              onClick={(e) => e.stopPropagation()} 
            >
              <button onClick={() => setSelectedBadge(null)} className="absolute top-2 right-2 text-[#8d6e63] hover:text-[#3e2723]">
                <X size={24} />
              </button>

              <div className="text-5xl sm:text-6xl mb-4 drop-shadow-md">
                {selectedBadge.name.split(' ')[0]}
              </div>
              
              <h3 className="text-xl sm:text-2xl font-black text-[#3e2723] mb-2 font-serif">
                {selectedBadge.name.split(' ').slice(1).join(' ')}
              </h3>
              
              <div className={`inline-block px-3 py-1 rounded-full text-xs font-bold mb-4 ${selectedBadge.earned ? 'bg-[#2e7d32] text-white' : 'bg-[#bdbdbd] text-white'}`}>
                {selectedBadge.earned ? '獲得済み' : '未獲得'}
              </div>

              <p className="text-[#5d4037] text-xs sm:text-sm font-medium leading-relaxed">
                {selectedBadge.desc}
              </p>
              
              {!selectedBadge.earned && (
                <p className="mt-4 text-[10px] sm:text-xs text-[#8d6e63] border-t border-[#d7ccc8] pt-2">
                  🔒 まだ条件を満たしていません
                </p>
              )}
            </motion.div>
          </div>
        )}
      </AnimatePresence>

    </div>
  );
};

export default EmotionStats;