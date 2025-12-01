import React, { useState, useEffect } from 'react';
import { fetchReflections, saveReflection } from '../../api/values';
import { ChevronLeft, ChevronRight, X, PenTool, Book, Loader } from 'lucide-react';

/**
 * MagicBook コンポーネント
 * * 「心の航海日誌」機能を提供するモーダルコンポーネント。
 * APIから質問を取得し、本のようなUIで1ページずつ回答を入力・保存
 * * @param {function} onClose - 本を閉じる
 */
const MagicBook = ({ onClose }) => {
  // --- State管理 ---
  // questions: APIから取得した質問と回答のリスト
  const [questions, setQuestions] = useState([]);
  // currentIndex: 現在開いている質問のインデックス（0始まり）
  const [currentIndex, setCurrentIndex] = useState(0);
  // loading: 初期データ読み込み中かどうか
  const [loading, setLoading] = useState(true);
  // isSaving: 回答の保存処理中かどうか（インジケーター表示用）
  const [isSaving, setIsSaving] = useState(false);
  // error: データ取得時のエラーメッセージ
  const [error, setError] = useState(null);

  /**
   * 初期化処理: コンポーネントマウント時に質問データをAPIから取得
   */
  useEffect(() => {
    const loadData = async () => {
      try {
        const res = await fetchReflections();
        if (res.data && res.data.length > 0) {
          setQuestions(res.data);
        } else {
          setError("質問データが見つかりませんでした。");
        }
      } catch (err) {
        console.error("Failed to load reflections", err);
        setError("航海日誌を開けませんでした。通信状況を確認してください。");
      } finally {
        setLoading(false);
      }
    };
    loadData();
  }, []);

  /**
   * 回答保存ロジック
   * * ページ遷移時や閉じる時に呼び出され、現在の回答をAPIに送信
   * ユーザーが明示的に保存ボタンを押さなくても良い「自動保存」形式
   */
  const handleSave = async () => {
    if (!questions[currentIndex]) return;
    setIsSaving(true);
    try {
      await saveReflection(questions[currentIndex].id, questions[currentIndex].answer);
    } catch (e) {
      console.error("Save failed", e);
      // エラー時はここでユーザーに通知する処理を入れても良い
    } finally {
      setIsSaving(false);
    }
  };

  /**
   * テキストエリア入力ハンドラー
   * * ローカルのState（questions）を即時更新し、UIに入力を反映させる
   */
  const handleTextChange = (e) => {
    const newText = e.target.value;
    const newQuestions = [...questions];
    // 現在の質問の回答を更新
    newQuestions[currentIndex].answer = newText;
    setQuestions(newQuestions);
  };

  /**
   * 次のページへ進む
   * 移動前に現在のページの内容を保存する
   */
  const handleNext = () => {
    handleSave();
    if (currentIndex < questions.length - 1) setCurrentIndex(prev => prev + 1);
  };

  /**
   * 前のページへ戻る
   * 移動前に現在のページの内容を保存する
   */
  const handlePrev = () => {
    handleSave();
    if (currentIndex > 0) setCurrentIndex(prev => prev - 1);
  };

  // --- レンダリング分岐 ---

  // 1. 読み込み中
  if (loading) {
    return (
      <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-fade-in">
        <div className="text-center text-[#ffecb3]">
          <Loader size={48} className="animate-spin mx-auto mb-4" />
          <p className="font-serif tracking-widest">日誌の紐を解いています...</p>
        </div>
      </div>
    );
  }

  // 2. エラー発生時
  if (error) {
    return (
      <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-fade-in">
        <div className="bg-[#fdf6e3] p-8 rounded-lg text-center max-w-md border-4 border-[#3e2723]">
          <p className="text-[#5d4037] mb-6 font-bold">{error}</p>
          <button onClick={onClose} className="bg-[#3e2723] text-[#ffecb3] px-6 py-2 rounded-full hover:bg-[#4e342e]">
            閉じる
          </button>
        </div>
      </div>
    );
  }

  // 3. メインビュー（本）
  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-fade-in">
      
      {/* 本の外枠コンテナ: アスペクト比を固定して本の形状を維持 */}
      <div className="relative w-full max-w-5xl aspect-[3/2] md:aspect-[2/1] bg-[#fdf6e3] rounded-r-2xl rounded-l-md shadow-[0_20px_50px_rgba(0,0,0,0.9)] flex overflow-hidden border-8 border-[#3e2723]">
        
        {/* 閉じるボタン: 閉じる際も保存を実行 */}
        <button 
          onClick={() => { handleSave(); onClose(); }} 
          className="absolute top-4 right-4 z-20 text-[#5d4037] hover:bg-[#5d4037]/10 p-2 rounded-full transition-colors"
        >
          <X size={28} />
        </button>

        {/* --- 左ページ (質問表示エリア) --- */}
        <div className="flex-1 p-8 md:p-12 border-r border-[#d7ccc8] relative flex flex-col justify-center items-center text-center">
          {/* 紙の質感をCSSグラデーションで表現 */}
          <div className="absolute inset-0 bg-[#fdf6e3] opacity-50" style={{ backgroundImage: 'radial-gradient(#d7ccc8 1px, transparent 1px)', backgroundSize: '20px 20px' }}></div>
          {/* 本のノド（中央）の影 */}
          <div className="absolute inset-0 bg-gradient-to-r from-transparent to-black/5 pointer-events-none"></div>
          
          <div className="relative z-10">
            <div className="text-[#8d6e63] font-serif italic mb-6 flex items-center justify-center gap-2">
              <Book size={16} />
              <span>Question {currentIndex + 1} / {questions.length}</span>
            </div>
            
            <h2 className="text-xl md:text-3xl font-bold text-[#3e2723] font-serif leading-relaxed mb-8">
              {questions[currentIndex].body}
            </h2>
            
            <div className="text-[#8d6e63]/50">
              <PenTool size={48} />
            </div>
          </div>
          
          {/* ページ番号（奇数） */}
          <div className="absolute bottom-6 left-6 text-[#8d6e63] font-serif">{currentIndex * 2 + 1}</div>
        </div>

        {/* --- 右ページ (回答入力エリア) --- */}
        <div className="flex-1 p-8 md:p-12 relative bg-[#fffaf0]">
          <div className="absolute inset-0 bg-gradient-to-l from-transparent to-black/10 pointer-events-none"></div>
          
          <div className="h-full flex flex-col relative z-10">
            {/* 罫線付きのテキストエリア */}
            <textarea
              className="w-full h-full bg-transparent resize-none border-none focus:ring-0 text-[#3e2723] font-serif text-lg md:text-xl leading-loose p-4 placeholder-[#bcaaa4]"
              style={{ 
                // CSSグラデーションでノートの罫線を引く
                backgroundImage: 'linear-gradient(transparent, transparent 39px, #d7ccc8 39px)', 
                backgroundSize: '100% 40px', 
                lineHeight: '40px' 
              }}
              placeholder="ここにあなたの答えを記してください..."
              value={questions[currentIndex].answer}
              onChange={handleTextChange}
            />
            {/* 保存中インジケーター */}
            {isSaving && <span className="absolute bottom-4 right-12 text-xs text-[#8d6e63] animate-pulse">保存中...</span>}
          </div>

          {/* ページ番号（偶数） */}
          <div className="absolute bottom-6 right-6 text-[#8d6e63] font-serif">{currentIndex * 2 + 2}</div>
        </div>

        {/* --- ページめくりボタン --- */}
        {currentIndex > 0 && (
          <button onClick={handlePrev} className="absolute left-2 md:left-4 top-1/2 -translate-y-1/2 p-3 text-[#5d4037] hover:scale-110 transition bg-[#fdf6e3]/80 rounded-full shadow-lg">
            <ChevronLeft size={32} />
          </button>
        )}
        {currentIndex < questions.length - 1 && (
          <button onClick={handleNext} className="absolute right-2 md:right-4 top-1/2 -translate-y-1/2 p-3 text-[#5d4037] hover:scale-110 transition bg-[#fdf6e3]/80 rounded-full shadow-lg">
            <ChevronRight size={32} />
          </button>
        )}
        
      </div>
    </div>
  );
};

export default MagicBook;