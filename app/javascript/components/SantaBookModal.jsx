import React, { useState } from 'react';
import { X, ChevronLeft, ChevronRight, BookOpen } from 'lucide-react';

// ▼▼▼ デザイン用スタイル定義（絵本風フォント・紙の質感・クリスマス柄テープ） ▼▼▼
const fontStyle = (
  <style>
    {`
      @import url('https://fonts.googleapis.com/css2?family=Zen+Maru+Gothic:wght@500;700&display=swap');
      
      .font-picture-book {
        font-family: 'Zen Maru Gothic', sans-serif;
      }
      
      /* 紙の質感（中心が明るく、端が少し暗い） */
      .paper-texture {
        background-color: #fffbf0;
        background-image: radial-gradient(circle, #fffbf0 0%, #fff8e1 90%, #faeec7 100%);
      }

      /* ▼▼▼ クリスマスカラーのストライプテープ ▼▼▼ */
      .masking-tape {
        position: absolute;
        top: -12px;
        left: 50%;
        transform: translateX(-50%) rotate(-1.5deg);
        width: 100px;
        height: 28px;
        
        /* 斜めストライプ（赤・黄・緑・黄の繰り返し） */
        background-image: repeating-linear-gradient(
          -45deg,
          rgba(211, 47, 47, 0.85) 0px,  /* 赤 */
          rgba(211, 47, 47, 0.85) 10px,
          rgba(253, 216, 53, 0.9) 10px, /* 黄 */
          rgba(253, 216, 53, 0.9) 12px,
          rgba(56, 142, 60, 0.85) 12px, /* 緑 */
          rgba(56, 142, 60, 0.85) 30px,
          rgba(253, 216, 53, 0.9) 30px, /* 黄（つなぎ） */
          rgba(253, 216, 53, 0.9) 33px
        );

        /* テープの端のギザギザ感 */
        border-left: 2px dotted rgba(255,255,255,0.8);
        border-right: 2px dotted rgba(255,255,255,0.8);
        box-shadow: 0 2px 4px rgba(0,0,0,0.15);
        z-index: 10;
        opacity: 0.95;
      }
    `}
  </style>
);

// === 📖 ガイドブックのデータ設定 ===
const guideContent = [
  // ----------------------------------------------------
  // Page 1: ギフトホール
  // ----------------------------------------------------
  {
    id: 1,
    title: "ギフトホール",
    icon: "🎁",
    desc: "ここは、仲間と優しさを交換する場所。あなたの言葉が誰かのプレゼントになります。",
    status: "open",
    path: "/gift-hall",
    steps: [
      {
        title: "ギフトホールの入り口",
        text: "ここがトップ画面です。「メッセージを送る」を選ぶと、手紙を書く準備が始まります。",
        img: "/images/guide/gift_01_top.png" 
      },
      {
        title: "宛先帳（Address Book）",
        text: "メッセージを送りたい相手をリストから探しましょう。検索して新しい友達を見つけることもできます。フォローボタンを押すとCheck Friend List を押した際にフレンドリストに追加されます。",
        img: "/images/guide/gift_02_address.png"
      },
      {
        title: "相手を選ぶ",
        text: "「お手紙を送る」ボタンを押してみてください。メッセージを送ることができます。名前をクリックするとプロフィールを見ることができます。もちろんプロフィール画面からフォロー、お手紙を送ることが可能です。",
        img: "/images/guide/gift_03_select.png"
      },
      {
        title: "手紙を書く",
        text: "便箋にあなたの想いを綴りましょう。応援、感謝、共有... 温かい言葉なら何でもOK。これは相手の心に届くギフトです。相手が自分の素敵な魅力に気づくよう、素敵だな！と思うところをチェックリストから1つは選んでくださいね。",
        img: "/images/guide/gift_04_write.png"
      },
      {
        title: "内容の確認",
        text: "書き終わったら最終確認。切手を貼るように、心を込めて右下の送信ボタンを押します。",
        img: "/images/guide/gift_05_confirm.png"
      },
      {
        title: "ポストに届く",
        text: "相手のポスト（Mail Box）にあなたの手紙が届きます。ギフトホールの入り口から「メッセージ一覧へ」で送受信ともに確認ができます。もちろん、あなたにも誰かからお手紙が届くかも？",
        img: "/images/guide/gift_06_mailbox.png"
      },
      {
        title: "手紙を開く",
        text: "届いた手紙はいつでも読み返せます。辛い時こそ読み返すと、元気が湧いてくる宝物になります。",
        img: "/images/guide/gift_07_open.png"
      },
      {
        title: "ダッシュボードの更新",
        text: "手紙が届くと、ダッシュボードの情報が更新されます。チェックされたあなたの良いところやあなたに最近メッセージを送ってくれたサンタさんが可視化されます！",
        img: "/images/guide/gift_08_dashboard.png"
      },
    ]
  },
  // ----------------------------------------------------
  // Page 2: リビング（感情の暖炉）
  // ----------------------------------------------------
  {
    id: 2,
    title: "暖炉のリビング",
    icon: "🔥",
    desc: "ここは、心の温度を感じる場所。嬉しいことも、悲しいことも、薪にくべて温かさに変えましょう。",
    status: "open",
    path: "/emotion-log",
    steps: [
      {
        title: "暖炉の前で一休み",
        text: "まずは暖炉の前のソファーに座るように、心を落ち着かせましょう。「LOG」ボタンから過去の記録を見ることができます。",
        img: "/images/guide/hearth_01_top.png"
      },
      {
        title: "今の気持ちを薪にする",
        text: "「喜び」「悲しみ」などの感情を選び、その強さをスライダーで調節します。言葉として感情はメモに残せます。準備が整ったら、「薪をくべる」ボタンを押しましょう。",
        img: "/images/guide/hearth_02_input.png"
      },
      {
        title: "魔法の粉で昇華する",
        text: "悲しみや不安などの「負の感情」を選んだ時だけ、不思議な魔法の粉が現れます。炎の色を変えて、痛みを美しく昇華させましょう。そのままでも大丈夫です。",
        img: "/images/guide/hearth_03_magic.png"
      },
      {
        title: "灯火のあしあと（LOG）",
        text: "くべた薪は、あなたが人間らしく気持ちを持って生きた証として記録されます。記録の書から過去の感情を振り返ることで、自分の心の癖に気づけるかもしれません。",
        img: "/images/guide/hearth_04_log.png"
      },
      {
        title: "ステータス",
        text: "「灯火のあしあと」ページでは、記録した感情の数や、魔法の粉の使用回数が見られます(薪をくべた数に応じてレベルが上がり、称号が変化します)。実績に応じてカードコレクションも獲得できますよ！",
        img: "/images/guide/hearth_05_stats.png"
      },
    ]
  },
  // ----------------------------------------------------
  {
    id: 3,
    title: "サンタの書斎",
    icon: "📜",
    desc: "価値観と人生地図の部屋。自分が大切にしたいものを整理する羅針盤です。",
    status: "open",
    path: "/santa-study"
  },
  {
    id: 4,
    title: "思い出ギャラリー",
    icon: "🖼",
    desc: "過去を飾る軌跡の部屋。歩みを振り返り、落ち込んだ時に自信を回復させます。",
    status: "coming",
  },
  {
    id: 5,
    title: "クリスタルアトリエ",
    icon: "❄️",
    desc: "性格診断の部屋。あなたの個性を美しい結晶の形として可視化します。",
    status: "coming",
  },
  {
    id: 6,
    title: "屋根裏プランニング",
    icon: "🌠",
    desc: "未来設計の部屋。望遠鏡で星を見ながら、将来の夢や目標を描きます。",
    status: "coming",
  },
  {
    id: 7,
    title: "秘密の地下室",
    icon: "🕯",
    desc: "弱さを吐き出すシェルター。誰にも言えない不安をそっと置いておける場所。",
    status: "coming",
  },
  {
    id: 8,
    title: "中庭のツリー",
    icon: "🎄",
    desc: "成長の象徴。日々の積み重ねがオーナメントとなり、ツリーを輝かせます。",
    status: "coming",
  },
  {
    id: 9,
    title: "トナカイの厩舎",
    icon: "🦌",
    desc: "強み（才能）を育てる場所。9頭のトナカイの個性を知り、伸ばしていきましょう。",
    status: "coming",
  },
  {
    id: 10,
    title: "キッチン",
    icon: "🍪",
    desc: "セルフケアの場所。心の栄養となる行動（クッキー）レシピを集めます。",
    status: "coming",
  },
];

const SantaBookModal = () => {
  const [isOpen, setIsOpen] = useState(false);
  const [spreadIndex, setSpreadIndex] = useState(0);

  const toggleBook = () => {
    setIsOpen(!isOpen);
    setSpreadIndex(0);
  };

  const nextPage = () => {
    if (spreadIndex < Math.ceil(guideContent.length / 2)) {
      setSpreadIndex(spreadIndex + 1);
    }
  };

  const prevPage = () => {
    if (spreadIndex > 0) {
      setSpreadIndex(spreadIndex - 1);
    }
  };

  const jumpToPage = (itemIndex) => {
    const targetSpread = Math.floor(itemIndex / 2) + 1;
    setSpreadIndex(targetSpread);
  };

  const renderSpread = () => {
    // === 目次ページ (Index) ===
    if (spreadIndex === 0) {
      return (
        <div className="flex flex-col md:flex-row h-full paper-texture font-picture-book rounded-lg">
          {/* 左側：イントロダクション＆挿絵 */}
          <div className="flex-1 p-8 border-b md:border-b-0 md:border-r border-[#D7CCC8] border-dashed flex flex-col items-center justify-center text-center">
            
            {/* ▼▼▼ 追加：挿絵エリア ▼▼▼ */}
            <div className="mb-6 w-48 h-48 md:w-56 md:h-56 bg-white p-2 rounded shadow-md transform rotate-2 border border-[#E0E0E0]">
               <img 
                 src="/images/guide/intro_illustration.png"  // ※ここに挿絵の画像を置く
                 alt="Introduction" 
                 className="w-full h-full object-cover rounded opacity-90 sepia-[0.1]"
                 onError={(e) => {
                    e.target.onerror = null; 
                    e.target.src = "https://placehold.co/400x400/FFF8E1/8D6E63?text=Santa+Illustration"; 
                 }}
               />
            </div>

            <h2 className="text-3xl font-bold text-[#B71C1C] mb-4 tracking-widest drop-shadow-sm">
              GUIDE BOOK
            </h2>
            
            <p className="text-[#5D4037] text-sm leading-loose font-bold">
              ようこそ、心の家、Heartory Homeへ<br/>
              右の目次から<br/>
              気になる部屋を探してみてください<br/>
              <span className="text-[#8D6E63] text-xs mt-2 block">
                サンタさんが夜な夜な執筆中... ✍️<br/>(まだ未完成です)
              </span>
            </p>
          </div>

          {/* 右側：目次リスト */}
          <div className="flex-1 p-6 overflow-y-auto custom-scrollbar">
            <h3 className="text-center font-bold text-[#3E2723] border-b-2 border-[#B71C1C] pb-2 mb-4 inline-block w-full">
              I N D E X
            </h3>
            <ul className="space-y-2">
              {guideContent.map((item, idx) => (
                <li key={item.id} className="text-sm">
                  <button 
                    onClick={() => jumpToPage(idx)}
                    className="w-full text-left flex items-center justify-between group hover:bg-[#FFE0B2]/50 p-2 rounded transition"
                  >
                    <span className="text-[#5D4037] font-bold truncate group-hover:text-[#B71C1C]">
                      {idx + 1}. {item.title}
                    </span>
                    <span className="text-xs text-[#8D6E63] border-b border-dotted border-[#8D6E63] flex-grow mx-2"></span>
                    <span className="text-xs text-[#B71C1C]">p.{Math.floor(idx/2)+1}</span>
                  </button>
                </li>
              ))}
            </ul>
          </div>
        </div>
      );
    }

    // === 詳細ページ（左右見開き） ===
    const startIndex = (spreadIndex - 1) * 2;
    const leftItem = guideContent[startIndex];
    const rightItem = guideContent[startIndex + 1];

    return (
      <div className="flex flex-col md:flex-row h-full">
        <DetailPage item={leftItem} pageNum={startIndex + 1} closeBook={toggleBook} />
        {/* 中央の影（本ののど） */}
        <div className="hidden md:block w-0 relative">
           <div className="absolute inset-y-0 -left-4 w-8 bg-gradient-to-r from-transparent via-[rgba(0,0,0,0.05)] to-transparent pointer-events-none z-10"></div>
           <div className="absolute inset-y-0 left-0 w-[1px] bg-[#D7CCC8]"></div>
        </div>
        <DetailPage item={rightItem} pageNum={startIndex + 2} closeBook={toggleBook} />
      </div>
    );
  };

  return (
    <>
      {fontStyle}

      {/* 🔴 トリガーボタン */}
      <button 
        onClick={toggleBook}
        className="fixed bottom-6 right-6 z-50 bg-[#B71C1C] text-[#FFD54F] p-4 rounded-full shadow-xl hover:scale-110 hover:bg-[#C62828] transition-all border-2 border-[#FFD54F] group"
        title="ガイドブックを開く"
      >
        <BookOpen size={24} className="group-hover:animate-bounce" />
      </button>

      {/* 📖 モーダル本体 */}
      {isOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-sm p-4 transition-opacity duration-300">
          <div className="relative bg-[#B71C1C] p-3 md:p-4 rounded-r-xl rounded-l-md shadow-2xl max-w-5xl w-full h-[85vh] flex flex-col border-l-8 border-[#8E1C1C]">
            <button 
              onClick={toggleBook}
              className="absolute -top-4 -right-4 bg-[#FFD54F] text-[#B71C1C] rounded-full p-2 shadow-lg hover:bg-white transition z-50 border-2 border-[#B71C1C]"
            >
              <X size={20} strokeWidth={3} />
            </button>

            {/* 紙の部分 */}
            <div className="bg-[#FFF8E1] flex-grow rounded shadow-inner relative overflow-hidden flex flex-col">
              <div className="flex-grow overflow-y-auto relative custom-scrollbar">
                 {/* しおり */}
                 <div className="absolute top-0 right-8 w-6 h-16 bg-[#C62828] rounded-b-lg shadow-md z-10 pointer-events-none opacity-90"></div>
                 {renderSpread()}
              </div>

              {/* ページ送りナビゲーション */}
              <div className="h-14 border-t border-[#D7CCC8] bg-[#FFF3E0] flex items-center justify-between px-6 select-none flex-shrink-0 font-picture-book">
                <button 
                  onClick={prevPage}
                  disabled={spreadIndex === 0}
                  className={`flex items-center gap-1 text-[#5D4037] font-bold hover:text-[#B71C1C] transition ${spreadIndex === 0 ? 'opacity-30 cursor-not-allowed' : ''}`}
                >
                  <ChevronLeft size={18} /> Prev
                </button>
                <div className="flex items-center gap-2">
                  {spreadIndex > 0 && (
                    <button 
                      onClick={() => setSpreadIndex(0)}
                      className="text-xs px-3 py-1 rounded-full bg-[#D7CCC8] text-[#5D4037] hover:bg-[#B71C1C] hover:text-white transition font-bold"
                    >
                      目次へ
                    </button>
                  )}
                  <span className="text-xs text-[#8D6E63]">
                    {spreadIndex === 0 ? "" : `${spreadIndex} / ${Math.ceil(guideContent.length/2)}`}
                  </span>
                </div>
                <button 
                  onClick={nextPage}
                  disabled={spreadIndex >= Math.ceil(guideContent.length / 2)}
                  className={`flex items-center gap-1 text-[#5D4037] font-bold hover:text-[#B71C1C] transition ${spreadIndex >= Math.ceil(guideContent.length / 2) ? 'opacity-30 cursor-not-allowed' : ''}`}
                >
                  Next <ChevronRight size={18} />
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

// === 詳細ページのコンポーネント（デザイン強化版） ===
const DetailPage = ({ item, pageNum, closeBook }) => {
  if (!item) return <div className="flex-1 paper-texture rounded-r-lg"></div>; 
  const isOpen = item.status === "open";

  return (
    <div className="flex-1 p-6 md:p-8 flex flex-col h-full relative paper-texture font-picture-book">
      {/* ヘッダー */}
      <div className="flex items-center gap-3 mb-6 border-b-2 border-dashed border-[#D7CCC8] pb-4">
        <div className={`text-3xl p-2 rounded-lg ${isOpen ? 'bg-[#FFECB3]' : 'bg-[#E0E0E0] grayscale opacity-50'}`}>
          {item.icon}
        </div>
        <div>
          <h3 className={`font-bold text-lg ${isOpen ? 'text-[#3E2723]' : 'text-[#757575]'}`}>{item.title}</h3>
          <span className={`text-[10px] px-2 py-0.5 rounded-full ${isOpen ? 'bg-[#C62828] text-white' : 'bg-[#9E9E9E] text-white'}`}>
            {isOpen ? "AVAILABLE" : "COMING SOON"}
          </span>
        </div>
      </div>

      {/* コンテンツエリア */}
      <div className="flex-grow overflow-y-auto pr-2 custom-scrollbar">
        <p className={`text-sm leading-relaxed font-medium mb-6 ${isOpen ? 'text-[#5D4037]' : 'text-[#9E9E9E]'}`}>
          {item.desc}
        </p>
        
        {/* ▼▼▼ ステップ（手順）がある場合の表示（ポラロイド風） ▼▼▼ */}
        {isOpen && item.steps && item.steps.length > 0 && (
          <div className="space-y-10 pb-8 px-1">
            <div className="text-center text-xs text-[#B71C1C] font-bold border-y border-dashed border-[#B71C1C] py-1 mb-6">
              ★ サンタの使いかたガイド ★
            </div>
            
            {item.steps.map((step, idx) => (
              <div key={idx} className={`relative bg-white p-3 pt-6 pb-4 rounded shadow-sm border border-[#EFEBE9] 
                 ${idx % 2 === 0 ? 'rotate-1' : '-rotate-1'} hover:rotate-0 transition-transform duration-300 hover:shadow-md hover:z-10`}>
                
                {/* マスキングテープ装飾 */}
                <div className="masking-tape"></div>

                {/* 画像エリア */}
                <div className="bg-[#FAFAFA] border border-[#E0E0E0] p-1 pb-4 mb-3 shadow-inner">
                  {step.img ? (
                    <img 
                      src={step.img} 
                      alt={step.title} 
                      className="w-full h-auto rounded-sm object-cover sepia-[0.15] hover:sepia-0 transition-all duration-500"
                      onError={(e) => {
                        e.target.onerror = null; 
                        e.target.src = "https://placehold.co/400x250/F5F5F5/CCCCCC?text=Image+Step+" + (idx+1); 
                      }}
                    />
                  ) : (
                    <div className="w-full h-32 bg-[#F5F5F5] flex items-center justify-center text-[#BDBDBD] text-xs">
                      No Image
                    </div>
                  )}
                </div>

                <h4 className="font-bold text-[#3E2723] text-sm mb-1 flex items-center gap-2">
                   <span className="bg-[#8D6E63] text-white w-5 h-5 rounded-full flex items-center justify-center text-[10px] shadow-sm">{idx + 1}</span>
                   {step.title}
                </h4>
                <p className="text-xs text-[#5D4037] leading-relaxed">
                  {step.text}
                </p>
              </div>
            ))}
          </div>
        )}

        {/* 画像がない場合のプレースホルダー（ステップがないページ用） */}
        {isOpen && (!item.steps || item.steps.length === 0) && (
          <div className="w-full h-32 rounded border-2 border-dashed border-[#D7CCC8] flex items-center justify-center bg-[#F5F5F5]">
             <span className="text-[#D7CCC8] text-xs font-bold">Image Area</span>
          </div>
        )}
      </div>

      {/* 遷移ボタン */}
      <div className="mt-4 pt-4 border-t border-dashed border-[#D7CCC8]">
        {isOpen ? (
          <a 
            href={item.path} 
            onClick={closeBook} 
            className="block w-full text-center py-2 rounded bg-[#C62828] text-white text-sm font-bold shadow hover:bg-[#B71C1C] transition hover:-translate-y-0.5"
          >
            この部屋へ行く &rarr;
          </a>
        ) : (
          <button disabled className="block w-full text-center py-2 rounded bg-[#E0E0E0] text-[#9E9E9E] text-sm font-bold cursor-not-allowed">準備中です...</button>
        )}
      </div>
    </div>
  );
};

export default SantaBookModal;