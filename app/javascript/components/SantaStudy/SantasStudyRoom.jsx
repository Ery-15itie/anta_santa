import React, { useState } from 'react';
import StarryWorkshop from './StarryWorkshop';
import MagicBook from './MagicBook';
import ReflectionsList from './ReflectionsList';
import { ArrowLeft, Map, Book, Library, Flame } from 'lucide-react';

const SantasStudyRoom = ({ onBack }) => {
  // 画面モード: 'room' | 'workshop' | 'magic_book' | 'history'
  const [mode, setMode] = useState('room');

  // --- ナビゲーション制御 ---
  if (mode === 'workshop') {
    return <StarryWorkshop onBack={() => setMode('room')} />;
  }
  if (mode === 'history') {
    return <ReflectionsList onBack={() => setMode('room')} />;
  }

  return (
    <div className="min-h-screen bg-[#2a1b15] relative overflow-hidden font-sans text-white">
      
      {/* --- 書斎の背景と装飾 --- */}
      <div className="absolute inset-0 z-0">
        {/* 壁紙 */}
        <div className="absolute inset-0 bg-[#3e2723] opacity-80" 
             style={{ backgroundImage: 'repeating-linear-gradient(90deg, #3e2723 0, #3e2723 20px, #4e342e 20px, #4e342e 40px)' }}>
        </div>
        {/* 床 */}
        <div className="absolute bottom-0 left-0 right-0 h-1/3 bg-[#1a100c] border-t-8 border-[#1a100c]"></div>
        
        {/* 暖炉の灯り（環境光） */}
        <div className="absolute bottom-20 left-1/2 -translate-x-1/2 w-96 h-96 bg-orange-500/20 rounded-full blur-[100px] animate-pulse"></div>
      </div>

      {/* --- メインUI (部屋のオブジェクト) --- */}
      <div className="relative z-10 container mx-auto px-4 h-screen flex flex-col">
        
        {/* ヘッダー */}
        <header className="flex justify-between items-center py-6">
          <h1 className="text-2xl font-bold text-[#ffecb3] font-serif tracking-wider drop-shadow-md">
            📜 サンタの書斎
          </h1>
          <button 
            onClick={onBack} 
            className="flex items-center gap-2 bg-black/30 hover:bg-black/50 px-4 py-2 rounded-full transition text-sm border border-white/10"
          >
            <ArrowLeft size={16} /> 家に戻る
          </button>
        </header>

        {/* 部屋のコンテンツエリア */}
        <div className="flex-1 flex flex-col md:flex-row items-center justify-center gap-8 md:gap-16 pb-20">
          
          {/* 1. 机と地図 (価値観パズルへ) */}
          <div className="group relative cursor-pointer" onClick={() => setMode('workshop')}>
            <div className="absolute -inset-4 bg-yellow-500/20 rounded-full blur-xl opacity-0 group-hover:opacity-100 transition duration-500"></div>
            <div className="relative bg-[#5d4037] w-64 h-48 rounded-lg shadow-2xl border-b-8 border-[#3e2723] transform group-hover:-translate-y-2 transition duration-300 flex flex-col items-center justify-center border border-[#795548]">
              <Map size={64} className="text-[#ffecb3] mb-3 drop-shadow-md" />
              <div className="text-center">
                <h3 className="text-xl font-bold text-[#ffecb3] font-serif">価値観の地図</h3>
                <p className="text-xs text-[#d7ccc8] mt-1">星空のパズルを開く</p>
              </div>
              {/* 地図っぽい装飾 */}
              <div className="absolute top-2 left-2 w-full h-full border-2 border-dashed border-[#8d6e63]/30 pointer-events-none rounded"></div>
            </div>
          </div>

          {/* 2. 本棚 (航海日誌 & 記録) */}
          <div className="flex flex-col gap-6">
            
            {/* 魔法の本 (質問へ) */}
            <div className="group relative cursor-pointer" onClick={() => setMode('magic_book')}>
              <div className="absolute -inset-4 bg-purple-500/20 rounded-full blur-xl opacity-0 group-hover:opacity-100 transition duration-500"></div>
              <div className="relative bg-[#4a148c] w-64 h-20 rounded-md shadow-xl border-l-8 border-[#311b92] flex items-center px-6 transform group-hover:translate-x-2 transition duration-300">
                <Book size={32} className="text-[#e1bee7] mr-4" />
                <div>
                  <h3 className="text-lg font-bold text-[#e1bee7] font-serif">心の航海日誌</h3>
                  <p className="text-xs text-[#ce93d8]">16の問いに向き合う</p>
                </div>
              </div>
            </div>

            {/* 過去の記録 (リストへ) */}
            <div className="group relative cursor-pointer" onClick={() => setMode('history')}>
              <div className="absolute -inset-4 bg-blue-500/20 rounded-full blur-xl opacity-0 group-hover:opacity-100 transition duration-500"></div>
              <div className="relative bg-[#1a237e] w-60 h-16 rounded-md shadow-xl border-l-8 border-[#0d47a1] flex items-center px-6 transform group-hover:translate-x-2 transition duration-300">
                <Library size={24} className="text-[#c5cae9] mr-4" />
                <div>
                  <h3 className="text-md font-bold text-[#c5cae9] font-serif">星空の記録</h3>
                  <p className="text-[10px] text-[#9fa8da]">過去の軌跡を見る</p>
                </div>
              </div>
            </div>

          </div>
        </div>

        {/* 暖炉の演出 (フッター) */}
        <div className="absolute bottom-0 left-1/2 -translate-x-1/2 w-full max-w-2xl flex flex-col items-center">
          <div className="bg-[#3e2723] w-full h-12 rounded-t-lg shadow-inner flex justify-center items-end pb-2 relative">
             <div className="absolute -top-16 text-orange-500 animate-bounce opacity-80"><Flame size={48} /></div>
             <div className="text-[#8d6e63] text-xs font-serif tracking-widest">SANTA'S STUDY</div>
          </div>
        </div>

      </div>

      {/* 魔法の本モーダル */}
      {mode === 'magic_book' && <MagicBook onClose={() => setMode('room')} />}

    </div>
  );
};

export default SantasStudyRoom;