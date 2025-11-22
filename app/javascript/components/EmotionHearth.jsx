import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ArrowLeft, Sparkles, History, LogOut, Flame } from 'lucide-react';

// 感情データ
const EMOTIONS = [
  { id: 'joy', label: '😊 嬉しい', color: '#fbbf24', type: 'positive' },
  { id: 'calm', label: '😌 穏やか', color: '#4ade80', type: 'positive' },
  { id: 'love', label: '🥰 愛おしい', color: '#f472b6', type: 'positive' },
  { id: 'excited', label: '✨ ワクワク', color: '#fb923c', type: 'positive' },
  { id: 'normal', label: '😐 普通', color: '#e5e7eb', type: 'neutral' },
  { id: 'thinking', label: '🤔 考え中', color: '#67e8f9', type: 'neutral' },
  { id: 'surprise', label: '😮 驚き', color: '#c084fc', type: 'neutral' },
  { id: 'sadness', label: '😔 悲しい', color: '#60a5fa', type: 'negative' },
  { id: 'anxiety', label: '😰 不安', color: '#818cf8', type: 'negative' },
  { id: 'anger', label: '😤 怒り', color: '#ef4444', type: 'negative' },
  { id: 'empty', label: '😞 虚しい', color: '#9ca3af', type: 'negative' },
];

const MAGIC_POWDERS = [
  { id: 'copper', label: '銅の粉 (青緑)', desc: '冷静さに変える', color: '#2dd4bf' },
  { id: 'lithium', label: 'リチウム (赤)', desc: '情熱に変える', color: '#db2777' },
  { id: 'sodium', label: 'ナトリウム (黄)', desc: '明るさに変える', color: '#facc15' },
  { id: 'barium', label: 'バリウム (緑)', desc: '成長に変える', color: '#65a30d' },
];

// 共通パーツ：吊り看板ボタン
const HangingSign = ({ onClick, icon: Icon, label, color = "text-[#ffecb3]" }) => (
  <div className="relative group cursor-pointer z-50" onClick={onClick}>
    <div className="absolute -top-8 left-1/2 -translate-x-1/2 w-1 h-12 bg-[#3e2723] shadow-sm"></div>
    <div className={`relative mt-2 bg-[#5d4037] border-4 border-[#3e2723] px-3 py-2 rounded-sm shadow-[0_4px_6px_rgba(0,0,0,0.5)] flex items-center gap-2 transform transition-transform hover:rotate-2 origin-top ${color}`}>
       <Icon size={16} />
       <span className="font-black text-xs tracking-widest font-serif uppercase">{label}</span>
       <div className="absolute -top-1.5 left-1/2 -translate-x-1/2 w-2 h-2 bg-[#271c19] rounded-full opacity-80"></div>
    </div>
  </div>
);

// 感情ボタン
const EmotionButton = ({ emo, selectedEmotion, setSelectedEmotion }) => (
  <button
    onClick={() => setSelectedEmotion(emo)}
    className={`px-3 py-2 rounded-lg text-xs sm:text-sm font-bold transition-all border-b-4 active:border-b-0 active:translate-y-1 flex-grow sm:flex-grow-0 text-center
      ${selectedEmotion?.id === emo.id 
        ? 'bg-[#5d4037] border-[#3e2723] text-[#ffecb3] shadow-inner scale-105' 
        : 'bg-[#3e2723] border-[#2c1e1b] text-[#8d6e63] hover:bg-[#4e342e]'}`}
  >
    {emo.label}
  </button>
);

const EmotionHearth = ({ onBack, onOpenStats, onLogout }) => {
  const [fireState, setFireState] = useState({ size: 1.0, color: 'normal', temperature: 36 });
  const [logs, setLogs] = useState([]);
  const [selectedEmotion, setSelectedEmotion] = useState(null);
  const [note, setNote] = useState('');
  const [intensity, setIntensity] = useState(3);
  const [showPowderModal, setShowPowderModal] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [successMessage, setSuccessMessage] = useState(null);

  useEffect(() => {
    fetchFireState();
  }, []);

  const fetchFireState = async () => {
    try {
      const response = await fetch('/api/v1/emotion_logs');
      if (response.ok) {
        const data = await response.json();
        setFireState(data.fire_state);
        // 履歴を多めに取得して薪として表示
        setLogs(data.logs || []);
      }
    } catch (error) {
      console.error('Failed to fetch', error);
    }
  };

  const handleSubmit = async (powderId = 'no_powder') => {
    setIsSubmitting(true);
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
    try {
      const response = await fetch('/api/v1/emotion_logs', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': csrfToken },
        body: JSON.stringify({
          emotion_log: {
            emotion: selectedEmotion.id,
            body: note,
            intensity: intensity,
            magic_powder: powderId
          }
        }),
      });

      if (response.ok) {
        const data = await response.json();
        setFireState(data.fire_state);
        setLogs([data.log, ...logs]);
        setSelectedEmotion(null);
        setNote('');
        setIntensity(3);
        setShowPowderModal(false);
        setSuccessMessage("感情が炎に変わりました 🔥");
        setTimeout(() => setSuccessMessage(null), 3000);
      }
    } catch (error) {
      console.error('Error:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  const handlePreSubmit = () => {
    if (!selectedEmotion) return;
    if (selectedEmotion.type === 'negative') {
      setShowPowderModal(true);
    } else {
      handleSubmit('no_powder');
    }
  };

  const getFireColorCode = (colorKey) => {
    const powder = MAGIC_POWDERS.find(p => p.id === colorKey);
    if (powder) return powder.color;
    const emotion = EMOTIONS.find(e => e.id === colorKey);
    return emotion ? emotion.color : '#fb923c';
  };

  const groupedEmotions = {
    positive: EMOTIONS.filter(e => e.type === 'positive'),
    neutral: EMOTIONS.filter(e => e.type === 'neutral'),
    negative: EMOTIONS.filter(e => e.type === 'negative'),
  };

  const currentFireSize = Math.min(Math.max(fireState.size, 1.0), 3.0);

  return (
    <div className="min-h-screen bg-[#271c19] text-[#d7ccc8] font-sans relative overflow-hidden flex flex-col">
      
      {/* 背景 (暗い部屋) */}
      <div className="absolute inset-0 z-0 bg-[#1a100e]"></div>
      <div className="absolute inset-0 opacity-20 pointer-events-none" style={{ backgroundImage: 'url("https://www.transparenttextures.com/patterns/wood-pattern.png")' }}></div>

      {/* ヘッダー */}
      <div className="relative z-50 p-4 flex justify-between items-start">
        <HangingSign onClick={onBack} icon={ArrowLeft} label="Home" />
        
        <div className="mt-6 bg-[#3e2723] border-2 border-[#5d4037] px-4 py-1 rounded-full shadow-lg flex items-center gap-2">
            <div className={`w-2 h-2 rounded-full ${fireState.temperature > 50 ? 'bg-red-500 animate-pulse' : 'bg-orange-500'}`}></div>
            <span className="text-xs font-mono text-[#8d6e63]">TEMP:</span>
            <span className="text-sm font-bold text-[#ffcc80] font-mono">{Math.round(fireState.temperature)}°C</span>
        </div>

        <div className="flex gap-3">
            <HangingSign onClick={onOpenStats} icon={History} label="Log" color="text-[#ffcc80]" />
            <HangingSign onClick={onLogout} icon={LogOut} label="Exit" color="text-[#ff8a80]" />
        </div>
      </div>

      {/* ▼▼▼ 暖炉本体 (ピザ釜風デザイン) ▼▼▼ */}
      <div className="flex-grow relative flex flex-col items-center justify-end pb-32 z-10">
        
        {/* 煙突 */}
        <div className="absolute -top-10 w-48 h-[120%] bg-[#5d4037] z-0 border-x-4 border-[#3e2723]" 
             style={{backgroundImage: 'repeating-linear-gradient(0deg, transparent 0, transparent 19px, #3e2723 19px, #3e2723 20px)'}}>
        </div>

        {/* 暖炉の構造体 (上下2段) */}
        <div className="relative w-full max-w-3xl z-10 flex flex-col items-center">

           {/* 上段：燃焼室 (アーチ状のレンガ造り) */}
           <div className="w-[80%] aspect-[4/3] bg-[#6d4c41] rounded-t-[10rem] relative border-[20px] border-[#5d4037] shadow-2xl overflow-hidden flex items-end justify-center"
                style={{backgroundImage: 'repeating-linear-gradient(45deg, #6d4c41 0, #6d4c41 10px, #5d4037 10px, #5d4037 20px)'}}>
              
              {/* 炉内 (煤けた暗闇 + 奥行き) */}
              <div className="w-[80%] h-[80%] bg-[#1a0f0d] rounded-t-[8rem] relative overflow-hidden shadow-[inset_0_20px_80px_#000] border-4 border-[#3e2723]">
                  
                  {/* 🔥 炎のアニメーション 🔥 */}
                  <div className="absolute bottom-4 left-1/2 transform -translate-x-1/2 z-10">
                     {/* 1. グロー (部屋全体を照らす明かり) */}
                     <motion.div 
                       animate={{ opacity: [0.4, 0.6, 0.4], scale: [1, 1.1, 1] }} 
                       transition={{ duration: 3, repeat: Infinity }}
                       className="absolute bottom-0 left-1/2 -translate-x-1/2 w-[300px] h-[300px] rounded-full blur-[60px] -z-10"
                       style={{ backgroundColor: getFireColorCode(fireState.color) }}
                     />
                     {/* 2. メインの炎 (ゆらめく) */}
                     <motion.div
                       animate={{
                         scale: [currentFireSize, currentFireSize * 1.1, currentFireSize],
                         opacity: [0.8, 1, 0.8],
                       }}
                       transition={{ duration: 0.5, repeat: Infinity, ease: "easeInOut" }}
                       className="w-32 h-40 rounded-full blur-xl"
                       style={{ backgroundColor: getFireColorCode(fireState.color), mixBlendMode: 'screen' }}
                     />
                     {/* 3. 火の粉 (パーティクル) */}
                     {[...Array(8)].map((_, i) => (
                       <motion.div
                          key={i}
                          className="absolute bottom-0 left-1/2 rounded-full blur-[1px]"
                          style={{ backgroundColor: '#fff', width: Math.random() * 4 + 2, height: Math.random() * 4 + 2, x: '-50%' }}
                          animate={{ y: [-20, -150 - (currentFireSize * 50)], x: ['-50%', (Math.random() - 0.5) * 100], opacity: [1, 0], scale: [1, 0] }}
                          transition={{ duration: 1 + Math.random(), repeat: Infinity, delay: Math.random() * 2, ease: "easeOut" }}
                       />
                     ))}
                  </div>
                            {/* 燃えている薪 (シルエット) */}
                  <div className="absolute bottom-0 left-1/2 transform -translate-x-1/2 w-40 h-10 bg-[#2e1c18] rounded-t flex items-center justify-center shadow-lg">
                     {/* 燃え差し */}
                     <div className="w-full h-full bg-gradient-to-t from-black via-transparent to-transparent opacity-80"></div>
                  </div>
              </div>
           </div>

           {/* 仕切り (マントルピース) */}
           <div className="w-[90%] h-8 bg-[#4e342e] shadow-xl rounded border-y-4 border-[#3e2723] z-20 relative">
              <div className="absolute inset-0 bg-black opacity-20" style={{backgroundImage: 'repeating-linear-gradient(90deg, transparent 0, transparent 19px, rgba(0,0,0,0.5) 20px)'}}></div>
           </div>

           {/* 下段：薪置き場 (Wood Storage) */}
           <div className="w-[80%] h-40 bg-[#3e2723] border-x-[20px] border-b-[20px] border-[#5d4037] relative shadow-[inset_0_10px_30px_#000] flex items-end justify-center overflow-hidden px-2 pb-2">
              
              {/* 🪵 くべた薪の山 (リアルな薪が積み上がる) */}
              <div className="flex flex-wrap-reverse justify-center gap-y-1 gap-x-0.5 w-full max-h-full overflow-visible relative z-10">
                 {logs.slice(0, 25).map((log, i) => {
                    const emo = EMOTIONS.find(e => e.id === log.emotion);
                    const iconColor = (log.magic_powder && log.magic_powder !== 'no_powder') 
                       ? MAGIC_POWDERS.find(p=>p.id === log.magic_powder)?.color 
                       : emo?.color;

                    return (
                      <motion.div
                        key={log.id}
                        // 上から降ってくるようなアニメーション
                        initial={{ y: -100, opacity: 0, rotate: Math.random() * 180 }}
                        animate={{ y: 0, opacity: 1, rotate: (i % 2 === 0 ? 2 : -2) }}
                        transition={{ type: 'spring', bounce: 0.3, delay: i * 0.05 }}
                        className="relative group cursor-help -ml-1 sm:ml-0"
                        style={{ zIndex: 30 - i }} // 新しいものを手前に
                        title={log.body}
                      >
              {/* ▼ リアルな薪デザイン (焼き印なしVer) ▼ */}
                  <div className="relative w-14 h-5 sm:w-16 sm:h-6 bg-[#5d4037] rounded-sm border border-[#3e2723] shadow-[1px_2px_3px_rgba(0,0,0,0.6)] flex items-center overflow-hidden transform hover:-translate-y-1 transition">
                        {/* 樹皮テクスチャ */}
                        <div className="absolute inset-0 opacity-70" style={{backgroundImage: 'repeating-linear-gradient(90deg, #4e342e 0px, #4e342e 2px, #5d4037 2px, #5d4037 5px)'}}></div>
                        
                        {/* 断面 (年輪風) */}
                        <div className="h-full w-3 bg-[#3e2723] border-r border-[#2c1e1b] relative flex-shrink-0">
                            <div className="absolute inset-0 opacity-60" style={{backgroundImage: 'radial-gradient(circle at -30% 50%, transparent 30%, #d7ccc8 40%, #3e2723 80%)'}}></div>
                        </div>
                        
                        {/* 中央の焼き印ブロックを削除*/}
                     </div>

                         {/* 魔法の粉エフェクト */}
                         {log.magic_powder && log.magic_powder !== 'no_powder' && (
                           <span className="absolute -top-1 -right-1 w-2 h-2 rounded-full border border-black animate-pulse shadow-[0_0_5px_currentColor]" style={{backgroundColor: iconColor, color: iconColor}}></span>
                         )}
                         
                         {/* ツールチップ */}
                         <div className="absolute bottom-full mb-1 hidden group-hover:block w-max max-w-[120px] bg-[#271c19] text-[#ffecb3] text-[10px] rounded p-1 border border-[#5d4037] shadow-xl z-50 truncate text-center pointer-events-none">
                           {log.body || '...'}
                         </div>
                      </motion.div>
                    );
                 })}
                 
                 {logs.length === 0 && (
                   <p className="text-xs text-[#8d6e63] opacity-50 absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-full text-center">No logs yet...</p>
                 )}
              </div>
           </div>

        </div>
      </div>

      {/* --- 入力エリア --- */}
      <div className="relative z-40 bg-[#271c19] border-t-4 border-[#3e2723] p-4 sm:p-6 shadow-[0_-20px_50px_rgba(0,0,0,1)]">
        
        {/* ガイドメッセージ */}
        <p className="text-center text-[#8d6e63] text-sm font-bold mb-4 tracking-wider">今の気持ちを選んでください</p>

        {/* 1. 感情選択 */}
        <div className="mb-6 space-y-3">
          <div className="flex flex-wrap justify-center gap-2">
            {groupedEmotions.positive.map(emo => <EmotionButton key={emo.id} emo={emo} selectedEmotion={selectedEmotion} setSelectedEmotion={setSelectedEmotion} />)}
          </div>
          <div className="flex flex-wrap justify-center gap-2 items-center">
            {groupedEmotions.neutral.map(emo => <EmotionButton key={emo.id} emo={emo} selectedEmotion={selectedEmotion} setSelectedEmotion={setSelectedEmotion} />)}
            <div className="hidden sm:block w-px h-8 bg-[#3e2723] mx-2"></div>
            {groupedEmotions.negative.map(emo => <EmotionButton key={emo.id} emo={emo} selectedEmotion={selectedEmotion} setSelectedEmotion={setSelectedEmotion} />)}
          </div>
        </div>

        {/* 2. 詳細入力 */}
        <AnimatePresence>
          {selectedEmotion && (
            <motion.div initial={{ height: 0, opacity: 0 }} animate={{ height: 'auto', opacity: 1 }} exit={{ height: 0, opacity: 0 }} className="space-y-4 overflow-hidden">
              <input type="text" value={note} onChange={(e) => setNote(e.target.value)} placeholder="その気持ちについて、一言メモを残しますか？" className="w-full bg-[#1a100e] border border-[#4e342e] rounded px-4 py-3 text-[#d7ccc8] focus:outline-none focus:border-[#8d6e63] transition placeholder-[#5d4037]" />
              
              {/* 強度スライダー (目盛り付き) */}
              <div className="flex flex-col sm:flex-row gap-4 items-center justify-between bg-[#1a100e] p-3 rounded border border-[#3e2723]">
                <div className="w-full sm:w-auto flex-grow">
                    <div className="flex justify-between text-[10px] text-[#8d6e63] font-bold mb-1 px-1">
                       <span>弱い</span><span>強い</span>
                    </div>
                    <input type="range" min="1" max="5" step="1" value={intensity} onChange={(e) => setIntensity(parseInt(e.target.value))} className="w-full h-2 bg-[#3e2723] rounded-lg appearance-none cursor-pointer accent-[#d84315]" />
                    <div className="flex justify-between text-[10px] text-[#5d4037] mt-1 px-1">
                       <span>1</span><span>2</span><span>3</span><span>4</span><span>5</span>
                    </div>
                </div>
                <div className="text-xl font-black text-[#ffcc80] w-8 text-center">{intensity}</div>

                <button onClick={handlePreSubmit} disabled={isSubmitting} className="w-full sm:w-auto flex items-center justify-center gap-2 bg-[#bf360c] text-[#ffccbc] border-b-4 border-[#870000] px-8 py-2 rounded font-bold shadow-lg hover:brightness-110 active:border-b-0 active:translate-y-1 transition-all disabled:opacity-50 disabled:cursor-not-allowed shrink-0">
                    {isSubmitting ? '燃やしています...' : '薪をくべる 🔥'}
                </button>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
      
      {/* メッセージ (Toast) */}
      <AnimatePresence>
        {successMessage && (
          <motion.div initial={{ opacity: 0, y: -20 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -20 }} className="absolute top-32 left-1/2 transform -translate-x-1/2 z-50 bg-[#ffcc80] text-[#3e2723] px-6 py-3 rounded shadow-xl font-bold border-2 border-[#fff] flex items-center gap-2">
            <Flame size={20} /> {successMessage}
          </motion.div>
        )}
      </AnimatePresence>

      {/* 魔法の粉モーダル */}
      {showPowderModal && (
         <div className="fixed inset-0 bg-black/90 backdrop-blur-sm z-50 flex items-center justify-center p-4">
             <div className="bg-[#2c1e1b] border-4 border-[#5d4037] p-6 rounded shadow-[0_0_50px_rgba(0,0,0,1)] max-w-sm w-full relative overflow-hidden">
                 <div className="absolute top-0 left-0 w-full h-1 bg-[#8d6e63] opacity-50"></div>
                 <h3 className="text-xl font-bold text-[#ffecb3] text-center mb-4 flex items-center justify-center gap-2"><Sparkles size={20} /> 魔法の粉を使いますか？</h3>
                 <div className="space-y-2 relative z-10">
                    {MAGIC_POWDERS.map((powder) => (
                        <button key={powder.id} onClick={() => handleSubmit(powder.id)} className="w-full p-3 bg-[#3e2723] border border-[#5d4037] text-[#d7ccc8] rounded hover:bg-[#4e342e] flex items-center gap-3 transition">
                            <span className="w-6 h-6 rounded-full shadow-inner border border-black/30" style={{backgroundColor: powder.color}}></span>
                            <div className="text-left">
                                <div className="text-sm font-bold">{powder.label}</div>
                                <div className="text-xs text-[#8d6e63]">{powder.desc}</div>
                            </div>
                        </button>
                    ))}
                  <button onClick={() => handleSubmit('no_powder')} className="w-full p-3 text-[#8d6e63] text-sm hover:text-[#d7ccc8] mt-2">粉を使わずに燃やす</button>
                 </div>
             </div>
         </div>
      )}
    </div>
  );
};

export default EmotionHearth;