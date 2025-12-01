import React, { useState, useEffect } from 'react';
import { fetchReflections, saveReflection } from '../../api/values';
import { ChevronLeft, ChevronRight, X, PenTool, Book } from 'lucide-react';

const MagicBook = ({ onClose }) => {
  const [questions, setQuestions] = useState([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [loading, setLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);

  useEffect(() => {
    fetchReflections().then(res => {
      setQuestions(res.data);
      setLoading(false);
    });
  }, []);

  // 自動保存ロジック
  const handleSave = async () => {
    if (!questions[currentIndex]) return;
    setIsSaving(true);
    await saveReflection(questions[currentIndex].id, questions[currentIndex].answer);
    setIsSaving(false);
  };

  const handleTextChange = (e) => {
    const newText = e.target.value;
    const newQuestions = [...questions];
    newQuestions[currentIndex].answer = newText;
    setQuestions(newQuestions);
  };

  const handleNext = () => {
    handleSave();
    if (currentIndex < questions.length - 1) setCurrentIndex(prev => prev + 1);
  };

  const handlePrev = () => {
    handleSave();
    if (currentIndex > 0) setCurrentIndex(prev => prev - 1);
  };

  if (loading) return null;

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-fade-in">
      
      {/* 本のコンテナ */}
      <div className="relative w-full max-w-5xl aspect-[3/2] md:aspect-[2/1] bg-[#fdf6e3] rounded-r-2xl rounded-l-md shadow-[0_20px_50px_rgba(0,0,0,0.9)] flex overflow-hidden border-8 border-[#3e2723]">
        
        {/* 閉じるボタン */}
        <button 
          onClick={() => { handleSave(); onClose(); }} 
          className="absolute top-4 right-4 z-20 text-[#5d4037] hover:bg-[#5d4037]/10 p-2 rounded-full transition-colors"
        >
          <X size={28} />
        </button>

        {/* --- 左ページ (質問) --- */}
        <div className="flex-1 p-8 md:p-12 border-r border-[#d7ccc8] relative flex flex-col justify-center items-center text-center">
          {/* 紙の質感演出 */}
          <div className="absolute inset-0 bg-[#fdf6e3] opacity-50" style={{ backgroundImage: 'radial-gradient(#d7ccc8 1px, transparent 1px)', backgroundSize: '20px 20px' }}></div>
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
          
          <div className="absolute bottom-6 left-6 text-[#8d6e63] font-serif">{currentIndex * 2 + 1}</div>
        </div>

        {/* --- 右ページ (回答) --- */}
        <div className="flex-1 p-8 md:p-12 relative bg-[#fffaf0]">
          <div className="absolute inset-0 bg-gradient-to-l from-transparent to-black/10 pointer-events-none"></div>
          
          <div className="h-full flex flex-col relative z-10">
            <textarea
              className="w-full h-full bg-transparent resize-none border-none focus:ring-0 text-[#3e2723] font-serif text-lg md:text-xl leading-loose p-4 placeholder-[#bcaaa4]"
              style={{ 
                backgroundImage: 'linear-gradient(transparent, transparent 39px, #d7ccc8 39px)', 
                backgroundSize: '100% 40px', 
                lineHeight: '40px' 
              }}
              placeholder="ここにあなたの答えを記してください..."
              value={questions[currentIndex].answer}
              onChange={handleTextChange}
            />
            {isSaving && <span className="absolute bottom-4 right-12 text-xs text-[#8d6e63] animate-pulse">保存中...</span>}
          </div>

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