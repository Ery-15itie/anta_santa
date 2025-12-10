import React, { useEffect, useState, useRef, useLayoutEffect, useMemo } from 'react';
import { fetchValueCategories, fetchUserSelections, createSelection, deleteSelection, uploadOgpImage } from '../../api/values';
import PuzzlePiece from './PuzzlePiece';
import {
  Star, Send, Clock, MapPin, Compass,
  ArrowLeft, Check, AlertCircle, Share2, Download, X, Loader, Sparkles
} from 'lucide-react';
import html2canvas from 'html2canvas';

// --- カスタム通知 ---
const Toast = ({ message, type = 'success' }) => {
  const baseClass = "fixed top-4 sm:top-10 left-1/2 -translate-x-1/2 z-[100] px-4 py-3 sm:px-6 sm:py-4 rounded-lg shadow-2xl flex items-center gap-3 animate-fade-in-down border w-[90%] sm:w-auto justify-center";
  const colorClass = type === 'error' ? "bg-red-50 text-red-800 border-red-200" : "bg-white text-[#5d4037] border-[#d7ccc8]";
  const iconBgClass = type === 'error' ? "bg-red-100 text-red-600" : "bg-green-100 text-green-600";
  return (
    <div className={`${baseClass} ${colorClass}`}>
      <div className={`p-1 rounded-full ${iconBgClass} shrink-0`}>{type === 'error' ? <AlertCircle size={16} /> : <Check size={16} />}</div>
      <span className="font-bold text-sm sm:text-base">{message}</span>
    </div>
  );
};

// --- タイムタブ ---
const TimeTab = ({ id, label, icon: Icon, activeTimeframe, onClick }) => (
  <button
    onClick={() => onClick(id)}
    className={`flex items-center gap-1 sm:gap-2 px-3 py-1.5 sm:px-4 sm:py-2 rounded-full transition-all duration-300 border backdrop-blur-md text-xs sm:text-sm ${
      activeTimeframe === id 
        ? 'bg-yellow-500/90 text-white border-yellow-400 shadow-[0_0_15px_rgba(234,179,8,0.5)] scale-105' 
        : 'bg-white/5 text-slate-300 border-white/10 hover:bg-white/10 hover:border-white/30'
    }`}
  >
    <Icon size={14} className="sm:w-4 sm:h-4" />
    <span className="font-bold">{label}</span>
  </button>
);

// --- 背景コンポーネント ---
const StarryBackground = React.memo(() => {
  const toys = ['🎁', '🧸', '🚂', '🤖', '🧩', '🥁', '🎺', '🎨', '🚀', '🏰', '🎠', '🎮'];

  const starsData = useMemo(() => {
    return [...Array(50)].map(() => ({
      top: Math.random() * 100,
      left: Math.random() * 100,
      duration: Math.random() * 60 + 60,
      delay: Math.random() * 60,
      scale: Math.random() * 0.6 + 0.4
    }));
  }, []);

  const toyData = useMemo(() => {
    return [...Array(40)].map(() => ({
      char: toys[Math.floor(Math.random() * toys.length)],
      top: Math.random() * 90,
      fontSize: Math.random() * 1.5 + 1.5,
      duration: Math.random() * 40 + 40, 
      delay: -(Math.random() * 100)
    }));
  }, []);

  return (
    <div className="fixed inset-0 pointer-events-none z-0 select-none overflow-hidden">
      <style>{`
        @keyframes drift-across {
          from { transform: translateX(-10vw) rotate(0deg); }
          to   { transform: translateX(110vw) rotate(10deg); }
        }
        @keyframes twinkle-super-slow {
          0%, 100% { opacity: 0.2; transform: scale(1); }
          50% { opacity: 0.7; transform: scale(1.1); }
        }
      `}</style>

      {starsData.map((data, i) => (
        <div 
          key={`star-${i}`} 
          className="absolute text-yellow-100"
          style={{
            top: `${data.top}%`,
            left: `${data.left}%`,
            transform: `scale(${data.scale})`,
            animation: `twinkle-super-slow ${data.duration}s ease-in-out infinite`,
            animationDelay: `-${data.delay}s`
          }}
        >
          <Star size={Math.random() > 0.8 ? 6 : 3} fill="currentColor" />
        </div>
      ))}

      <div className="hidden md:block">
        <div 
          className="absolute top-1/2 left-0 text-7xl filter grayscale brightness-50 contrast-50 blur-[1px] opacity-20"
          style={{ 
            animation: 'drift-across 800s linear infinite', 
            animationDelay: '-400s' 
          }}
        >
          🛷💨
        </div>
        {toyData.map((data, i) => (
          <div
            key={`toy-${i}`}
            className="absolute filter grayscale brightness-75 contrast-50 blur-[0.5px] drop-shadow-sm opacity-10"
            style={{
              top: `${data.top}%`,
              left: '0', 
              fontSize: `${data.fontSize}rem`,
              animation: `drift-across ${data.duration}s linear infinite`,
              animationDelay: `${data.delay}s`
            }}
          >
            {data.char}
          </div>
        ))}
      </div>
    </div>
  );
});

// --- メインコンポーネント ---
const StarryWorkshop = ({ onBack }) => {
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selections, setSelections] = useState({ past: [], current: [], future: [] });
  const [activeTimeframe, setActiveTimeframe] = useState('current');
  const [isSaving, setIsSaving] = useState(false);
  const [toast, setToast] = useState(null);
  const [viewMode, setViewMode] = useState('workshop');
  const [reflectionText, setReflectionText] = useState("");
  const [selectedDetailCard, setSelectedDetailCard] = useState(null);
  const [shouldReset, setShouldReset] = useState(true);

  const [shareModalOpen, setShareModalOpen] = useState(false);
  const [generatedImage, setGeneratedImage] = useState(null);
  const [isUploading, setIsUploading] = useState(false);
  const [isGeneratingImage, setIsGeneratingImage] = useState(false);
  const shareRef = useRef(null);

  const cardRefs = useRef({});
  const [pcLines, setPcLines] = useState([]); 
  const [trainPath, setTrainPath] = useState(""); 
  const [pathLength, setPathLength] = useState(0);

  useEffect(() => {
    const loadData = async () => {
      try {
        const [catRes, selRes] = await Promise.all([fetchValueCategories(), fetchUserSelections()]);
        if (catRes.data) setCategories(catRes.data);
        const newSelections = { past: [], current: [], future: [] };
        if (selRes.data) {
          selRes.data.forEach(s => {
            if (newSelections[s.timeframe]) newSelections[s.timeframe].push(s.value_card_id);
          });
        }
        setSelections(newSelections);
      } catch (error) { console.error(error); } finally { setLoading(false); }
    };
    loadData();
  }, []);

  const showToast = (msg, type = 'success') => {
    setToast({ message: msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const handleCardClick = (card) => { if (viewMode === 'workshop') setSelectedDetailCard(card); };

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
        showToast("選べる星は10個までです ⭐", 'error');
        return;
      }
    }
    setSelections(prev => ({ ...prev, [activeTimeframe]: newList }));
    setSelectedDetailCard(null);
  };

  useLayoutEffect(() => {
    if (viewMode !== 'workshop') return;
    const calculateVisuals = () => {
      const currentIds = selections[activeTimeframe];
      const isMobile = window.innerWidth < 768; 

      const points = currentIds.map(id => {
        const el = cardRefs.current[id];
        if (el && el.offsetParent !== null) {
          const rect = el.getBoundingClientRect();
          return { x: rect.left + rect.width / 2, y: rect.top + rect.height / 2 };
        }
        return null;
      }).filter(Boolean);

      if (points.length === 0) {
        setPcLines([]);
        setTrainPath("");
        return;
      }

      if (isMobile) {
        let d = `M ${points[0].x} ${points[0].y}`;
        if (points.length === 1) {
          d += ` L ${points[0].x + 0.1} ${points[0].y} Z`;
        } else {
          for (let i = 1; i < points.length; i++) {
            d += ` L ${points[i].x} ${points[i].y}`;
          }
          d += ` Z`;
        }
        setTrainPath(d);
        setPathLength(points.length);
        setPcLines([]);
      } else {
        const lines = [];
        for (let i = 0; i < points.length - 1; i++) {
          lines.push({ x1: points[i].x, y1: points[i].y, x2: points[i+1].x, y2: points[i+1].y });
        }
        setPcLines(lines);
        setTrainPath("");
      }
    };

    calculateVisuals();
    window.addEventListener('resize', calculateVisuals);
    window.addEventListener('scroll', calculateVisuals, true);
    
    let animationFrameId;
    const loop = () => { calculateVisuals(); animationFrameId = requestAnimationFrame(loop); };
    loop();

    return () => {
      window.removeEventListener('resize', calculateVisuals);
      window.removeEventListener('scroll', calculateVisuals, true);
      cancelAnimationFrame(animationFrameId);
    };
  }, [selections, activeTimeframe, loading, viewMode]);

  const handleTabChange = (id) => {
    setActiveTimeframe(id);
    setViewMode('workshop');
  };

  const handleShareOpen = async () => {
    setShareModalOpen(true); setGeneratedImage(null); setIsGeneratingImage(true);
    setTimeout(async () => {
      if (shareRef.current) {
        try {
          const canvas = await html2canvas(shareRef.current, { backgroundColor: '#0f172a', scale: 2, useCORS: true, logging: false });
          setGeneratedImage(canvas.toDataURL('image/png'));
        } catch (e) { showToast("生成失敗", 'error'); } finally { setIsGeneratingImage(false); }
      }
    }, 500);
  };
  const handleTweet = async () => {
    if (!generatedImage) return; setIsUploading(true);
    try {
      const res = await uploadOgpImage(generatedImage);
      if (!res.data || !res.data.url) throw new Error("URL error");
      const shareUrl = res.data.url;
      const timeframeLabel = activeTimeframe === 'past' ? '過去' : activeTimeframe === 'future' ? '未来' : '現在';
      const text = `【${timeframeLabel}の価値観】私の大切な価値観の星々✨\n\n#サンタの書斎 #AntaSanta #価値観パズル`;
      const tweetUrl = `https://x.com/intent/tweet?text=${encodeURIComponent(text)}&url=${encodeURIComponent(shareUrl)}`;
      window.open(tweetUrl, '_blank', 'noopener,noreferrer');
      setShareModalOpen(false);
    } catch (error) { showToast("シェア失敗", 'error'); } finally { setIsUploading(false); }
  };
  const handleDownloadImage = () => {
    if (!generatedImage) return;
    const link = document.createElement('a'); link.href = generatedImage; link.download = `santas-study-values-${activeTimeframe}.png`; link.click(); showToast("保存しました", 'success');
  };
  const handleConfirm = () => setViewMode('reflection_input');
  const handleCompleteReflection = async () => {
    setIsSaving(true);
    const currentList = selections[activeTimeframe];
    const selectedCardNames = currentList.map(id => {
      const c = categories.flatMap(cat => cat.value_cards).find(card => card.id === id);
      return c ? c.name : '';
    }).filter(Boolean).join(', ');
    const timestamp = new Date().toLocaleString('ja-JP', { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' });
    const finalNote = `【${timestamp}の記録】\n⭐ 選んだ星: ${selectedCardNames}\n\n${reflectionText}`;
    try {
      if (currentList.length > 0) {
        const lastCardId = currentList[currentList.length - 1];
        await createSelection({ value_card_id: lastCardId, timeframe: activeTimeframe, description: finalNote });
      }
      showToast("航海日誌に記録しました ✒️");
      if (shouldReset) setSelections(prev => ({ ...prev, [activeTimeframe]: [] }));
      setViewMode('workshop'); setReflectionText("");
    } catch (e) { showToast("保存失敗", 'error'); } finally { setIsSaving(false); }
  };
  const getReflectionMessage = () => {
    switch(activeTimeframe) {
      case 'past': return "あの頃、この価値観があなたをどう支えていましたか？";
      case 'current': return "今、これらの価値観を選んだ理由は何ですか？";
      case 'future': return "この価値観を大切にして、どんな未来を描きますか？";
      default: return "今の気持ちを書き留めましょう。";
    }
  };

  return (
    <div className="min-h-screen bg-[radial-gradient(ellipse_at_bottom,_var(--tw-gradient-stops))] from-[#1e1b4b] via-[#0f172a] to-[#020617] text-white font-sans fixed inset-0 z-50 overflow-y-auto overflow-x-hidden">
      {toast && <Toast message={toast.message} type={toast.type} />}

      <StarryBackground />

      <svg className="fixed inset-0 pointer-events-none z-30" style={{ width: '100%', height: '100%' }}>
        <defs>
          <filter id="glow">
            <feGaussianBlur stdDeviation="2" result="coloredBlur"/>
            <feMerge><feMergeNode in="coloredBlur"/><feMergeNode in="SourceGraphic"/></feMerge>
          </filter>
        </defs>
        {pcLines.map((line, i) => (
          <line
            key={`line-${i}`} x1={line.x1} y1={line.y1} x2={line.x2} y2={line.y2}
            stroke="#fcd34d" strokeWidth="2" strokeDasharray="4, 4" strokeOpacity="0.6" filter="url(#glow)"
            className="hidden md:block"
          />
        ))}
        {trainPath && (
          <g className="md:hidden">
            <path id="trainTrack" d={trainPath} fill="none" stroke="none" />
            <text fontSize="24" dy="5">
              <animateMotion dur="40s" repeatCount="indefinite" rotate="auto">
                <mpath href="#trainTrack" />
              </animateMotion>
              🚂
            </text>
            <circle r="4" fill="#fbbf24" filter="blur(2px)">
               <animateMotion dur="40s" repeatCount="indefinite" rotate="auto" begin="0.1s">
                <mpath href="#trainTrack" />
              </animateMotion>
              <style>{`@keyframes pulse-smoke { 0% { opacity: 0.6; } 50% { opacity: 0.8; } 100% { opacity: 0.6; } }`}</style>
              <animate attributeName="opacity" values="0.6;0.8;0.6" dur="2s" repeatCount="indefinite" />
            </circle>
          </g>
        )}
      </svg>

      <header className="fixed top-0 left-0 right-0 z-50 px-4 py-3 sm:px-6 sm:py-4 bg-[#0f172a]/80 backdrop-blur-xl border-b border-white/10 shadow-2xl">
        <div className="flex justify-between items-center mb-3 sm:mb-4 max-w-7xl mx-auto w-full">
          <h1 className="hidden md:flex text-xl font-bold text-yellow-100 items-center gap-3 font-serif tracking-wider">
            <span className="text-3xl filter drop-shadow-[0_0_10px_rgba(253,224,71,0.5)]">📖</span>
            サンタの書斎
          </h1>
          <h1 className="flex md:hidden text-lg font-bold text-yellow-100 items-center gap-2 font-serif tracking-wider">
             <span className="text-2xl">🌌</span> サンタの書斎
          </h1>
          <button onClick={onBack} className="text-sm bg-white/5 hover:bg-white/10 px-3 py-1.5 sm:px-5 sm:py-2.5 rounded-full border border-white/10 flex items-center gap-2 transition-all">
            <span>🏠</span> <span className="hidden sm:inline">部屋に戻る</span>
          </button>
        </div>
        <div className="flex justify-center gap-3 sm:gap-6">
          <TimeTab id="past" label="過去" icon={Clock} activeTimeframe={activeTimeframe} onClick={handleTabChange} />
          <TimeTab id="current" label="現在" icon={MapPin} activeTimeframe={activeTimeframe} onClick={handleTabChange} />
          <TimeTab id="future" label="未来" icon={Compass} activeTimeframe={activeTimeframe} onClick={handleTabChange} />
        </div>
      </header>

      <main className="container mx-auto px-4 pt-36 sm:pt-48 pb-32 sm:pb-40 relative z-10 max-w-7xl">
        <div className="md:hidden text-center mb-6 animate-fade-in-down">
          <h2 className="text-xl font-bold text-yellow-100 font-serif mb-1 drop-shadow-lg">ようこそ、銀河の旅へ！</h2>
          <p className="text-xs text-slate-300 opacity-90">車窓に流れる星々から、あなたの大切な価値観を見つけてください</p>
        </div>

        {loading ? (
          <div className="text-center mt-32 text-yellow-100 animate-pulse">星々を集めています...</div>
        ) : (
          <div className={`grid grid-cols-1 md:grid-cols-2 gap-6 md:gap-16 transition-all duration-700 ${
            viewMode !== 'workshop' ? 'opacity-20 blur-sm pointer-events-none' : 'opacity-100'
          }`}>
            {categories.map((category, index) => (
              <div
                key={category.id}
                className={`relative transition-all duration-500 hover:scale-[1.01] md:hover:scale-[1.02] 
                  ${/* スマホ */ 'p-5 rounded-2xl border border-white/10 bg-white/5 backdrop-blur-md'}
                  ${/* PC */ 'md:p-8 md:bg-transparent md:border-none md:shadow-none'}
                `}
                style={ window.innerWidth >= 768 ? {
                  background: `linear-gradient(135deg, ${category.theme_color}15 0%, ${category.theme_color}05 100%)`,
                  backdropFilter: 'blur(12px)',
                  boxShadow: `inset 0 0 40px ${category.theme_color}20, 0 10px 30px rgba(0,0,0,0.3)`,
                  border: `1px solid ${category.theme_color}30`,
                  borderRadius: index % 2 === 0 ? '60% 40% 70% 30% / 60% 30% 70% 40%' : '40% 60% 30% 70% / 50% 60% 30% 60%',
                } : {}}
              >
                <div className={`
                  flex items-center gap-3 z-20 
                  ${/* スマホ */ 'mb-4 border-b border-white/10 pb-2'}
                  ${/* PC */ 'md:absolute md:-top-4 md:left-1/2 md:-translate-x-1/2 md:bg-[#0f172a] md:px-5 md:py-2 md:rounded-full md:border md:border-white/20 md:shadow-xl md:mb-0 md:border-b-0 md:pb-0'}
                `}>
                  <div className="w-8 h-8 md:w-3 md:h-3 rounded-full flex items-center justify-center shadow-[0_0_10px]" 
                    style={{ backgroundColor: category.theme_color, boxShadow: `0 0 10px ${category.theme_color}` }}>
                      <span className="md:hidden text-xs">🪐</span>
                  </div>
                  <h2 className="text-lg font-bold text-slate-200 font-serif tracking-wider whitespace-nowrap">
                    {category.name}
                  </h2>
                </div>

                <div className="flex flex-wrap justify-center items-center gap-3 md:gap-6 mt-0 md:mt-6 min-h-[100px] md:min-h-[140px] px-1 md:px-4">
                  {category.value_cards.map((card, i) => {
                    const isSelected = selections[activeTimeframe].includes(card.id);
                    const stationIndex = selections[activeTimeframe].indexOf(card.id) + 1;
                    
                    return (
                      <div 
                        key={card.id} 
                        className="animate-float-random" 
                        style={{ animationDelay: `${i * 0.5}s` }}
                      >
                         <div className="hidden md:block">
                           <PuzzlePiece
                             ref={el => cardRefs.current[card.id] = el}
                             card={card}
                             color={category.theme_color}
                             isSelected={isSelected}
                             onClick={() => handleCardClick(card)}
                           />
                         </div>

                         <button
                           ref={el => { if(window.innerWidth < 768) cardRefs.current[card.id] = el }}
                           onClick={() => handleCardClick(card)}
                           className={`md:hidden relative flex flex-col items-center justify-center w-20 h-20 rounded-full transition-all duration-300
                             ${isSelected 
                                ? 'bg-yellow-400/20 border-2 border-yellow-400 text-yellow-100 animate-pulse-glow scale-110 z-10 shadow-[0_0_15px_rgba(250,204,21,0.5)]' 
                                : 'bg-white/5 border border-white/10 text-slate-400 hover:bg-white/10 hover:border-white/30'
                             }
                           `}
                         >
                            <Star size={isSelected ? 24 : 18} fill={isSelected ? "currentColor" : "none"} className={`mb-1 transition-all ${isSelected ? 'text-yellow-300' : 'text-slate-500'}`} />
                            <span className="text-[10px] font-bold text-center leading-tight px-1">{card.name}</span>
                            {isSelected && (
                              <span className="absolute -top-2 -right-1 w-5 h-5 bg-indigo-600 text-white text-[10px] font-bold flex items-center justify-center rounded-full border border-indigo-400 shadow-lg">
                                {stationIndex}
                              </span>
                            )}
                         </button>

                      </div>
                    );
                  })}
                </div>
              </div>
            ))}
          </div>
        )}
      </main>

      {/* フッター (★修正点: pb-8 で下部余白確保、px-4で横余白確保) */}
      {viewMode === 'workshop' && (
        <div className="fixed bottom-0 left-0 right-0 px-4 py-3 pb-8 sm:p-4 bg-[#0f172a]/90 border-t border-white/10 backdrop-blur-xl z-50">
          <div className="container mx-auto flex justify-between items-center max-w-4xl">
            <div className="text-sm text-slate-300 flex items-center gap-2">
              <Star size={20} className={selections[activeTimeframe].length === 10 ? 'text-green-400' : 'text-yellow-400'} fill="currentColor"/>
              <div className="flex flex-col leading-tight sm:flex-row sm:items-baseline sm:gap-1">
                <span className="text-[10px] sm:text-sm text-slate-400">Stars:</span>
                <span className={`text-xl sm:text-2xl font-bold ${selections[activeTimeframe].length === 10 ? 'text-green-400' : 'text-yellow-400'}`}>
                  {selections[activeTimeframe].length}
                </span>
                <span className="text-slate-600 text-sm sm:text-lg">/ 10</span>
              </div>
            </div>
           
            <div className="flex gap-3 items-center">
              <button
                onClick={handleShareOpen}
                disabled={selections[activeTimeframe].length === 0}
                className={`px-3 py-2 sm:px-4 rounded-full border border-white/10 text-slate-300 flex items-center gap-2 transition-all ${selections[activeTimeframe].length > 0 ? 'hover:bg-black/50 hover:text-white' : 'opacity-50'}`}
              >
                <Share2 size={18} /> <span className="hidden sm:inline">シェア</span>
              </button>

              <button
                onClick={handleConfirm}
                disabled={selections[activeTimeframe].length === 0}
                className={`px-6 py-3 rounded-full font-bold shadow-2xl transition-all flex items-center gap-2 ${
                  selections[activeTimeframe].length > 0 
                    ? 'bg-gradient-to-r from-yellow-500 to-amber-600 text-white hover:scale-105' 
                    : 'bg-white/5 text-slate-600 cursor-not-allowed'
                }`}
              >
                <span className="text-sm sm:text-base">決定</span> <Send size={18} />
              </button>
            </div>
          </div>
        </div>
      )}

      {selectedDetailCard && (
        <div 
          className="fixed inset-0 z-[70] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-fade-in" 
          onClick={() => setSelectedDetailCard(null)}
        >
          <div className="bg-[#1e1b4b] border-2 border-yellow-500/30 p-6 sm:p-8 rounded-2xl max-w-md w-full shadow-[0_0_50px_rgba(251,191,36,0.2)] relative overflow-hidden" onClick={e => e.stopPropagation()}>
            <button onClick={() => setSelectedDetailCard(null)} className="absolute top-4 right-4 text-slate-400 hover:text-white"><X size={24} /></button>
            <div className="flex flex-col items-center text-center">
              <div className="w-16 h-16 sm:w-20 sm:h-20 rounded-full bg-yellow-500/20 flex items-center justify-center mb-6 border border-yellow-500/50 shadow-[0_0_30px_rgba(251,191,36,0.3)]">
                <Star size={32} className="text-yellow-400 fill-yellow-400" />
              </div>
              <h3 className="text-xl sm:text-2xl font-bold text-white mb-2 font-serif">{selectedDetailCard.name}</h3>
              <p className="text-slate-200 text-sm sm:text-lg leading-relaxed mb-8 font-medium">{selectedDetailCard.description}</p>
              {selections[activeTimeframe].includes(selectedDetailCard.id) ? (
                <button onClick={() => toggleSelection(selectedDetailCard.id)} className="w-full py-3 rounded-xl border border-red-500/50 text-red-300 hover:bg-red-500/10 transition-colors">星を外す</button>
              ) : (
                <button onClick={() => toggleSelection(selectedDetailCard.id)} className="w-full bg-gradient-to-r from-yellow-500 to-amber-600 text-white font-bold py-3 sm:py-4 rounded-xl hover:brightness-110 shadow-lg flex justify-center items-center gap-2">
                   星を選択する <Sparkles size={18} />
                </button>
              )}
            </div>
          </div>
        </div>
      )}

      {viewMode === 'reflection_input' && (
        <div className="fixed inset-0 z-[60] flex items-center justify-center p-4 bg-black/60 backdrop-blur-md animate-fade-in">
          <div className="bg-[#1e1b4b]/95 border border-white/20 p-6 sm:p-8 rounded-3xl max-w-lg w-full shadow-2xl relative">
            <button onClick={() => setViewMode('workshop')} className="absolute top-6 right-6 text-slate-400 hover:text-white"><ArrowLeft size={24} /></button>
            <h3 className="text-xl sm:text-2xl font-bold text-yellow-100 mb-2 font-serif flex items-center gap-3"><span>✒️</span> 航海日誌</h3>
            <p className="text-slate-300 text-xs sm:text-sm mb-6 opacity-80 whitespace-pre-wrap">{getReflectionMessage()}</p>
            <textarea
              className="w-full h-32 sm:h-40 bg-[#020617]/50 border border-white/10 rounded-xl p-5 text-slate-200 focus:ring-2 focus:ring-yellow-500/50 outline-none resize-none"
              placeholder="ここに想いを書き留めてください..."
              value={reflectionText}
              onChange={(e) => setReflectionText(e.target.value)}
            />
            <div className="mt-4 flex items-center gap-2 cursor-pointer" onClick={() => setShouldReset(!shouldReset)}>
              <div className={`w-5 h-5 rounded border border-slate-500 flex items-center justify-center ${shouldReset ? 'bg-yellow-500 border-yellow-500' : ''}`}>{shouldReset && <Check size={14} className="text-black" />}</div>
              <span className="text-xs sm:text-sm text-slate-300 select-none">記録後に星空をリセットする</span>
            </div>
            <button onClick={handleCompleteReflection} disabled={isSaving} className="w-full mt-6 bg-gradient-to-r from-yellow-500 to-amber-600 text-white font-bold py-3 sm:py-4 rounded-xl hover:brightness-110 shadow-lg flex justify-center items-center gap-2 disabled:opacity-50">
              {isSaving ? '記録中...' : '記録を保存する'} <Send size={18} />
            </button>
          </div>
        </div>
      )}

      {shareModalOpen && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/90 backdrop-blur-md animate-fade-in overflow-y-auto">
          <div className="flex flex-col items-center gap-6 max-w-4xl w-full my-auto">
            <div className="flex justify-between items-center w-full text-white">
              <h3 className="text-xl font-bold flex items-center gap-2"><Share2 className="text-yellow-400" /> シェア</h3>
              <button onClick={() => { setShareModalOpen(false); setGeneratedImage(null); }} className="p-2 hover:bg-white/10 rounded-full"><X /></button>
            </div>
            <div className="relative w-full flex justify-center items-center bg-[#0f172a] rounded-xl overflow-hidden border border-white/10 shadow-2xl p-4 min-h-[300px]">
              {isGeneratingImage && <div className="absolute inset-0 flex flex-col items-center justify-center bg-[#0f172a] z-20 text-yellow-100"><Loader className="animate-spin mb-4"/><p>星空を撮影しています...</p></div>}
              {generatedImage && !isGeneratingImage && <img src={generatedImage} alt="Share" className="max-w-full h-auto rounded-lg shadow-lg max-h-[60vh] object-contain" />}
              <div ref={shareRef} className="absolute top-0 left-0 pointer-events-none" style={{ width: '1200px', height: '630px', background: 'linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #312e81 100%)', opacity: generatedImage ? 0 : 1, zIndex: generatedImage ? -1 : 10 }}>
                <div className="w-full h-full relative flex flex-col items-center justify-center p-16 text-white font-sans">
                  <div className="absolute top-0 left-0 w-full h-full opacity-30" style={{ backgroundImage: 'radial-gradient(circle at 50% 50%, rgba(255,255,255,0.1) 1px, transparent 1px)', backgroundSize: '40px 40px' }}></div>
                  <h1 className="text-5xl font-bold text-yellow-100 mb-4 font-serif drop-shadow-lg z-10">私の選んだ価値観の星たち</h1>
                  <p className="text-2xl text-slate-300 mb-12 tracking-widest uppercase opacity-80 z-10">Santa's Study - {activeTimeframe.toUpperCase()}</p>
                  <div className="flex flex-wrap justify-center gap-4 max-w-4xl z-10">
                    {selections[activeTimeframe].map(id => {
                      const card = categories.flatMap(c => c.value_cards).find(c => c.id === id);
                      return card ? (
                        <div key={id} className="flex items-center gap-2 px-6 py-3 bg-white/10 rounded-full border border-white/20 shadow-lg backdrop-blur-md">
                          <Star size={24} className="text-yellow-400 fill-yellow-400" />
                          <span className="text-2xl font-bold text-white">{card.name}</span>
                        </div>
                      ) : null;
                    })}
                  </div>
                  <div className="absolute bottom-8 right-12 flex items-center gap-3 opacity-70 z-10">
                    <span className="text-xl font-bold">Anta-Santa</span>
                    <span className="text-lg">{new Date().toLocaleDateString('ja-JP')}</span>
                  </div>
                </div>
              </div>
            </div>
            {generatedImage && !isGeneratingImage && (
              <div className="flex gap-4 w-full justify-center">
                <button onClick={handleDownloadImage} className="flex items-center gap-2 bg-white text-[#0f172a] px-6 py-3 rounded-full font-bold hover:bg-slate-200 transition shadow-lg"><Download size={20} /> 保存</button>
                <button onClick={handleTweet} disabled={isUploading} className="flex items-center gap-2 bg-black text-white px-6 py-3 rounded-full font-bold hover:bg-gray-800 transition shadow-lg border border-white/20">{isUploading ? <Loader className="animate-spin" size={20}/> : <Share2 size={20}/>} ポスト</button>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
};

export default StarryWorkshop;