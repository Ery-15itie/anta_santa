import React, { useEffect, useState, useRef, useLayoutEffect } from 'react';
import { fetchValueCategories, fetchUserSelections, createSelection, deleteSelection } from '../../api/values';
import PuzzlePiece from './PuzzlePiece';
import { 
  Gift, 
  Music, 
  Snowflake, 
  Star, 
  Cloud, 
  Send, 
  Clock, 
  MapPin, 
  Compass, 
  ArrowLeft, 
  Check, 
  AlertCircle 
} from 'lucide-react'; 

/**
 * Toast コンポーネント
 * 画面上部に通知メッセージを表示
 */
const Toast = ({ message, type = 'success' }) => {
  const baseClass = "fixed top-10 left-1/2 -translate-x-1/2 z-[100] px-6 py-4 rounded-lg shadow-2xl flex items-center gap-3 animate-fade-in-down border";
  const colorClass = type === 'error' 
    ? "bg-red-50 text-red-800 border-red-200" 
    : "bg-white text-[#5d4037] border-[#d7ccc8]";
  
  const iconBgClass = type === 'error' ? "bg-red-100 text-red-600" : "bg-green-100 text-green-600";

  return (
    <div className={`${baseClass} ${colorClass}`}>
      <div className={`p-1 rounded-full ${iconBgClass}`}>
        {type === 'error' ? <AlertCircle size={16} /> : <Check size={16} />}
      </div>
      <span className="font-bold">{message}</span>
    </div>
  );
};

const StarryWorkshop = ({ onBack }) => {
  // --- State定義 ---
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  
  const [selections, setSelections] = useState({ past: [], current: [], future: [] });
  const [activeTimeframe, setActiveTimeframe] = useState('current');
  const [isSaving, setIsSaving] = useState(false);
  const [toast, setToast] = useState(null);
  
  const [viewMode, setViewMode] = useState('workshop'); // 'workshop' | 'reflection_input'
  const [reflectionText, setReflectionText] = useState("");
  const [selectedDetailCard, setSelectedDetailCard] = useState(null);
  const [shouldReset, setShouldReset] = useState(true);

  const cardRefs = useRef({});
  const [lines, setLines] = useState([]);

  // --- 初期データ読み込み ---
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
            if (newSelections[s.timeframe]) {
              newSelections[s.timeframe].push(s.value_card_id);
            }
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

  // 通知表示ヘルパー
  const showToast = (msg, type = 'success') => {
    setToast({ message: msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  // --- イベントハンドラー ---

  const handleCardClick = (card) => {
    if (viewMode !== 'workshop') return;
    setSelectedDetailCard(card);
  };

  const toggleSelection = async (cardId) => {
    const currentList = selections[activeTimeframe];
    let newList;
    let isAdding = !currentList.includes(cardId);

    if (!isAdding) {
      // 解除処理
      newList = currentList.filter(id => id !== cardId);
      await deleteSelection(cardId, activeTimeframe);
    } else {
      // 追加処理
      if (currentList.length < 10) {
        newList = [...currentList, cardId];
        await createSelection({ value_card_id: cardId, timeframe: activeTimeframe });
      } else {
        showToast("空に浮かべられる星は10個までです ⭐", 'error');
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
    
    // 選んだカードの名前
    const selectedCardNames = currentList.map(id => {
      const c = categories.flatMap(cat => cat.value_cards).find(card => card.id === id);
      return c ? c.name : '';
    }).filter(Boolean).join(', ');

    const timestamp = new Date().toLocaleString([], { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' });
    const finalNote = `【${timestamp}の記録】\n⭐ 選んだ星: ${selectedCardNames}\n\n${reflectionText}`;

    try {
      if (currentList.length > 0) {
        const lastCardId = currentList[currentList.length - 1];
        await createSelection({ 
          value_card_id: lastCardId, 
          timeframe: activeTimeframe, 
          description: finalNote 
        });
      }

      showToast("航海日誌に記録しました ✒️");
      
      if (shouldReset) {
        setSelections(prev => ({ ...prev, [activeTimeframe]: [] }));
      }

      setViewMode('workshop');
      setReflectionText("");
    } catch (e) {
      console.error(e);
      showToast("保存に失敗しました", 'error');
    } finally {
      setIsSaving(false);
    }
  };

  // --- 星座線の描画ロジック ---
  useLayoutEffect(() => {
    if (viewMode !== 'workshop') return;
    const calculateLines = () => {
      const currentIds = selections[activeTimeframe];
      if (currentIds.length < 2) {
        setLines([]); return;
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
            x1: startRect.left + startRect.width / 2, 
            y1: startRect.top + startRect.height / 2,
            x2: endRect.left + endRect.width / 2, 
            y2: endRect.top + endRect.height / 2
          });
        }
      }
      setLines(newLines);
    };
    calculateLines();
    window.addEventListener('resize', calculateLines);
    return () => window.removeEventListener('resize', calculateLines);
  }, [selections, activeTimeframe, loading, viewMode]);

  // --- メッセージ定義 ---
  const getReflectionMessage = () => {
    switch(activeTimeframe) {
      case 'past':
        return "あの頃、この価値観があなたをどう支えていましたか？\n当時のエピソードがあれば書き残しましょう。";
      case 'current':
        return "今、これらの価値観を選んだ理由は何ですか？\n現在のあなたの指針となっている想いを言葉にしてみましょう。";
      case 'future':
        return "この価値観を大切にして、どんな未来を描きますか？\n理想の自分に近づくための第一歩は何でしょう。";
      default:
        return "今の気持ちを書き留めましょう。";
    }
  };

  // --- サブコンポーネント: 時間軸タブ ---
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

  const toys = ['🎁', '🧸', '🚂', '🤖', '🧩', '🥁', '🎺', '🎨', '🚀', '🏰', '🎠', '🎮'];

  return (
    <div className="min-h-screen bg-[radial-gradient(ellipse_at_bottom,_var(--tw-gradient-stops))] from-[#1e1b4b] via-[#0f172a] to-[#020617] text-white font-sans fixed inset-0 z-50 overflow-y-auto overflow-x-hidden">
      
      {toast && <Toast message={toast.message} type={toast.type} />}

      {/* --- 背景装飾 --- */}
      <div className="fixed inset-0 pointer-events-none z-0 select-none overflow-hidden">
        <style>{`
          @keyframes float-random { 0%, 100% { transform: translate(0, 0); } 50% { transform: translate(0, -10px); } }
          @keyframes drift { 0% { transform: translateX(-10vw); opacity: 0; } 10% { opacity: 0.5; } 90% { opacity: 0.5; } 100% { transform: translateX(110vw); opacity: 0; } }
          @keyframes drift-slow { 0% { transform: translateX(-10vw) translateY(0); opacity: 0; } 20% { opacity: 0.3; } 80% { opacity: 0.3; } 100% { transform: translateX(110vw) translateY(20px); opacity: 0; } }
          @keyframes twinkle { 0%, 100% { opacity: 0.3; transform: scale(1); } 50% { opacity: 1; transform: scale(1.2); } }
          .animate-float-random { animation: float-random 6s ease-in-out infinite; }
          .animate-drift { animation: drift 60s linear infinite; }
          .animate-drift-slow { animation: drift-slow 90s linear infinite; }
          .animate-twinkle { animation: twinkle 4s ease-in-out infinite; }
        `}</style>
        
        {/* 光のオーラ */}
        <div className="absolute top-[-5%] right-[-5%] w-[500px] h-[500px] bg-yellow-100/5 rounded-full blur-[100px]"></div>
        
        {/* ソリ */}
        <div className="absolute top-1/2 left-0 animate-drift opacity-50" style={{ animationDelay: '5s' }}>
           <div className="text-7xl filter grayscale brightness-200 contrast-0 blur-[1px] transform -rotate-6 drop-shadow-lg">🛷💨</div>
        </div>

        {/* 星々 */}
        {[...Array(30)].map((_, i) => (
          <div 
            key={`star-${i}`} 
            className="absolute text-yellow-100 animate-twinkle" 
            style={{ 
              top: `${Math.random()*100}%`, 
              left: `${Math.random()*100}%`, 
              opacity: Math.random()*0.5+0.1, 
              animationDelay: `${Math.random()*5}s`, 
              transform: `scale(${Math.random()*0.8+0.5})` 
            }}
          >
            <Star size={Math.random() > 0.8 ? 16 : 8} fill="currentColor" />
          </div>
        ))}

        {/* おもちゃ */}
        {[...Array(20)].map((_, i) => {
          const toy = toys[Math.floor(Math.random() * toys.length)];
          return (
            <div 
              key={`toy-${i}`} 
              className="absolute animate-drift-slow filter grayscale brightness-150 contrast-50 blur-[1px] drop-shadow-md" 
              style={{ 
                top: `${Math.random() * 80 + 10}%`,
                left: `${Math.random() * 20 - 20}%`,
                fontSize: `${Math.random() * 2 + 1.5}rem`,
                opacity: Math.random() * 0.2 + 0.1,
                animationDelay: `${Math.random() * 60}s`,
                animationDuration: `${Math.random() * 60 + 60}s`
              }}
            >
              {toy}
            </div>
          );
        })}
      </div>

      {/* 星座線 */}
      <svg className="fixed inset-0 pointer-events-none z-0" style={{ width: '100%', height: '100%' }}>
        <defs>
          <filter id="glow">
            <feGaussianBlur stdDeviation="2" result="coloredBlur"/>
            <feMerge>
              <feMergeNode in="coloredBlur"/>
              <feMergeNode in="SourceGraphic"/>
            </feMerge>
          </filter>
        </defs>
        {lines.map((line, i) => (
          <line 
            key={i} 
            x1={line.x1} y1={line.y1} 
            x2={line.x2} y2={line.y2} 
            stroke="#fcd34d" 
            strokeWidth="2" 
            strokeDasharray="4, 4" 
            strokeOpacity="0.6" 
            filter="url(#glow)" 
          />
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
            <span>🚪</span> <span className="hidden sm:inline">書斎に戻る</span>
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
          <div className={`grid grid-cols-1 md:grid-cols-2 gap-16 transition-all duration-700 ${viewMode !== 'workshop' ? 'opacity-20 blur-sm pointer-events-none' : 'opacity-100'}`}>
            {categories.map((category, index) => (
              <div 
                key={category.id} 
                className="relative p-8 transition-all duration-500 hover:scale-[1.02]"
                style={{
                  background: `linear-gradient(135deg, ${category.theme_color}15 0%, ${category.theme_color}05 100%)`,
                  backdropFilter: 'blur(12px)',
                  boxShadow: `inset 0 0 40px ${category.theme_color}20, 0 10px 30px rgba(0,0,0,0.3)`,
                  border: `1px solid ${category.theme_color}30`,
                  borderRadius: index % 2 === 0 ? '60% 40% 70% 30% / 60% 30% 70% 40%' : '40% 60% 30% 70% / 50% 60% 30% 60%',
                }}
              >
                <div className="absolute -top-4 left-1/2 -translate-x-1/2 bg-[#0f172a] px-5 py-2 rounded-full border border-white/20 shadow-xl flex items-center gap-3 z-20">
                  <div className="w-3 h-3 rounded-full shadow-[0_0_10px]" style={{ backgroundColor: category.theme_color, boxShadow: `0 0 10px ${category.theme_color}` }}></div>
                  <h2 className="text-lg font-bold text-slate-200 font-serif tracking-wider whitespace-nowrap">{category.name}</h2>
                </div>
                <div className="flex flex-wrap justify-center items-center gap-6 mt-6 min-h-[140px] px-4">
                  {category.value_cards.map((card, i) => (
                    <div key={card.id} className="animate-float-random" style={{ animationDelay: `${i * 0.5}s` }}>
                      <PuzzlePiece
                        ref={el => cardRefs.current[card.id] = el}
                        card={card}
                        color={category.theme_color}
                        isSelected={selections[activeTimeframe].includes(card.id)}
                        onClick={() => handleCardClick(card)} 
                      />
                    </div>
                  ))}
                </div>
              </div>
            ))}
          </div>
        )}
      </main>

      {/* フッター */}
      {viewMode === 'workshop' && (
        <div className="fixed bottom-0 left-0 right-0 p-4 bg-[#0f172a]/90 border-t border-white/10 backdrop-blur-xl z-50">
          <div className="container mx-auto flex justify-between items-center max-w-4xl">
            <div className="text-sm text-slate-300">
              <span className="text-slate-400">Stars:</span> 
              <span className={`text-2xl font-bold ml-1 ${selections[activeTimeframe].length === 10 ? 'text-green-400' : 'text-yellow-400'}`}>{selections[activeTimeframe].length}</span> 
              <span className="text-slate-600 text-lg">/ 10</span>
            </div>
            
            <button 
              onClick={handleConfirm}
              disabled={selections[activeTimeframe].length === 0}
              className={`px-8 py-3 rounded-full font-bold shadow-2xl transition-all flex items-center gap-3 ${selections[activeTimeframe].length > 0 ? 'bg-gradient-to-r from-yellow-500 to-amber-600 text-white hover:scale-105' : 'bg-white/5 text-slate-600 cursor-not-allowed'}`}
            >
              星空を決定する <Send size={18} />
            </button>
          </div>
        </div>
      )}

      {/* 詳細モーダル */}
      {selectedDetailCard && (
        <div className="fixed inset-0 z-[70] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-fade-in" onClick={() => setSelectedDetailCard(null)}>
          <div className="bg-[#1e1b4b] border-2 border-yellow-500/30 p-8 rounded-2xl max-w-md w-full shadow-[0_0_50px_rgba(251,191,36,0.2)] relative overflow-hidden" onClick={e => e.stopPropagation()}>
            <button onClick={() => setSelectedDetailCard(null)} className="absolute top-4 right-4 text-slate-400 hover:text-white"><ArrowLeft size={24} /></button>
            <div className="flex flex-col items-center text-center">
              <div className="w-20 h-20 rounded-full bg-yellow-500/20 flex items-center justify-center mb-6 border border-yellow-500/50 shadow-[0_0_30px_rgba(251,191,36,0.3)]">
                <Star size={40} className="text-yellow-400 fill-yellow-400" />
              </div>
              <h3 className="text-2xl font-bold text-white mb-2 font-serif tracking-wider">{selectedDetailCard.name}</h3>
              <p className="text-slate-200 text-lg leading-relaxed mb-8 font-medium">{selectedDetailCard.description}</p>
              {selections[activeTimeframe].includes(selectedDetailCard.id) ? (
                <button onClick={() => toggleSelection(selectedDetailCard.id)} className="w-full py-3 rounded-xl border border-red-500/50 text-red-300 hover:bg-red-500/10 transition-colors">星を空から外す</button>
              ) : (
                <button onClick={() => toggleSelection(selectedDetailCard.id)} className="w-full bg-gradient-to-r from-yellow-500 to-amber-600 text-white font-bold py-4 rounded-xl hover:brightness-110 shadow-lg flex justify-center items-center gap-2">この価値観を星として登録する <Star size={18} fill="currentColor" /></button>
              )}
            </div>
          </div>
        </div>
      )}

      {/* 振り返り入力モーダル */}
      {viewMode === 'reflection_input' && (
        <div className="fixed inset-0 z-[60] flex items-center justify-center p-4 bg-black/60 backdrop-blur-md animate-fade-in">
          <div className="bg-[#1e1b4b]/95 border border-white/20 p-8 rounded-3xl max-w-lg w-full shadow-2xl relative overflow-hidden">
            <button onClick={() => setViewMode('workshop')} className="absolute top-6 right-6 text-slate-400 hover:text-white"><ArrowLeft size={24} /></button>
            <h3 className="text-2xl font-bold text-yellow-100 mb-2 font-serif flex items-center gap-3"><span>✒️</span> 航海日誌</h3>
            
            <p className="text-slate-300 text-sm mb-6 opacity-80 whitespace-pre-wrap">
              {getReflectionMessage()}
            </p>
            <p className="text-yellow-500/70 text-xs mb-4">※ 選んだ星も一緒に記録されます</p>
            
            <div className="text-xs text-slate-500 mb-2 text-right">Date: {new Date().toLocaleDateString()}</div>

            <textarea
              className="w-full h-40 bg-[#020617]/50 border border-white/10 rounded-xl p-5 text-slate-200 focus:ring-2 focus:ring-yellow-500/50 outline-none resize-none"
              placeholder="ここに想いを書き留めてください..."
              value={reflectionText}
              onChange={(e) => setReflectionText(e.target.value)}
            />

            {/* リセットオプション */}
            <div className="mt-4 flex items-center gap-2 cursor-pointer" onClick={() => setShouldReset(!shouldReset)}>
              <div className={`w-5 h-5 rounded border border-slate-500 flex items-center justify-center ${shouldReset ? 'bg-yellow-500 border-yellow-500' : ''}`}>
                {shouldReset && <Check size={14} className="text-black" />}
              </div>
              <span className="text-sm text-slate-300 select-none">
                記録後に星空をリセットする（新しい星を探す）
              </span>
            </div>

            <button onClick={handleCompleteReflection} disabled={isSaving} className="w-full mt-6 bg-gradient-to-r from-yellow-500 to-amber-600 text-white font-bold py-4 rounded-xl hover:brightness-110 shadow-lg flex justify-center items-center gap-2">
              {isSaving ? '記録中...' : '記録を保存する'} <Send size={18} />
            </button>
          </div>
        </div>
      )}

    </div>
  );
};

export default StarryWorkshop;