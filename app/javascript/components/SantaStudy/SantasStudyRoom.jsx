import React, { useState } from 'react';
import StarryWorkshop from './StarryWorkshop';
import MagicBook from './MagicBook';
import ReflectionsList from './ReflectionsList';
import { ArrowLeft, Map, Book, Library, Flame } from 'lucide-react';

/**
 * SantasStudyRoom コンポーネント
 * * サンタの書斎のエントランス（ハブ画面）。
 * 図書館のような落ち着いたUIを提供し、ユーザーの目的に応じて各機能コンポーネントを表示
 * * @param {function} onBack - ホームに戻る
 */
const SantasStudyRoom = ({ onBack }) => {
  // --- 画面モード管理 ---
  // 'room'       : 書斎の部屋（メニュー画面）
  // 'workshop'   : 価値観の地図（星空パズル）
  // 'magic_book' : 心の航海日誌（質問回答）
  // 'history'    : 星空の記録（過去ログ閲覧）
  const [mode, setMode] = useState('room');

  // --- モードによるコンポーネントの切り替え ---
  
  // 1. 価値観パズル画面へ
  if (mode === 'workshop') {
    // onBackで 'room' モードに戻る関数を渡す
    return <StarryWorkshop onBack={() => setMode('room')} />;
  }
  // 2. 過去の記録リストへ
  if (mode === 'history') {
    return <ReflectionsList onBack={() => setMode('room')} />;
  }

  // 3. メイン：書斎の部屋（メニュー）
  return (
    <div className="min-h-screen bg-[#2a1b15] relative overflow-hidden font-sans text-white">
      
      {/* --- 背景装飾レイヤー --- */}
      <div className="absolute inset-0 z-0">
        {/* 壁紙: 重厚な縦ストライプで書斎の厳格さを演出 */}
        <div className="absolute inset-0 bg-[#2d1b15]" 
             style={{ backgroundImage: 'repeating-linear-gradient(90deg, #3e2723 0, #3e2723 40px, #2a1b15 40px, #2a1b15 80px)' }}>
        </div>
        {/* 環境光: 暖炉からの温かい光を下部に配置 */}
        <div className="absolute bottom-0 left-1/2 -translate-x-1/2 w-full h-1/2 bg-gradient-to-t from-orange-900/50 to-transparent blur-3xl"></div>
      </div>

      {/* --- コンテンツレイヤー --- */}
      <div className="relative z-10 container mx-auto px-4 h-screen flex flex-col items-center justify-center">
        
        {/* 左上の戻るボタン */}
        <button 
          onClick={onBack} 
          className="absolute top-6 left-6 flex items-center gap-2 bg-black/40 hover:bg-black/60 px-4 py-2 rounded-full transition text-sm border border-white/10"
        >
          <ArrowLeft size={16} /> 家に戻る
        </button>

        {/* --- 3つのメインメニューボタン --- */}
        <div className="flex flex-col md:flex-row gap-8 items-stretch justify-center w-full max-w-5xl">
          
          {/* 1. 価値観の地図 (メイン機能) */}
          <button 
            type="button"
            onClick={() => setMode('workshop')}
            className="group relative flex-1 bg-[#4e342e] border-4 border-[#3e2723] rounded-xl shadow-2xl p-8 flex flex-col items-center justify-center gap-4 hover:scale-105 transition-transform duration-300 min-h-[240px] cursor-pointer active:scale-95"
          >
            {/* 縫い目のような破線装飾 */}
            <div className="absolute inset-2 border-2 border-dashed border-[#8d6e63]/50 rounded-lg pointer-events-none"></div>
            
            <Map size={64} className="text-[#ffecb3] drop-shadow-md group-hover:scale-110 transition-transform" />
            <div className="text-center">
              <h2 className="text-2xl font-bold text-[#ffecb3] font-serif mb-2">価値観の地図</h2>
              <p className="text-[#d7ccc8] text-sm">星空のパズルを開く</p>
            </div>
          </button>

          {/* 右側のサブメニュー群 */}
          <div className="flex flex-col gap-6 flex-1 justify-center">
            
            {/* 2. 心の航海日誌 (質問) */}
            <button 
              type="button"
              onClick={() => setMode('magic_book')}
              className="group relative bg-[#4a148c] border-l-8 border-[#311b92] rounded-r-lg shadow-xl p-6 flex items-center gap-6 hover:translate-x-2 transition-transform duration-300 cursor-pointer active:scale-95"
            >
              <Book size={40} className="text-[#e1bee7]" />
              <div className="text-left">
                <h3 className="text-xl font-bold text-[#e1bee7] font-serif">心の航海日誌</h3>
                <p className="text-xs text-[#ce93d8]">20の問いに向き合う</p>
              </div>
            </button>

            {/* 3. 星空の記録 (履歴) */}
            <button 
              type="button"
              onClick={() => setMode('history')}
              className="group relative bg-[#1a237e] border-l-8 border-[#0d47a1] rounded-r-lg shadow-xl p-6 flex items-center gap-6 hover:translate-x-2 transition-transform duration-300 cursor-pointer active:scale-95"
            >
              <Library size={40} className="text-[#c5cae9]" />
              <div className="text-left">
                <h3 className="text-xl font-bold text-[#c5cae9] font-serif">星空の記録</h3>
                <p className="text-xs text-[#9fa8da]">過去の軌跡を見る</p>
              </div>
            </button>

          </div>
        </div>

      </div>

      {/* --- モーダル展開 --- */}
      {/* 魔法の本は「部屋の中で開いている」演出のため、モーダルとして表示 */}
      {mode === 'magic_book' && <MagicBook onClose={() => setMode('room')} />}

    </div>
  );
};

export default SantasStudyRoom;