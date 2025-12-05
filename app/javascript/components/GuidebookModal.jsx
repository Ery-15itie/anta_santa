import React, { useState, useEffect } from 'react';
import { X, Heart, Flame, BookOpen, Snowflake, Cookie, Target, Users, Leaf, Clock, Zap, ArrowRight, HelpCircle, Mail, Feather } from 'lucide-react';

// ガイドブック用データ定義
const guideData = {
  // 1F
  gift_hall: {
    title: "玄関：ギフトホール",
    subtitle: "Core & Daily Life",
    icon: Heart,
    color: "text-red-500",
    bg: "bg-red-50",
    summary: "他者からの優しさを受け取る、メールボックスのある場所。「自分は誰かにとって価値がある」と実感できる場所です。",
    steps: [
      { label: "届いた手紙を読む", desc: "仲間から届いた「ありがとう」や応援メッセージを確認できます。" },
      { label: "ギフトを贈る", desc: "誰かの素敵な行動を見つけたら、サンタとして感謝の手紙を送りましょう。" },
      { label: "宝箱にしまう", desc: "嬉しかった言葉は宝箱に保存して、いつでも読み返せます。" }
    ]
  },
  emotion_hearth: {
    title: "リビング：感情の暖炉",
    subtitle: "Core & Daily Life",
    icon: Flame,
    color: "text-orange-500",
    bg: "bg-orange-50",
    summary: "感情ログ。今の気持ちを見つめ、感情を薪としてくべ、燃やして昇華する場所です。",
    steps: [
      { label: "今の気分を選ぶ", desc: "「喜び」「不安」「怒り」など、今の感情に一番近い薪を選びます。" },
      { label: "暖炉にくべる", desc: "感情を言葉にして薪に書き込み、暖炉に投げ入れます。" },
      { label: "炎を見つめる", desc: "燃え上がる炎のアニメーションを見ながら、心を落ち着かせましょう。" }
    ]
  },
  santa_study: {
    title: "書斎：サンタの書斎",
    subtitle: "Core & Daily Life",
    icon: BookOpen,
    color: "text-amber-500",
    bg: "bg-amber-50",
    summary: "価値観マップと人生地図。自分の軸を見つけ、生き方の指針を知る場所です。",
    steps: [
      { label: "価値観の探求", desc: "いくつかの質問に答え、あなたが大切にしている「価値観キーワード」を見つけます。" },
      { label: "人生地図を描く", desc: "過去の出来事と、これからの目標を地図のように配置します。" }
    ]
  },
  crystal_atelier: {
    title: "アトリエ：雪の結晶",
    subtitle: "Core & Daily Life",
    icon: Snowflake,
    color: "text-cyan-500",
    bg: "bg-cyan-50",
    summary: "性格診断。自分の特性を「結晶」として可視化し、強み・弱みを優しく知る場所です。",
    steps: [
      { label: "診断を受ける", desc: "質問に答えると、あなただけの形の「雪の結晶」が生成されます。" },
      { label: "特性を知る", desc: "結晶の形から、あなたの繊細さや強さのバランスを読み解きます。" }
    ]
  },
  kitchen: {
    title: "キッチン",
    subtitle: "Core & Daily Life",
    icon: Cookie,
    color: "text-yellow-500",
    bg: "bg-yellow-50",
    summary: "セルフケアと休息。心のクッキー作りで「自分を大切にする方法」を学ぶ場所です。",
    steps: [
      { label: "クッキーを焼く", desc: "「5分休む」「深呼吸する」などのセルフケアを実行し、クッキーを焼きます。" },
      { label: "瓶に貯める", desc: "自分をケアした証として、クッキージャーがいっぱいになっていきます。" }
    ]
  },
  // 2F
  attic_planning: {
    title: "屋根裏：プランニング",
    subtitle: "Future & Growth",
    icon: Target,
    color: "text-indigo-500",
    bg: "bg-indigo-50",
    summary: "未来設計。目標や夢を育成し、未来の自分をデザインする場所です。",
    steps: [
      { label: "目標ツリー", desc: "大きな夢を頂点に、それを達成するための小さな目標を枝分けして登録します。" },
      { label: "進捗確認", desc: "日々の達成度を入力し、夢への距離を確認します。" }
    ]
  },
  reindeer_stable: {
    title: "小屋：トナカイの厩舎",
    subtitle: "Future & Growth",
    icon: Users,
    color: "text-lime-600",
    bg: "bg-lime-50",
    summary: "9つの強み（トナカイ）を育て、「自分は何ができる？」に答える場所です。",
    steps: [
      { label: "経験値を得る", desc: "村での活動（コメントや開発）に応じて、対応するトナカイの経験値が入ります。" },
      { label: "レベルアップ", desc: "トナカイが成長すると、あなたの「強み」としてプロフィールに表示されます。" }
    ]
  },
  courtyard_tree: {
    title: "中庭：クリスマスツリー",
    subtitle: "Future & Growth",
    icon: Leaf,
    color: "text-green-500",
    bg: "bg-green-50",
    summary: "成長の象徴。部屋の活動によって飾りが増え、自己理解の進捗が光り出す場所です。",
    steps: [
      { label: "オーナメント", desc: "各部屋のミッションをクリアすると、ツリーに飾りが増えます。" },
      { label: "点灯式", desc: "自己理解が深まると、ツリー全体が光り輝きます。" }
    ]
  },
  gallery_detail: {
    title: "廊下：思い出ギャラリー",
    subtitle: "Future & Growth",
    icon: Clock,
    color: "text-teal-500",
    bg: "bg-teal-50",
    summary: "過去から学ぶ。過去の成果や言葉を飾り、頑張ってきた自分を肯定する場所です。",
    steps: [
      { label: "作品を飾る", desc: "過去に作ったアプリや記事を額縁に入れて飾ります。" },
      { label: "歩みを振り返る", desc: "自分がどれだけ遠くまで来たか、視覚的に確認できます。" }
    ]
  },
  // B1
  basement: {
    title: "地下室：秘密の工房",
    subtitle: "Basement",
    icon: Zap,
    color: "text-stone-500",
    bg: "bg-stone-100",
    summary: "弱さと共に生きる練習。不安や挫折を閉じ込めず、そっと置いておける安全地帯です。",
    steps: [
      { label: "不安を置く", desc: "解決しなくていい。ただ「不安がある」ことだけをここに書き留めます。" },
      { label: "鍵をかける", desc: "今は見たくないものは、箱に入れて鍵をかけておきましょう。" }
    ]
  },
};

const reindeersList = [
  { icon: "🔥", name: "ブレイズ", mean: "情熱・行動力" },
  { icon: "💡", name: "ルキス", mean: "洞察・気づき" },
  { icon: "🍯", name: "ミエル", mean: "優しさ・共感" },
  { icon: "🎨", name: "イデア", mean: "創造・アイデア" },
  { icon: "🌱", name: "クレスコ", mean: "成長・努力" },
  { icon: "🛡️", name: "ノービレ", mean: "誠実・責任感" },
  { icon: "❄️", name: "カルマ", mean: "冷静・判断力" },
  { icon: "🤝", name: "リアン", mean: "協力・つながり" },
  { icon: "⚡", name: "アウダ", mean: "挑戦・冒険" },
];

const GuidebookModal = ({ isOpen, onClose }) => {
  // 初期表示は「ギフトホール」
  const [activeKey, setActiveKey] = useState('gift_hall'); 

  useEffect(() => {
    const handleEsc = (e) => {
      if (e.key === 'Escape') onClose();
    };
    window.addEventListener('keydown', handleEsc);
    return () => window.removeEventListener('keydown', handleEsc);
  }, [onClose]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-[9999] flex items-center justify-center bg-black/70 backdrop-blur-sm p-4 animate-in fade-in duration-300" onClick={onClose}>
      
      {/* 本のコンテナ */}
      <div 
        className="relative w-full max-w-6xl h-[85vh] bg-[#fdfbf7] rounded-r-2xl shadow-2xl flex overflow-hidden transform transition-all scale-100" 
        onClick={(e) => e.stopPropagation()}
      >
        {/* 閉じるボタン */}
        <button 
          onClick={onClose}
          className="absolute top-4 right-6 z-50 text-[#8d6e63] hover:text-[#b71c1c] transition flex items-center gap-1 font-serif font-bold"
        >
          <X size={24} /> <span className="hidden sm:inline">閉じる</span>
        </button>

        {/* ■■■ 左ページ：目次 (INDEX) ■■■ */}
        <div className="hidden md:flex flex-col w-1/3 min-w-[300px] bg-[#f5f0e6] border-r border-[#e3dcd2] relative overflow-y-auto custom-scrollbar">
           {/* 紙のテクスチャ */}
           <div className="absolute inset-0 opacity-10 pointer-events-none bg-[url('https://www.transparenttextures.com/patterns/cream-paper.png')]"></div>

           <div className="relative z-10 p-8 pb-20">
              <div className="mb-8 text-center border-b-2 border-[#d7ccc8] pb-4">
                <h2 className="text-2xl font-black text-[#3e2723] font-serif tracking-wider">GUIDE INDEX</h2>
                <p className="text-xs text-[#8d6e63] font-bold mt-1">部屋を選んで使い方を見る</p>
              </div>

              {/* 1F Menu */}
              <div className="mb-6">
                <h3 className="text-xs font-bold text-[#8d6e63] mb-2 px-2 uppercase tracking-widest">1F: Core & Daily Life</h3>
                <ul className="space-y-1">
                  <MenuItem id="gift_hall" label="① 玄関：ギフトホール" icon={Heart} activeKey={activeKey} onClick={setActiveKey} />
                  <MenuItem id="emotion_hearth" label="② リビング：感情の暖炉" icon={Flame} activeKey={activeKey} onClick={setActiveKey} />
                  <MenuItem id="santa_study" label="③ 書斎：サンタの書斎" icon={BookOpen} activeKey={activeKey} onClick={setActiveKey} />
                  <MenuItem id="crystal_atelier" label="④ アトリエ：雪の結晶" icon={Snowflake} activeKey={activeKey} onClick={setActiveKey} />
                  <MenuItem id="kitchen" label="⑤ キッチン" icon={Cookie} activeKey={activeKey} onClick={setActiveKey} />
                </ul>
              </div>

              {/* 2F & B1 Menu */}
              <div className="mb-6">
                <h3 className="text-xs font-bold text-[#8d6e63] mb-2 px-2 uppercase tracking-widest">2F & B1: Future & Growth</h3>
                <ul className="space-y-1">
                  <MenuItem id="attic_planning" label="⑥ 屋根裏：プランニング" icon={Target} activeKey={activeKey} onClick={setActiveKey} />
                  <MenuItem id="reindeer_stable" label="⑦ 小屋：トナカイの厩舎" icon={Users} activeKey={activeKey} onClick={setActiveKey} />
                  <MenuItem id="courtyard_tree" label="⑧ 中庭：クリスマツリー" icon={Leaf} activeKey={activeKey} onClick={setActiveKey} />
                  <MenuItem id="gallery_detail" label="⑨ 廊下：思い出ギャラリー" icon={Clock} activeKey={activeKey} onClick={setActiveKey} />
                  <MenuItem id="basement" label="⑩ 地下室：秘密の工房" icon={Zap} activeKey={activeKey} onClick={setActiveKey} />
                </ul>
              </div>

               {/* Special & Message Menu */}
               <div className="space-y-3 mt-8 pt-6 border-t border-[#d7ccc8]">
                <button 
                  onClick={() => setActiveKey('reindeers')}
                  className={`w-full flex items-center gap-3 px-3 py-3 rounded-lg text-sm font-bold transition-all duration-200 ${activeKey === 'reindeers' ? 'bg-[#3e2723] text-[#ffecb3] shadow-md transform scale-105' : 'text-[#5d4037] hover:bg-[#efebe9]'}`}
                >
                  <span className="text-lg">🦌</span> 9頭のトナカイ図鑑
                </button>

                <button 
                  onClick={() => setActiveKey('developer_message')}
                  className={`w-full flex items-center gap-3 px-3 py-3 rounded-lg text-sm font-bold transition-all duration-200 ${activeKey === 'developer_message' ? 'bg-[#b71c1c] text-white shadow-md transform scale-105' : 'text-[#8d6e63] hover:text-[#b71c1c] hover:bg-[#ffebee]'}`}
                >
                  <Mail size={18} /> 開発者からの手紙
                </button>
              </div>
           </div>
        </div>

        {/* ■■■ 右ページ：詳細コンテンツ ■■■ */}
        <div className="w-full md:w-2/3 bg-[#fffdf9] relative overflow-y-auto custom-scrollbar flex flex-col">
          {/* 本の綴じ目の陰影 */}
          <div className="absolute left-0 top-0 bottom-0 w-8 bg-gradient-to-r from-black/5 to-transparent pointer-events-none z-20"></div>

          {/* コンテンツ表示エリア */}
          <div className="flex-grow p-8 md:p-12 relative z-10">
            {activeKey === 'reindeers' ? (
              <ReindeersDetail />
            ) : activeKey === 'developer_message' ? (
              <DeveloperMessageDetail />
            ) : (
              <RoomDetail data={guideData[activeKey]} />
            )}
          </div>
          
          {/* フッター（ページ番号的な装飾） */}
          <div className="p-4 text-center border-t border-[#f0ebe5] text-[#d7ccc8] text-xs font-serif italic">
             Heartory Home Guide Book
          </div>
        </div>
      </div>
    </div>
  );
};

// --- 右ページ: 部屋の詳細 ---
const RoomDetail = ({ data }) => {
  if (!data) return <div className="p-10 text-center text-[#8d6e63]">部屋を選択してください</div>;

  const Icon = data.icon;

  return (
    <div className="animate-in fade-in slide-in-from-right-4 duration-500">
      {/* ヘッダーエリア */}
      <div className={`flex items-start gap-6 mb-8 border-b-2 border-dashed border-[#d7ccc8] pb-6`}>
        <div className={`p-6 rounded-2xl shadow-inner ${data.bg} ${data.color} shrink-0`}>
          <Icon size={48} />
        </div>
        <div>
          <span className="text-xs font-bold text-[#8d6e63] uppercase tracking-widest">{data.subtitle}</span>
          <h2 className="text-3xl font-black text-[#3e2723] font-serif mt-1 mb-3">{data.title}</h2>
          <p className="text-[#5d4037] leading-relaxed font-medium">
            {data.summary}
          </p>
        </div>
      </div>

      {/* 使い方ステップエリア */}
      <div className="mb-8">
        <h3 className="flex items-center gap-2 text-lg font-bold text-[#3e2723] mb-4 font-serif">
          <HelpCircle size={20} className="text-[#8d6e63]" />
          この部屋での過ごし方
        </h3>
        
        <div className="space-y-4">
          {data.steps.map((step, index) => (
            <div key={index} className="flex gap-4 bg-white p-4 rounded-xl border border-[#efebe9] shadow-sm hover:shadow-md transition-shadow">
              <div className="flex flex-col items-center justify-center w-10 h-10 rounded-full bg-[#3e2723] text-[#ffecb3] font-bold shrink-0 font-serif text-lg">
                {index + 1}
              </div>
              <div>
                <strong className="block text-[#3e2723] font-bold mb-1">{step.label}</strong>
                <p className="text-sm text-[#5d4037] opacity-90">{step.desc}</p>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* プレースホルダー画像エリア */}
      <div className="w-full h-48 bg-[#f5f0e6] rounded-xl border-2 border-dashed border-[#d7ccc8] flex flex-col items-center justify-center text-[#8d6e63] gap-2">
        <div className="opacity-50"><Icon size={32} /></div>
        <span className="text-xs font-bold">ここに部屋のイメージや操作画面が表示されます</span>
      </div>
    </div>
  );
};

// --- 右ページ: トナカイ図鑑 ---
const ReindeersDetail = () => (
  <div className="animate-in fade-in slide-in-from-right-4 duration-500">
    <div className="text-center mb-8 border-b-2 border-dashed border-[#d7ccc8] pb-6">
      <span className="text-4xl mb-2 block">🦌</span>
      <h2 className="text-3xl font-black text-[#3e2723] font-serif">9頭のトナカイ図鑑</h2>
      <p className="text-[#5d4037] mt-3">
        トナカイはあなたの「強み」の象徴です。<br/>
        村での活動や開発を通して経験値を積み、彼らを育てましょう。
      </p>
    </div>

    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
      {reindeersList.map((r) => (
        <div key={r.name} className="flex items-center gap-3 bg-white p-3 rounded-lg border border-[#efebe9] shadow-sm hover:border-[#8d6e63] transition-colors">
          <span className="text-3xl bg-[#fdfbf7] w-12 h-12 flex items-center justify-center rounded-full shadow-inner">{r.icon}</span>
          <div>
            <div className="font-bold text-[#3e2723]">{r.name}</div>
            <div className="text-xs text-[#8d6e63] font-bold bg-[#efebe9] px-2 py-0.5 rounded inline-block mt-1">
              {r.mean}
            </div>
          </div>
        </div>
      ))}
    </div>
  </div>
);

// --- 右ページ: 開発者からの手紙 (NEW) ---
const DeveloperMessageDetail = () => (
  <div className="animate-in fade-in slide-in-from-right-4 duration-500 max-w-2xl mx-auto">
    
    <div className="text-center mb-10">
        <span className="text-[#b71c1c] block mb-2"><Feather size={32} className="mx-auto" /></span>
        <h2 className="text-2xl font-black text-[#3e2723] font-serif mb-2">大人になったあなたへ</h2>
        <p className="text-xs text-[#8d6e63] font-bold uppercase tracking-widest">MESSAGE FROM DEVELOPER</p>
    </div>

    <div className="space-y-6 text-[#5d4037] text-sm leading-loose font-medium text-justify font-serif bg-white p-8 rounded-sm shadow-sm border border-[#efebe9] relative">
      {/* 封筒のような装飾ライン */}
      <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-red-700 via-green-700 to-red-700 opacity-30"></div>

      <p>
        子供の頃の私たちは毎年12月になると「今年は良い子だったかな？」と自分を振り返り、サンタさんからの評価を心待ちにしていました。あの頃のサンタさんは私たちの行いをすべて見ていて、公平に評価してくれる特別な存在でした。
      </p>
      <p>
        でも大人になるとサンタさんはプレゼントを持って訪れてはくれません。じゃあ誰が私たちを評価してくれるでしょうか？上司？家族？友人？<br/>
        実は、私たちの周りにいるすべての人が「サンタさん」なのです。
      </p>
      <p>
        同僚があなたの仕事ぶりに感謝し、友人があなたの優しさに救われ、家族があなたの存在に安心する。私たちは誰かにとっての「サンタさん」であり、同時に誰かから贈り物のような評価をもらう存在なのです。
      </p>
      <div className="py-4 px-6 bg-[#fff8e1] border-l-4 border-[#ffb300] italic text-xs sm:text-sm text-[#5d4037] my-4">
        「質問に丁寧に答えてくれてありがとう」<br/>
        「あなたの頑張る姿に刺激を受けたよ」
      </div>
      <p>
        こうした学習者同士の温かいフィードバックこそ、大人が求める「サンタさんからの評価」であり価値だと思います。<br/>
        このシステムは、みんなが誰かのサンタさんになれる場所を作ります。クリスマスが一年中続く、温かい居場所の実現を目指しています。
      </p>

      <div className="pt-6 mt-6 border-t border-dashed border-[#d7ccc8] text-center">
        <p className="text-lg font-bold text-[#b71c1c] mb-2">
          そして、もうひとり大切なサンタさんがいます。<br/>
          それは、<span className="underline decoration-red-300 decoration-4">あなた自身</span>です。
        </p>
        <p>
          Heartory Homeは、あなたが自分自身と向き合い、「よく頑張ったね」と自分にプレゼントを贈るための場所でもあります。
        </p>
        <p className="mt-4 font-bold text-[#3e2723]">
          さあ、あなただけの物語を始めましょう！！
        </p>
      </div>
      
      <div className="mt-8 text-right">
        <p className="text-xs text-[#8d6e63]">Anta-Santa Project Developer</p>
        <p className="font-serif font-bold text-[#3e2723] text-lg">えりぃー</p>
      </div>
    </div>
  </div>
);

// --- ヘルパー: 左メニュー項目 ---
const MenuItem = ({ id, label, icon: Icon, activeKey, onClick }) => (
  <li>
    <button 
      onClick={() => onClick(id)}
      className={`w-full flex items-center justify-between px-3 py-3 rounded-lg text-sm font-bold transition-all duration-200 group ${activeKey === id ? 'bg-[#3e2723] text-[#ffecb3] shadow-md transform scale-105' : 'text-[#5d4037] hover:bg-[#efebe9]'}`}
    >
      <div className="flex items-center gap-3">
        <Icon size={18} className={`${activeKey === id ? 'text-[#ffecb3]' : 'text-[#8d6e63] group-hover:text-[#5d4037]'}`} />
        <span>{label}</span>
      </div>
      {activeKey === id && <ArrowRight size={14} className="animate-pulse" />}
    </button>
  </li>
);

export default GuidebookModal;