import React, { useState } from 'react';
import { LogIn, Heart, BookOpen, Clock, Zap, Target, Aperture, Leaf, Users, Cookie, ChevronUp, LogOut } from 'lucide-react';
import EmotionHearth from './EmotionHearth';
import EmotionStats from './EmotionStats';
// 新しい「書斎の部屋」コンポーネントを読み込み 
import SantasStudyRoom from './SantaStudy/SantasStudyRoom'; 

// 画像URL定義
const rooms = [
  // 1階
  { id: 'gift_hall', name: '🎁 ギフトホール', icon: Heart, theme: 'bg-red-400', color: 'text-red-100', description: '他者と優しさで交流する場所', path: '/gift-hall', image_url: 'https://i.imgur.com/7oZ0Cb8.jpeg', floor: 1 },
  { id: 'emotion_hearth_living', name: '🔥 暖炉のリビング', icon: LogIn, theme: 'bg-orange-400', color: 'text-orange-100', description: '今の気持ちを見つめる場所 ', path: '/emotion-log', image_url: 'https://i.imgur.com/OrHvlUy.jpeg', floor: 1 },
  { id: 'santa_study', name: '📜 サンタの書斎', icon: BookOpen, theme: 'bg-amber-400', color: 'text-amber-100', description: '価値観と人生地図を知る場所', path: '/santa-study', image_url: 'https://i.imgur.com/vCcz63t.jpeg', floor: 1 },
  { id: 'crystal_atelier', name: '❄️ クリスタルアトリエ', icon: Aperture, theme: 'bg-cyan-400', color: 'text-cyan-100', description: '自分の特性を可視化する場所', path: '/atelier', image_url: 'https://i.imgur.com/JsZJ5xe.jpeg', floor: 1 },
  { id: 'kitchen', name: '🍪 キッチン', icon: Cookie, theme: 'bg-yellow-400', color: 'text-yellow-100', description: 'セルフケアと休息のための場所', path: '/kitchen', image_url: 'https://i.imgur.com/WAaScDe.jpeg', floor: 1 },
  // 2階
  { id: 'attic_planning', name: '🌠 屋根裏プランニング', icon: Target, theme: 'bg-indigo-400', color: 'text-indigo-100', description: '目標設定と未来設計の場所', path: '/planning', image_url: 'https://i.imgur.com/cc2N7a0.jpeg', floor: 2 },
  { id: 'reindeer_stable', name: '🦌 トナカイの厩舎', icon: Users, theme: 'bg-lime-400', color: 'text-lime-100', description: 'あなたの強み（才能）を育てる場所', path: '/reindeer', image_url: 'https://i.imgur.com/FudaPUO.jpeg', floor: 2 },
  { id: 'courtyard_tree', name: '🎄 中庭のツリー', icon: Leaf, theme: 'bg-green-400', color: 'text-green-100', description: '成長と軌跡のギャラリー', path: '/gallery', image_url: 'https://i.imgur.com/fl8y9zl.jpeg', floor: 2 },
  { id: 'gallery_detail', name: '🖼 思い出ギャラリー', icon: Clock, theme: 'bg-teal-400', color: 'text-teal-100', description: '過去から学び、未来に繋げる場所', path: '/gallery-detail', image_url: 'https://i.imgur.com/Towof2q.jpeg', floor: 2 },
  // 地下
  { id: 'basement', name: '🕯 秘密の地下室', icon: Zap, theme: 'bg-stone-600', color: 'text-stone-200', description: '弱さと向き合う場所', path: '/basement', image_url: 'https://i.imgur.com/QsrudWO.jpeg', floor: 0 },
];

const roomsFirstFloor = rooms.filter(r => r.floor === 1);
const roomsSecondFloor = rooms.filter(r => r.floor === 2);
const roomBasement = rooms.find(r => r.floor === 0);

const HeartoryHome = () => {
  const [currentPath, setCurrentPath] = useState('/'); 
  const [activeRoomId, setActiveRoomId] = useState(null); 

  const handleNavigation = (path) => {
    setCurrentPath(path);
    setActiveRoomId(null);
  };

  const handleLogout = (e) => {
    if(e) e.preventDefault();
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '/users/sign_out';
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
    const hiddenMethod = document.createElement('input');
    hiddenMethod.type = 'hidden';
    hiddenMethod.name = '_method';
    hiddenMethod.value = 'delete';
    const hiddenToken = document.createElement('input');
    hiddenToken.type = 'hidden';
    hiddenToken.name = 'authenticity_token';
    hiddenToken.value = csrfToken;
    form.appendChild(hiddenMethod);
    form.appendChild(hiddenToken);
    document.body.appendChild(form);
    form.submit();
  };

  const handleRoomClick = (room) => {
    if (room.id === 'gift_hall') {
      window.location.href = '/gift-hall'; 
      return;
    }
    if (room.id === 'emotion_hearth_living') {
      handleNavigation(room.path);
      return;
    }
    // 修正: サンタの書斎なら書斎画面へ 
    if (room.id === 'santa_study') {
      handleNavigation(room.path); // '/santa-study'
      return;
    }
    
    setActiveRoomId(room.id); 
  };

  const MessageModal = ({ roomId }) => {
    if (!roomId) return null;
    const room = rooms.find(r => r.id === roomId);
    if (!room) return null;

    return (
      <div className="fixed inset-0 bg-black/80 flex items-center justify-center z-50 p-4 backdrop-blur-sm">
        <div className={`relative p-8 rounded-sm shadow-2xl max-w-sm w-full bg-[#fdf6e3] border-8 border-[#5d4037] outline outline-2 outline-[#3e2723]`}>
          <div className="absolute top-2 left-2 w-3 h-3 rounded-full bg-[#3e2723] opacity-80 shadow-inner"></div>
          <div className="absolute top-2 right-2 w-3 h-3 rounded-full bg-[#3e2723] opacity-80 shadow-inner"></div>
          <div className="absolute bottom-2 left-2 w-3 h-3 rounded-full bg-[#3e2723] opacity-80 shadow-inner"></div>
          <div className="absolute bottom-2 right-2 w-3 h-3 rounded-full bg-[#3e2723] opacity-80 shadow-inner"></div>

          <div className={`text-center mb-4 ${room.color.replace('text-', 'text-gray-')}`}>
            <room.icon size={48} className={`mx-auto mb-2 ${room.theme.replace('bg-', 'text-')}`} />
            <h3 className="text-2xl font-black text-[#3e2723] font-serif">{room.name}</h3>
          </div>
          <img src={room.image_url} alt={room.name} className="w-full h-40 object-cover rounded border-2 border-[#8d6e63] mb-4 shadow-md" />
          <p className="text-sm text-[#5d4037] mb-6 text-center font-medium leading-relaxed">{room.description}</p>
          
          <p className="text-center font-bold text-[#3e2723] mt-2 border-t-2 border-dashed border-[#8d6e63] pt-4">
            — Coming Soon —
          </p>
          <button onClick={() => setActiveRoomId(null)} className={`w-full mt-6 py-3 px-4 rounded font-bold text-white shadow-md ${room.theme} hover:brightness-110 transition-all`}>
            閉じる
          </button>
        </div>
      </div>
    );
  };
    // 1. ホーム画面
  const HomeView = () => (
    <>
      <div className="relative mb-12 pt-6">
        <div className="absolute top-0 right-4 sm:right-10 z-20 group cursor-pointer" onClick={handleLogout}>
            <div className="absolute -top-6 left-4 w-1 h-12 bg-stone-400"></div>
            <div className="absolute -top-6 right-4 w-1 h-12 bg-stone-400"></div>
            <div className="relative bg-[#5d4037] border-4 border-[#3e2723] rounded shadow-xl px-4 py-2 transform group-hover:rotate-2 transition-transform duration-300 origin-top">
                <div className="flex items-center gap-2 text-[#ffecb3] font-bold font-serif tracking-wider">
                    <LogOut size={18} />
                    <span>EXIT</span>
                </div>
                <div className="absolute top-1 left-1 w-full h-[1px] bg-white/10"></div>
            </div>
        </div>

        <div className="text-center">
            <h1 className="text-4xl sm:text-5xl font-black text-[#ffecb3] tracking-wider drop-shadow-[0_4px_4px_rgba(0,0,0,0.8)] font-serif" 
                style={{ textShadow: '2px 2px 0px #3e2723, 4px 4px 0px #271c19' }}>
                Heartory Home
            </h1>
            <p className="text-[#d7ccc8] mt-2 font-medium tracking-widest text-sm sm:text-base shadow-black drop-shadow-md">
                ― ここは、あなたの心を見つめる温かい家 ―
            </p>
        </div>
      </div>

      <div className="max-w-6xl mx-auto relative">
        <div className="absolute -top-8 left-1/2 transform -translate-x-1/2 w-[95%] h-8 bg-[#3e2723] rounded-t-full shadow-xl z-0 flex items-center justify-center">
             <div className="w-20 h-20 bg-[#3e2723] rotate-45 transform translate-y-6 border-4 border-[#5d4037]"></div>
        </div>

        <div className="bg-[#fdf6e3] border-x-8 border-b-8 border-[#5d4037] rounded-b-lg shadow-2xl overflow-hidden relative z-10">
            <div className="p-6 bg-[#fff8e1] border-b-8 border-[#5d4037] relative">
                <div className="absolute top-0 left-0 w-full h-4 bg-[#4e342e] opacity-20"></div>
                <div className="flex items-center mb-4">
                    <div className="bg-[#5d4037] text-[#ffecb3] text-xs font-bold px-3 py-1 rounded shadow font-serif">2F: Future & Growth</div>
                </div>
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
                    {roomsSecondFloor.map((room) => (
                    <RoomCard key={room.id} room={room} onClick={handleRoomClick} />
                    ))}
                </div>
            </div>

            <div className="p-6 bg-[#fff8e1] relative">
                 <div className="flex items-center mb-4">
                    <div className="bg-[#5d4037] text-[#ffecb3] text-xs font-bold px-3 py-1 rounded shadow font-serif">1F: Core & Daily Life</div>
                </div>
                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 gap-4">
                    {roomsFirstFloor.map((room) => (
                    <RoomCard key={room.id} room={room} onClick={handleRoomClick} />
                    ))}
                </div>
            </div>
        </div>
      </div>
      
      {roomBasement && (
        <div className="max-w-xl mx-auto mt-12 pb-8">
          <div className="text-center mb-2">
             <span className="bg-black/50 text-white px-3 py-1 rounded-full text-xs font-bold">▼ Basement Entrance</span>
          </div>
          <div className="border-4 border-[#271c19] bg-[#1a1a1a] rounded-xl shadow-2xl p-1 mx-4 relative group cursor-pointer transform hover:translate-y-1 transition-transform">
             <div className="absolute inset-0 bg-[linear-gradient(45deg,transparent_45%,#000_45%,#000_55%,transparent_55%)] opacity-20 pointer-events-none"></div>
            <div className="p-4">
              <RoomCard room={roomBasement} onClick={handleRoomClick} isBasement={true} />
            </div>
          </div>
        </div>
      )}

      <div className="mt-12 mb-8 text-center border-t border-[#5d4037] pt-8 opacity-80 max-w-4xl mx-auto">
        <ul className="flex flex-wrap justify-center gap-4 sm:gap-6 text-xs sm:text-sm text-[#ffecb3] font-bold tracking-wider">
          <li><a href="/terms" className="hover:text-[#ffcc80]">利用規約 (村の掟)</a></li>
          <li><a href="/privacy" className="hover:text-[#ffcc80]">プライバシーポリシー (秘密の守り方)</a></li>
          <li><a href="/contact" className="hover:text-[#ffcc80]">お問い合わせフォーム</a></li>
        </ul>
        <p className="text-[#8d6e63] text-[10px] sm:text-xs mt-4 font-mono">© 2025 Anta-Santa. All Rights Reserved.</p>
      </div>
    </>
  );
  
  const renderView = () => {
    switch (currentPath) {
      case '/': return <HomeView />;
      case '/emotion-log': 
        return <EmotionHearth onBack={() => handleNavigation('/')} onOpenStats={() => handleNavigation('/emotion-stats')} onLogout={handleLogout} />;
      case '/emotion-stats':
         return <EmotionStats onBack={() => handleNavigation('/emotion-log')} onLogout={handleLogout} />;
      
      // 「書斎の部屋」を表示 ▼▼▼
      case '/santa-study':
         return <SantasStudyRoom onBack={() => handleNavigation('/')} />;
      
      default: return <HomeView />;
    }
  };

  return (
    <div className="min-h-screen bg-[#3e2723] font-sans text-gray-800 flex flex-col">
      <div className="fixed inset-0 opacity-20 pointer-events-none" style={{ backgroundImage: 'repeating-linear-gradient(45deg, #3e2723 25%, #4e342e 25%, #4e342e 50%, #3e2723 50%, #3e2723 75%, #4e342e 75%, #4e342e 100%)', backgroundSize: '20px 20px' }}></div>
      <MessageModal roomId={activeRoomId} />
      <main className="container mx-auto p-4 relative z-10 flex-grow">
        {renderView()}
      </main>
    </div>
  );
};

const RoomCard = ({ room, onClick, isBasement = false }) => {
  const Icon = room.icon;
  const borderClass = isBasement ? 'border-stone-600' : 'border-[#8d6e63]';
  const bgClass = isBasement ? 'bg-stone-800' : 'bg-[#5d4037]';
  const shadowClass = isBasement ? 'shadow-inner' : 'shadow-[2px_4px_0px_0px_rgba(62,39,35,1)]';

  return (
    <div
      onClick={() => onClick(room)}
      className={`group relative overflow-hidden rounded-lg cursor-pointer h-40 sm:h-48 w-full ${shadowClass} transition-all duration-300 transform hover:-translate-y-1 hover:brightness-110 border-4 ${borderClass} ${bgClass}`}
    >
      <div className="absolute inset-0 z-0">
        <img src={room.image_url} alt={room.name} className="w-full h-full object-cover opacity-90 transition-transform duration-700 group-hover:scale-110" />
        <div className={`absolute inset-0 bg-gradient-to-t ${isBasement ? 'from-black via-stone-900/70' : 'from-[#3e2723] via-transparent'} to-transparent opacity-90`} />
      </div>
      <div className="absolute inset-0 z-10 flex flex-col justify-end p-3 text-white">
        <div className="flex items-center justify-between mb-1">
            <div className={`p-1.5 rounded backdrop-blur-sm bg-black/30 border border-white/20 ${room.color}`}><Icon size={18} /></div>
            {!isBasement && <ChevronUp size={16} className="opacity-0 group-hover:opacity-100 transition-opacity duration-300 rotate-90 text-[#ffecb3]" />}
        </div>
        <h4 className="font-bold text-sm sm:text-base leading-tight drop-shadow-md font-serif tracking-wide text-[#ffecb3]">{room.name}</h4>
        <p className="text-[10px] sm:text-xs text-gray-200 mt-0.5 truncate opacity-90 font-light">{room.description}</p>
      </div>
    </div>
  );
};

export default HeartoryHome;