import React, { useState, useEffect } from 'react';
import { fetchReflections, saveReflection } from '../../api/values';
import { ChevronLeft, ChevronRight, X, PenTool, Book, Loader, Save } from 'lucide-react';

/**
 * MagicBook コンポーネント (レスポンシブ対応版)
 */
const MagicBook = ({ onClose }) => {
  const [questions, setQuestions] = useState([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [loading, setLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [error, setError] = useState(null);

  // データ取得
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

  // 保存処理
  const handleSave = async () => {
    if (!questions[currentIndex]) return;
    setIsSaving(true);
    try {
      await saveReflection(questions[currentIndex].id, questions[currentIndex].answer);
    } catch (e) {
      console.error("Save failed", e);
    } finally {
      setIsSaving(false);
    }
  };

  // テキスト変更
  const handleTextChange = (e) => {
    const newText = e.target.value;
    const newQuestions = [...questions];
    newQuestions[currentIndex].answer = newText;
    setQuestions(newQuestions);
  };

  // ページ移動
  const handleNext = () => {
    handleSave();
    if (currentIndex < questions.length - 1) setCurrentIndex(prev => prev + 1);
  };

  const handlePrev = () => {
    handleSave();
    if (currentIndex > 0) setCurrentIndex(prev => prev - 1);
  };

  // --- レンダリング ---

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

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-2 sm:p-4 bg-black/90 backdrop-blur-sm animate-fade-in">
      
      {/* 本の外枠: スマホは縦長(h-85vh), PCは横長(aspect-2/1) */}
      <div className="relative w-full max-w-5xl h-[85vh] md:h-auto md:aspect-[2/1] bg-[#fdf6e3] rounded-lg md:rounded-r-2xl md:rounded-l-md shadow-2xl flex flex-col md:flex-row overflow-hidden border-4 md:border-8 border-[#3e2723]">
        
        {/* 閉じるボタン */}
        <button 
          onClick={() => { handleSave(); onClose(); }} 
          className="absolute top-2 right-2 md:top-4 md:right-4 z-30 text-[#5d4037] bg-[#fdf6e3]/50 hover:bg-[#5d4037]/10 p-2 rounded-full transition-colors"
        >
          <X size={24} className="md:w-7 md:h-7" />
        </button>

        {/* --- [上段/左頁] 質問エリア --- */}
        <div className="w-full md:w-1/2 p-6 md:p-12 border-b md:border-b-0 md:border-r border-[#d7ccc8] relative flex flex-col justify-center items-center text-center bg-[#fdf6e3] shrink-0">
          {/* 紙の質感 */}
          <div className="absolute inset-0 bg-[#fdf6e3] opacity-50 pointer-events-none" style={{ backgroundImage: 'radial-gradient(#d7ccc8 1px, transparent 1px)', backgroundSize: '20px 20px' }}></div>
          
          <div className="relative z-10 max-h-[30vh] md:max-h-none overflow-y-auto w-full">
            <div className="text-[#8d6e63] font-serif italic mb-2 md:mb-6 flex items-center justify-center gap-2 text-xs md:text-base">
              <Book size={14} className="md:w-4 md:h-4" />
              <span>Question {currentIndex + 1} / {questions.length}</span>
            </div>
            
            <h2 className="text-lg md:text-3xl font-bold text-[#3e2723] font-serif leading-relaxed mb-4 md:mb-8">
              {questions[currentIndex].body}
            </h2>
            
            <div className="text-[#8d6e63]/50 hidden md:block">
              <PenTool size={48} />
            </div>
          </div>
          
          {/* PC用ページ番号 */}
          <div className="absolute bottom-6 left-6 text-[#8d6e63] font-serif hidden md:block">{currentIndex * 2 + 1}</div>
        </div>

        {/* --- [下段/右頁] 回答エリア --- */}
        <div className="w-full md:w-1/2 flex-1 relative bg-[#fffaf0] flex flex-col">
          {/* 影 (スマホは上から、PCは左から) */}
          <div className="absolute inset-0 bg-gradient-to-b md:bg-gradient-to-l from-black/5 to-transparent pointer-events-none h-4 md:h-full md:w-4 z-10"></div>
          
          <div className="h-full flex flex-col relative z-0">
            {/* 罫線付きテキストエリア */}
            <textarea
              className="w-full h-full bg-transparent resize-none border-none focus:ring-0 text-[#3e2723] font-serif p-4 md:p-8 placeholder-[#bcaaa4]
                         text-base leading-[32px] md:text-xl md:leading-[40px]"
              style={{ 
                // スマホ: 32px間隔 / PC: 40px間隔
                backgroundImage: 'linear-gradient(transparent, transparent calc(100% - 1px), #d7ccc8 calc(100% - 1px))', 
                backgroundSize: '100% 32px', // モバイルデフォルト
              }}
              // PC用のスタイル上書き
              // (Tailwindのクラスだけでbackground-sizeの切り替えが難しいためstyle属性とメディアクエリを併用推奨だが、ここでは簡易的にJSで切り替えるか、CSSクラスで対応)
              placeholder="ここにあなたの答えを記してください..."
              value={questions[currentIndex].answer}
              onChange={handleTextChange}
            />
            {/* styleの上書き用 (インラインスタイルだとメディアクエリが効かないため、ここで動的クラスを使用する代わりにstyleタグを埋め込む手法もありますが、今回は簡便のためstyle属性はモバイル合わせにし、PCはCSSクラスで調整することを想定。ただReactなのでstyleに条件分岐を入れるのが確実です) */}
            <style>{`
              @media (min-width: 768px) {
                textarea {
                  background-size: 100% 40px !important;
                  line-height: 40px !important;
                }
              }
            `}</style>

            {/* 保存中インジケーター */}
            <div className="absolute bottom-2 right-4 md:bottom-4 md:right-12 flex items-center gap-2 text-xs text-[#8d6e63]">
              {isSaving ? <span className="animate-pulse flex items-center gap-1"><Loader size={12} className="animate-spin"/> 保存中...</span> : <span className="flex items-center gap-1 opacity-50"><Save size={12}/> 保存済み</span>}
            </div>
          </div>

          {/* PC用ページ番号 */}
          <div className="absolute bottom-6 right-6 text-[#8d6e63] font-serif hidden md:block">{currentIndex * 2 + 2}</div>
        </div>

        {/* --- ナビゲーション (スマホ: 下部固定バー / PC: 左右矢印) --- */}
        
        {/* PC用矢印 (左右中央) */}
        <button onClick={handlePrev} disabled={currentIndex === 0} className="hidden md:block absolute left-4 top-1/2 -translate-y-1/2 p-3 text-[#5d4037] hover:scale-110 transition bg-[#fdf6e3]/80 rounded-full shadow-lg disabled:opacity-0">
          <ChevronLeft size={32} />
        </button>
        <button onClick={handleNext} disabled={currentIndex === questions.length - 1} className="hidden md:block absolute right-4 top-1/2 -translate-y-1/2 p-3 text-[#5d4037] hover:scale-110 transition bg-[#fdf6e3]/80 rounded-full shadow-lg disabled:opacity-0">
          <ChevronRight size={32} />
        </button>

        {/* スマホ用操作バー (最下部) */}
        <div className="md:hidden flex items-center justify-between px-6 py-3 bg-[#eefebe3] border-t border-[#d7ccc8] text-[#5d4037]">
           <button onClick={handlePrev} disabled={currentIndex === 0} className="flex items-center gap-1 disabled:opacity-30 px-4 py-2">
             <ChevronLeft size={20} /> <span className="text-sm font-bold">前へ</span>
           </button>
           <span className="font-serif text-sm">{currentIndex + 1} / {questions.length}</span>
           <button onClick={handleNext} disabled={currentIndex === questions.length - 1} className="flex items-center gap-1 disabled:opacity-30 px-4 py-2">
             <span className="text-sm font-bold">次へ</span> <ChevronRight size={20} /> 
           </button>
        </div>
        
      </div>
    </div>
  );
};

export default MagicBook;