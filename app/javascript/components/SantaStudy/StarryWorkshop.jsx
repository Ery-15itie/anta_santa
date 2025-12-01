import React, { useEffect, useState, useRef, useLayoutEffect } from 'react';
import { fetchValueCategories, fetchUserSelections, createSelection, deleteSelection } from '../../api/values';
import PuzzlePiece from './PuzzlePiece';
import ReflectionsList from './ReflectionsList'; 
import { Gift, Music, Snowflake, Star, Cloud, Send, Clock, MapPin, Compass, ArrowLeft, BookOpen } from 'lucide-react'; 

const StarryWorkshop = ({ onBack }) => {
  // --- State ---
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  
  const [selections, setSelections] = useState({ past: [], current: [], future: [] });
  const [activeTimeframe, setActiveTimeframe] = useState('current');
  const [isSaving, setIsSaving] = useState(false);
  
  const [viewMode, setViewMode] = useState('workshop');
  const [reflectionText, setReflectionText] = useState("");
  const [selectedDetailCard, setSelectedDetailCard] = useState(null);

  const cardRefs = useRef({}); 
  const [lines, setLines] = useState([]); 

  // --- Initial Load ---
  useEffect(() => {
    const loadData = async () => {
      try {
        const [catRes, selRes] = await Promise.all([
          fetchValueCategories(),
          fetchUserSelections()
        ]);
        if (catRes.data) setCategories(catRes.data);
        
        const newSelections = { past: [], current: [], future: [] };
        if (selRes.data) {
          selRes.data.forEach(s => {
            if (newSelections[s.timeframe]) newSelections[s.timeframe].push(s.value_card_id);
          });
        }
        setSelections(newSelections);
      } catch (error) {
        console.error("Data load failed", error);
      } finally {
        setLoading(false);
      }
    };
    loadData();
  }, []);

  // --- Handlers ---
  const handleCardClick = (card) => {
    if (viewMode !== 'workshop') return;
    setSelectedDetailCard(card);
  };

  const toggleSelection = async (cardId) => {
    const currentList = selections[activeTimeframe];
    let newList;
    let isAdding = !currentList.includes(cardId);

    if (!isAdding) {
      newList = currentList.filter(id => id !== cardId);
      await deleteSelection(cardId, activeTimeframe);
    } else {
      if (currentList.length < 10) {
        newList = [...currentList, cardId];
        await createSelection({ value_card_id: cardId, timeframe: activeTimeframe });
      } else {
        alert("空に浮かべられる星は10個までです ⭐");
        return;
      }
    }
    setSelections(prev => ({ ...prev, [activeTimeframe]: newList }));
    setSelectedDetailCard(null); 
  };

  const handleConfirm = () => setViewMode('reflection_input');

  const handleCompleteReflection = async () => {
    setIsSaving(true);
    const currentList = selections[activeTimeframe];
    const timestamp = new Date().toLocaleString([], { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' });
    const finalNote = `【${timestamp}の記録】\n${reflectionText}`;

    if (currentList.length > 0 && reflectionText) {
      const lastCardId = currentList[currentList.length - 1];
      await createSelection({ 
        value_card_id: lastCardId, 
        timeframe: activeTimeframe, 
        description: finalNote 
      });
    }
    setIsSaving(false);
    alert("航海日誌に記録しました ✒️");
    setViewMode('workshop');
    setReflectionText("");
  };

  useLayoutEffect(() => {
    if (viewMode !== 'workshop') return;
    const calculateLines = () => {
      const currentIds = selections[activeTimeframe];
      if (currentIds.length < 2) {
        setLines([]);
        return;
      }
      const newLines = [];
      for (let i = 0; i < currentIds.length - 1; i++) {
        const startId = currentIds[i];
        const endId = currentIds[i + 1];
        const startEl = cardRefs.current[startId];
        const endEl = cardRefs.current[endId];
        if (startEl && endEl) {
          const startRect = startEl.getBoundingClientRect();
          const endRect = endEl.getBoundingClientRect();
          newLines.push({
            x1: startRect.left + startRect.width / 2, y1: startRect.top + startRect.height / 2,
            x2: endRect.left + endRect.width / 2, y2: endRect.top + endRect.height / 2
          });
        }
      }
      setLines(newLines);
    };
    calculateLines();
    window.addEventListener('resize', calculateLines);
    return () => window.removeEventListener('resize', calculateLines);
  }, [selections, activeTimeframe, loading, viewMode]);

  // --- UI Components ---
  const TimeTab = ({ id, label, icon: Icon }) => (
    <button
      onClick={() => { setActiveTimeframe(id); setViewMode('workshop'); }}
      className={`
        flex items-center gap-2 px-4 py-2 rounded-full transition-all duration-300 border backdrop-blur-md
        ${activeTimeframe === id 
          ? 'bg-yellow-500/90 text-white border-yellow-400 shadow-[0_0_15px_rgba(234,179,8,0.5)] scale-105' 
          : 'bg-white/5 text-slate-300 border-white/10 hover:bg-white/10 hover:border-white/30'}
      `}
    >
      <Icon size={16} />
      <span className="text-sm font-bold">{label}</span>
    </button>
  );

  // === 画面表示切り替え ===
  if (viewMode === 'reflection_list') {
    return <ReflectionsList onBack={() => setViewMode('workshop')} />;
  }

  // === メインの戻り値 ===
  return (
    <div className="min-h-screen bg-[radial-gradient(ellipse_at_bottom,_var(--tw-gradient-stops))] from-[#1e1b4b] via-[#0f172a] to-[#020617] text-white font-sans fixed inset-0 z-50 overflow-y-auto overflow-x-hidden">
      
      {/* 背景装飾 */}
      <div className="fixed inset-0 pointer-events-none z-0 select-none overflow-hidden">
        <style>{`
          @keyframes float-random { 0%, 100% { transform: translate(0, 0); } 50% { transform: translate(0, -10px); } }
          @keyframes drift { 0% { transform: translateX(-10vw); opacity: 0; } 50% { opacity: 0.5; } 100% { transform: translateX(110vw); opacity: 0; } }
          @keyframes twinkle { 0%, 100% { opacity: 0.3; transform: scale(1); } 50% { opacity: 1; transform: scale(1.2); } }
          .animate-float-random { animation: float-random 6s ease-in-out infinite; }
          .animate-drift { animation: drift 60s linear infinite; }
          .animate-twinkle { animation: twinkle 4s ease-in-out infinite; }
        `}</style>
        <div className="absolute top-[-5%] right-[-5%] w-[500px] h-[500px] bg-yellow-100/5 rounded-full blur-[100px]"></div>
        <div className="absolute top-1/2 left-0 animate-drift opacity-50" style={{ animationDelay: '5s' }}>
           <div className="text-7xl filter grayscale brightness-200 contrast-0 blur-[1px] transform -rotate-6 drop-shadow-lg">🛷💨</div>
        </div>
        {[...Array(30)].map((_, i) => (
          <div key={i} className="absolute text-yellow-100 animate-twinkle" style={{ top: `${Math.random()*100}%`, left: `${Math.random()*100}%`, opacity: Math.random()*0.5+0.1, animationDelay: `${Math.random()*5}s`, transform: `scale(${Math.random()*0.8+0.5})` }}>
            <Star size={Math.random() > 0.8 ? 16 : 8} fill="currentColor" />
          </div>
        ))}
      </div>

      {/* 星座線 */}
      <svg className="fixed inset-0 pointer-events-none z-0" style={{ width: '100%', height: '100%' }}>
        <defs><filter id="glow"><feGaussianBlur stdDeviation="2" result="coloredBlur"/><feMerge><feMergeNode in="coloredBlur"/><feMergeNode in="SourceGraphic"/></feMerge></filter></defs>
        {lines.map((line, i) => (
          <line key={i} x1={line.x1} y1={line.y1} x2={line.x2} y2={line.y2} stroke="#fcd34d" strokeWidth="2" strokeDasharray="4, 4" strokeOpacity="0.6" filter="url(#glow)" />
        ))}
      </svg>

      {/* ヘッダー */}
      <header className="fixed top-0 left-0 right-0 z-50 px-6 py-4 bg-[#0f172a]/80 backdrop-blur-xl border-b border-white/10 shadow-2xl">
        <div className="flex justify-between items-center mb-4 max-w-7xl mx-auto w-full">
          <h1 className="text-xl font-bold text-yellow-100 flex items-center gap-3 font-serif tracking-wider">
            <span className="text-3xl filter drop-shadow-[0_0_10px_rgba(253,224,71,0.5)]">📖</span> 
            サンタの書斎 
          </h1>
          <button onClick={onBack} className="text-sm bg-white/5 hover:bg-white/10 px-5 py-2.5 rounded-full border border-white/10 flex items-center gap-2 transition-all">
            <span>🏠</span> <span className="hidden sm:inline">部屋に戻る</span>
          </button>
        </div>
        <div className="flex justify-center gap-3 sm:gap-6">
          <TimeTab id="past" label="過去" icon={Clock} />
          <TimeTab id="current" label="現在" icon={MapPin} />
          <TimeTab id="future" label="未来" icon={Compass} />
        </div>
      </header>

           {/* メインコンテンツ */}
      <main className="container mx-auto px-4 pt-48 pb-40 relative z-10 max-w-7xl">
        {loading ? (
          <div className="text-center mt-32 text-yellow-100 animate-pulse">星々を集めています...</div>
        ) : (
          <div className={"grid grid-cols-1 md:grid-cols-2 gap-16 transition-all duration-700 " + (viewMode !== 'workshop' ? 'opacity-20 blur-sm pointer-events-none' : 'opacity-100')}>
            {categories.map((category, index) => {
              const borderRadius = index % 2 === 0 
                ? '60% 40% 70% 30% / 60% 30% 70% 40%' 
                : '40% 60% 30% 70% / 50% 60% 30% 60%';
              
              const bgGradient = 'linear-gradient(135deg, ' + category.theme_color + '15 0%, ' + category.theme_color + '05 100%)';
              const boxShadowValue = 'inset 0 0 40px ' + category.theme_color + '20, 0 10px 30px rgba(0,0,0,0.3)';
              const borderValue = '1px solid ' + category.theme_color + '30';
              const dotShadow = '0 0 10px ' + category.theme_color;

              return (
                <div 
                  key={category.id} 
                  className="relative p-8 transition-all duration-500 hover:scale-[1.02]"
                  style={{
                    background: bgGradient,
                    backdropFilter: 'blur(12px)',
                    boxShadow: boxShadowValue,
                    border: borderValue,
                    borderRadius: borderRadius,
                  }}
                >
                  <div className="absolute -top-4 left-1/2 -translate-x-1/2 bg-[#0f172a] px-5 py-2 rounded-full border border-white/20 shadow-xl flex items-center gap-3 z-20">
                    <div 
                      className="w-3 h-3 rounded-full shadow-[0_0_10px]" 
                      style={{ 
                        backgroundColor: category.theme_color, 
                        boxShadow: dotShadow 
                      }}
                    ></div>
                    <h2 className="text-lg font-bold text-slate-200 font-serif tracking-wider whitespace-nowrap">
                      {category.name}
                    </h2>
                  </div>

                  <div className="flex flex-wrap justify-center items-center gap-6 mt-6 min-h-[140px] px-4">
                    {category.value_cards.map((card, i) => {
                      const animDelay = (i * 0.5) + 's';
                      
                      return (
                        <div 
                          key={card.id} 
                          className="animate-float-random" 
                          style={{ animationDelay: animDelay }}
                          ref={el => {
                            if (el) {
                              cardRefs.current[card.id] = el;
                            }
                          }}
                        >
                          <PuzzlePiece
                            card={card}
                            color={category.theme_color}
                            isSelected={selections[activeTimeframe].includes(card.id)}
                            onClick={() => handleCardClick(card)} 
                          />
                        </div>
                      );
                    })}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </main>

      {/* フッター */}
      {viewMode === 'workshop' && (
        <div className="fixed bottom-0 left-0 right-0 p-4 bg-[#0f172a]/90 border-t border-white/10 backdrop-blur-xl z-50">
          <div className="container mx-auto flex justify-between items-center max-w-4xl">
            <div className="text-sm text-slate-300">
              <span className="text-slate-400">Stars:</span> 
              <span className={"text-2xl font-bold ml-1 " + (selections[activeTimeframe].length === 10 ? 'text-green-400' : 'text-yellow-400')}>
                {selections[activeTimeframe].length}
              </span> 
              <span className="text-slate-600 text-lg">/ 10</span>
            </div>
            
            <button 
              onClick={() => setViewMode('reflection_list')}
              className="flex items-center gap-2 text-xs text-slate-400 hover:text-white hover:bg-white/10 px-3 py-2 rounded-lg transition-colors mr-auto ml-4"
            >
              <BookOpen size={14} /> 過去の記録を見る
            </button>

            <button 
              onClick={handleConfirm}
              disabled={selections[activeTimeframe].length === 0}
              className={"px-8 py-3 rounded-full font-bold shadow-2xl transition-all flex items-center gap-3 " + (selections[activeTimeframe].length > 0 ? 'bg-gradient-to-r from-yellow-500 to-amber-600 text-white hover:scale-105' : 'bg-white/5 text-slate-600 cursor-not-allowed')}
            >
              決定して振り返る <Send size={18} />
            </button>
          </div>
        </div>
      )}

      {/* 詳細 & 登録モーダル */}
      {selectedDetailCard && (
        <div 
          className="fixed inset-0 z-[70] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-fade-in" 
          onClick={() => setSelectedDetailCard(null)}
        >
          <div 
            className="bg-[#1e1b4b] border-2 border-yellow-500/30 p-8 rounded-2xl max-w-md w-full shadow-[0_0_50px_rgba(251,191,36,0.2)] relative overflow-hidden" 
            onClick={e => e.stopPropagation()}
          >
            <button 
              onClick={() => setSelectedDetailCard(null)} 
              className="absolute top-4 right-4 text-slate-400 hover:text-white"
            >
              <ArrowLeft size={24} />
            </button>
            <div className="flex flex-col items-center text-center">
              <div className="w-20 h-20 rounded-full bg-yellow-500/20 flex items-center justify-center mb-6 border border-yellow-500/50 shadow-[0_0_30px_rgba(251,191,36,0.3)]">
                <Star size={40} className="text-yellow-400 fill-yellow-400" />
              </div>
              <h3 className="text-2xl font-bold text-white mb-2 font-serif tracking-wider">
                {selectedDetailCard.name}
              </h3>
              <div className="w-12 h-1 bg-gradient-to-r from-transparent via-yellow-500 to-transparent mb-6"></div>
              <p className="text-slate-200 text-lg leading-relaxed mb-8 font-medium">
                {selectedDetailCard.description}
              </p>
              {selections[activeTimeframe].includes(selectedDetailCard.id) ? (
                <button 
                  onClick={() => toggleSelection(selectedDetailCard.id)} 
                  className="w-full py-3 rounded-xl border border-red-500/50 text-red-300 hover:bg-red-500/10 transition-colors"
                >
                  星を空から外す
                </button>
              ) : (
                <button 
                  onClick={() => toggleSelection(selectedDetailCard.id)} 
                  className="w-full bg-gradient-to-r from-yellow-500 to-amber-600 text-white font-bold py-4 rounded-xl hover:brightness-110 shadow-lg flex justify-center items-center gap-2"
                >
                  この価値観を星として登録する <Star size={18} fill="currentColor" />
                </button>
              )}
            </div>
          </div>
        </div>
      )}

      {/* 振り返り入力モーダル */}
      {viewMode === 'reflection_input' && (
        <div className="fixed inset-0 z-[60] flex items-center justify-center p-4 bg-black/60 backdrop-blur-md animate-fade-in">
          <div className="bg-[#1e1b4b]/95 border border-white/20 p-8 rounded-3xl max-w-lg w-full shadow-2xl relative overflow-hidden">
            <button 
              onClick={() => setViewMode('workshop')} 
              className="absolute top-6 right-6 text-slate-400 hover:text-white"
            >
              <ArrowLeft size={24} />
            </button>
            <h3 className="text-2xl font-bold text-yellow-100 mb-2 font-serif flex items-center gap-3">
              <span>✒️</span> 航海日誌
            </h3>
            <p className="text-slate-300 text-sm mb-6 opacity-80">
              {activeTimeframe === 'past' && "過去のあなたを支えた羅針盤は何でしたか？"}
              {activeTimeframe === 'current' && "今、この星々を選んだ理由は何ですか？"}
              {activeTimeframe === 'future' && "未来の航路を照らす光について教えてください。"}
            </p>
            <div className="text-xs text-slate-500 mb-2 text-right">
              Date: {new Date().toLocaleDateString()}
            </div>
            <textarea
              className="w-full h-40 bg-[#020617]/50 border border-white/10 rounded-xl p-5 text-slate-200 focus:ring-2 focus:ring-yellow-500/50 outline-none resize-none"
              placeholder="ここに想いを書き留めてください..."
              value={reflectionText}
              onChange={(e) => setReflectionText(e.target.value)}
            />
            <button 
              onClick={handleCompleteReflection} 
              disabled={isSaving} 
              className="w-full mt-8 bg-gradient-to-r from-yellow-500 to-amber-600 text-white font-bold py-4 rounded-xl hover:brightness-110 shadow-lg flex justify-center items-center gap-2"
            >
              {isSaving ? '記録中...' : '記録を保存する'} <Send size={18} />
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default StarryWorkshop;