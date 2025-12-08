import React, { useState, useEffect } from 'react';
import { X, ChevronLeft, ChevronRight, BookOpen } from 'lucide-react';

// ▼▼▼ デザイン用スタイル定義 ▼▼▼
const fontStyle = (
  <style>
    {`
      @import url('https://fonts.googleapis.com/css2?family=Zen+Maru+Gothic:wght@500;700&display=swap');
      
      .font-picture-book {
        font-family: 'Zen Maru Gothic', sans-serif;
      }
      
      .paper-texture {
        background-color: #fffbf0;
        background-image: radial-gradient(circle, #fffbf0 0%, #fff8e1 90%, #faeec7 100%);
      }

      /* クリスマスストライプテープ */
      .masking-tape {
        position: absolute;
        top: -12px;
        left: 50%;
        transform: translateX(-50%) rotate(-1.5deg);
        width: 100px;
        height: 28px;
        background-image: repeating-linear-gradient(
          -45deg,
          rgba(211, 47, 47, 0.85) 0px,
          rgba(211, 47, 47, 0.85) 10px,
          rgba(253, 216, 53, 0.9) 10px,
          rgba(253, 216, 53, 0.9) 12px,
          rgba(56, 142, 60, 0.85) 12px,
          rgba(56, 142, 60, 0.85) 30px,
          rgba(253, 216, 53, 0.9) 30px,
          rgba(253, 216, 53, 0.9) 33px
        );
        border-left: 2px dotted rgba(255,255,255,0.8);
        border-right: 2px dotted rgba(255,255,255,0.8);
        box-shadow: 0 2px 4px rgba(0,0,0,0.15);
        z-index: 10;
        opacity: 0.95;
      }

      /* スマホ用の調整 */
      @media (max-width: 640px) {
        .masking-tape {
          width: 70px;
          height: 20px;
          top: -8px;
        }
      }
    `}
  </style>
);

// === 📖 ガイドブックのデータ設定 ===
const guideContent = [
  // ----------------------------------------------------
  // Page 1　ギフトホール
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
  // Page 2　暖炉のリビング
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
  // Page 3: サンタの書斎
  // ----------------------------------------------------
  {
    id: 3,
    title: "サンタの書斎",
    icon: "📜",
    desc: "ここは、人生の羅針盤を見つける場所。56個の星（価値観）から、あなただけの星座を描きましょう。",
    status: "open",
    path: "/santa-study",
    steps: [
      {
        title: "書斎の入り口",
        text: "まずは「価値観の地図」を開いて星を探しに行くか、「心の航海日誌」で20の自分への問いに向き合うかを選びましょう。「星空の記録」から過去にあなたが選択した価値観を振り返ることができます。",
        img: "/images/guide/study_01_menu.png",
        img2: "/images/guide/study_01_sub.png" // ★追加：2枚目の画像パス
      },
      {
        title: "価値観の地図（星空のパズル）",
        text: "夜空に浮かぶ56個の価値観の中から、今のあなたにとって大切なものを最大10個まで選びます。星をクリックし、「この価値観を星として登録する」ボタンを押して価値観を登録しましょう。「過去・現在・未来」のタブを切り替えて、時系列で価値観の変化を見つめることもできます。",
        img: "/images/guide/study_02_map.png"
      },
      {
        title: "星座の完成",
        text: "星を選んで「決定して振り返る」を押すと、あなたの価値観の星空が完成します。この星空は保存するか空をリセットするかを選ぶことができます。",
        img: "/images/guide/study_03_complete.png"
      },
      {
        title: "価値観の共有",
        text: "完成した価値観リストは、「Xでシェア」から共有、画像として保存することもできます。あなたの大切な価値観を仲間にも伝えてみましょう！",
        img: "/images/guide/study_04_share.png"
      },
      {
        title: "心の航海日誌",
        text: "心の航海日誌では20の深い問いかけがあなたを待っています。答えを書き記すことで、自分の軸がより明確になるでしょう。ページを移動すると回答は自動で保存されます",
        img: "/images/guide/study_05_log.png"
      },
    ]
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
  const [pageIndex, setPageIndex] = useState(0); // 0: Index, 1~10: Content Pages
  const [isMobile, setIsMobile] = useState(false);

  // スマホ判定ロジック
  useEffect(() => {
    const checkMobile = () => setIsMobile(window.innerWidth < 768);
    checkMobile();
    window.addEventListener('resize', checkMobile);
    return () => window.removeEventListener('resize', checkMobile);
  }, []);

  const toggleBook = () => {
    setIsOpen(!isOpen);
    setPageIndex(0); // 閉じるたびに目次に戻す
  };

  const nextPage = () => {
    if (pageIndex < guideContent.length) {
      // スマホなら1ページ、PCなら2ページ進む（ただし上限は超えない）
      const increment = isMobile ? 1 : 2;
      setPageIndex(Math.min(pageIndex + increment, guideContent.length));
    }
  };

  const prevPage = () => {
    if (pageIndex > 0) {
      // スマホなら1ページ、PCなら2ページ戻る（ただし0未満にはならない）
      const decrement = isMobile ? 1 : 2;
      setPageIndex(Math.max(pageIndex - decrement, 0));
    }
  };

  const jumpToPage = (targetContentIndex) => {
    // コンテンツID（0始まり）からページ番号（1始まり）へ
    // PCの場合は奇数ページ（見開きの左側）に合わせる
    let targetPage = targetContentIndex + 1;
    if (!isMobile && targetPage % 2 === 0) {
      targetPage -= 1; // 偶数ページなら左側の奇数ページに寄せる
    }
    setPageIndex(targetPage);
  };

  // PCでの見開き計算用
  // pageIndexが 1 or 2 の時 -> Spread 1 (Content 0 & 1)
  const spreadStartContentIndex = Math.floor((pageIndex - 1) / 2) * 2;

  const renderContent = () => {
    // === 目次 (Index) ===
    if (pageIndex === 0) {
      return (
        <div className="flex flex-col md:flex-row h-full paper-texture font-picture-book rounded-lg overflow-hidden">
          {/* 左側：イントロダクション */}
          <div className="flex-1 p-6 md:p-8 border-b md:border-b-0 md:border-r border-[#D7CCC8] border-dashed flex flex-col items-center justify-center text-center">
            <div className="mb-4 md:mb-6 w-32 h-32 md:w-56 md:h-56 bg-white p-2 rounded shadow-md transform rotate-2 border border-[#E0E0E0]">
               <img 
                 src="/images/guide/intro_illustration.png"
                 alt="Introduction" 
                 className="w-full h-full object-cover rounded opacity-90 sepia-[0.1]"
                 onError={(e) => {
                    e.target.onerror = null; 
                    e.target.src = "https://placehold.co/400x400/FFF8E1/8D6E63?text=Santa+Illustration"; 
                 }}
               />
            </div>
            <h2 className="text-2xl md:text-3xl font-bold text-[#B71C1C] mb-2 md:mb-4 tracking-widest drop-shadow-sm">
              GUIDE BOOK
            </h2>
            <p className="text-[#5D4037] text-xs md:text-sm leading-loose font-bold">
              ようこそ、心の家、Heartory Homeへ<br/>
              {isMobile ? "下" : "右"}の目次から<br/>
              気になる部屋を探してみてください<br/>
              <span className="text-[#8D6E63] text-[10px] md:text-xs mt-2 block">
                サンタさんが夜な夜な執筆中... ✍️<br/>(まだ未完成です)
              </span>
            </p>
          </div>

          {/* 右側：目次リスト */}
          <div className="flex-1 p-4 md:p-6 overflow-y-auto custom-scrollbar">
            <h3 className="text-center font-bold text-[#3E2723] border-b-2 border-[#B71C1C] pb-2 mb-4 inline-block w-full text-sm md:text-base">
              I N D E X
            </h3>
            <ul className="space-y-1 md:space-y-2">
              {guideContent.map((item, idx) => (
                <li key={item.id} className="text-xs md:text-sm">
                  <button 
                    onClick={() => jumpToPage(idx)}
                    className="w-full text-left flex items-center justify-between group hover:bg-[#FFE0B2]/50 p-2 rounded transition"
                  >
                    <span className="text-[#5D4037] font-bold truncate group-hover:text-[#B71C1C]">
                      {idx + 1}. {item.title}
                    </span>
                    <span className="text-[10px] md:text-xs text-[#8D6E63] border-b border-dotted border-[#8D6E63] flex-grow mx-2"></span>
                    <span className="text-[10px] md:text-xs text-[#B71C1C]">p.{idx + 1}</span>
                  </button>
                </li>
              ))}
            </ul>
          </div>
        </div>
      );
    }

    // === スマホ表示：1ページのみ表示 ===
    if (isMobile) {
      const item = guideContent[pageIndex - 1]; // pageIndex 1 -> guideContent[0]
      return (
        <div className="h-full">
          <DetailPage item={item} closeBook={toggleBook} />
        </div>
      );
    }

    // === PC表示：見開き2ページ表示 ===
    // spreadStartContentIndex は pageIndex から計算済み
    const leftItem = guideContent[spreadStartContentIndex];
    const rightItem = guideContent[spreadStartContentIndex + 1];

    return (
      <div className="flex h-full overflow-hidden">
        <div className="flex-1 h-full">
          <DetailPage item={leftItem} closeBook={toggleBook} />
        </div>
        
        {/* 中央の影（本ののど） */}
        <div className="w-0 relative">
           <div className="absolute inset-y-0 -left-4 w-8 bg-gradient-to-r from-transparent via-[rgba(0,0,0,0.05)] to-transparent pointer-events-none z-10"></div>
           <div className="absolute inset-y-0 left-0 w-[1px] bg-[#D7CCC8]"></div>
        </div>

        <div className="flex-1 h-full">
          <DetailPage item={rightItem} closeBook={toggleBook} />
        </div>
      </div>
    );
  };

  return (
    <>
      {fontStyle}

      {/* 🔴 トリガーボタン */}
      <button 
        onClick={toggleBook}
        className="fixed bottom-4 right-4 md:bottom-6 md:right-6 z-50 bg-[#B71C1C] text-[#FFD54F] p-3 md:p-4 rounded-full shadow-xl hover:scale-110 hover:bg-[#C62828] transition-all border-2 border-[#FFD54F] group"
        title="ガイドブックを開く"
      >
        <BookOpen size={20} className="md:w-6 md:h-6 group-hover:animate-bounce" />
      </button>

      {/* 📖 モーダル本体 */}
      {isOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-sm p-2 md:p-4 transition-opacity duration-300">
          <div className="relative bg-[#B71C1C] p-2 md:p-4 rounded-md md:rounded-r-xl md:rounded-l-md shadow-2xl max-w-5xl w-full h-[90vh] md:h-[85vh] flex flex-col border-l-4 md:border-l-8 border-[#8E1C1C]">
            <button 
              onClick={toggleBook}
              className="absolute -top-3 -right-3 md:-top-4 md:-right-4 bg-[#FFD54F] text-[#B71C1C] rounded-full p-1.5 md:p-2 shadow-lg hover:bg-white transition z-50 border-2 border-[#B71C1C]"
            >
              <X size={16} className="md:w-5 md:h-5" strokeWidth={3} />
            </button>

            {/* 紙の部分 */}
            <div className="bg-[#FFF8E1] flex-grow rounded shadow-inner relative overflow-hidden flex flex-col">
              <div className="flex-grow overflow-y-auto relative custom-scrollbar">
                 <div className="absolute top-0 right-4 md:right-8 w-4 md:w-6 h-12 md:h-16 bg-[#C62828] rounded-b-lg shadow-md z-10 pointer-events-none opacity-90"></div>
                 {renderContent()}
              </div>

              {/* フッター（ページ送り） */}
              <div className="h-12 md:h-14 border-t border-[#D7CCC8] bg-[#FFF3E0] flex items-center justify-between px-4 md:px-6 select-none flex-shrink-0 font-picture-book">
                <button 
                  onClick={prevPage}
                  disabled={pageIndex === 0}
                  className={`flex items-center gap-1 text-[#5D4037] font-bold text-xs md:text-base hover:text-[#B71C1C] transition ${pageIndex === 0 ? 'opacity-30 cursor-not-allowed' : ''}`}
                >
                  <ChevronLeft size={16} className="md:w-[18px]" /> Prev
                </button>
                <div className="flex items-center gap-2">
                  {pageIndex > 0 && (
                    <button 
                      onClick={() => setPageIndex(0)}
                      className="text-[10px] md:text-xs px-2 md:px-3 py-1 rounded-full bg-[#D7CCC8] text-[#5D4037] hover:bg-[#B71C1C] hover:text-white transition font-bold"
                    >
                      目次
                    </button>
                  )}
                  {/* PCでは見開き番号、スマホではページ番号を表示 */}
                  <span className="text-[10px] md:text-xs text-[#8D6E63]">
                    {pageIndex === 0 ? "" : 
                      isMobile 
                        ? `${pageIndex} / ${guideContent.length}` 
                        : `${Math.ceil(pageIndex/2)} / ${Math.ceil(guideContent.length/2)}`
                    }
                  </span>
                </div>
                <button 
                  onClick={nextPage}
                  // スマホなら最後のページ、PCなら最後の見開きで無効化
                  disabled={isMobile ? pageIndex >= guideContent.length : pageIndex >= guideContent.length - 1}
                  className={`flex items-center gap-1 text-[#5D4037] font-bold text-xs md:text-base hover:text-[#B71C1C] transition ${(isMobile ? pageIndex >= guideContent.length : pageIndex >= guideContent.length - 1) ? 'opacity-30 cursor-not-allowed' : ''}`}
                >
                  Next <ChevronRight size={16} className="md:w-[18px]" />
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

// === 詳細ページのコンポーネント（番号削除版） ===
const DetailPage = ({ item, closeBook }) => {
  if (!item) return <div className="flex-1 paper-texture md:rounded-r-lg min-h-[50vh]"></div>; 
  const isOpen = item.status === "open";

  return (
    <div className="flex-1 p-4 md:p-8 flex flex-col h-full relative paper-texture font-picture-book">
      
      {/* 🗑️ 右上のページ番号を削除しました */}
      
      {/* ヘッダー */}
      <div className="flex items-center gap-3 mb-4 md:mb-6 border-b-2 border-dashed border-[#D7CCC8] pb-3 md:pb-4">
        <div className={`text-2xl md:text-3xl p-1.5 md:p-2 rounded-lg ${isOpen ? 'bg-[#FFECB3]' : 'bg-[#E0E0E0] grayscale opacity-50'}`}>
          {item.icon}
        </div>
        <div>
          <h3 className={`font-bold text-base md:text-lg ${isOpen ? 'text-[#3E2723]' : 'text-[#757575]'}`}>{item.title}</h3>
          <span className={`text-[10px] px-2 py-0.5 rounded-full ${isOpen ? 'bg-[#C62828] text-white' : 'bg-[#9E9E9E] text-white'}`}>
            {isOpen ? "AVAILABLE" : "COMING SOON"}
          </span>
        </div>
      </div>

      {/* コンテンツエリア */}
      <div className="flex-grow pr-0 md:pr-2 overflow-y-auto custom-scrollbar">
        <p className={`text-xs md:text-sm leading-relaxed font-medium mb-6 ${isOpen ? 'text-[#5D4037]' : 'text-[#9E9E9E]'}`}>
          {item.desc}
        </p>
        
        {/* ステップ */}
        {isOpen && item.steps && item.steps.length > 0 && (
          <div className="space-y-6 md:space-y-10 pb-4 md:pb-8 px-1">
            <div className="text-center text-xs text-[#B71C1C] font-bold border-y border-dashed border-[#B71C1C] py-1 mb-4 md:mb-6">
              ★ サンタの使いかたガイド ★
            </div>
            
            {item.steps.map((step, idx) => (
              <div key={idx} className={`relative bg-white p-2 md:p-3 pt-5 md:pt-6 pb-3 md:pb-4 rounded shadow-sm border border-[#EFEBE9] 
                 ${idx % 2 === 0 ? 'rotate-1' : '-rotate-1'} hover:rotate-0 transition-transform duration-300`}>
                
                {/* マスキングテープ */}
                <div className="masking-tape"></div>

                {/* 画像エリア（修正版：2枚対応） */}
                <div className="bg-[#FAFAFA] border border-[#E0E0E0] p-1 pb-3 md:pb-4 mb-2 md:mb-3 shadow-inner">
                  {step.img2 ? (
                    /* ▼▼▼ 画像が2枚ある場合：横並び表示 ▼▼▼ */
                    <div className="grid grid-cols-2 gap-1">
                      <img 
                        src={step.img} 
                        alt={step.title} 
                        className="w-full h-24 md:h-32 rounded-sm object-cover border border-[#EEEEEE] sepia-[0.15] hover:sepia-0 transition-all duration-500"
                        onError={(e) => { e.target.onerror = null; e.target.src = "https://placehold.co/200x150/F5F5F5/CCCCCC?text=Image+1"; }}
                      />
                      <img 
                        src={step.img2} 
                        alt={step.title + " 2"} 
                        className="w-full h-24 md:h-32 rounded-sm object-cover border border-[#EEEEEE] sepia-[0.15] hover:sepia-0 transition-all duration-500"
                        onError={(e) => { e.target.onerror = null; e.target.src = "https://placehold.co/200x150/F5F5F5/CCCCCC?text=Image+2"; }}
                      />
                    </div>
                  ) : step.img ? (
                    /* ▼▼▼ 画像が1枚の場合：通常表示 ▼▼▼ */
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
                    /* ▼▼▼ 画像がない場合 ▼▼▼ */
                    <div className="w-full h-24 md:h-32 bg-[#F5F5F5] flex items-center justify-center text-[#BDBDBD] text-xs">
                      No Image
                    </div>
                  )}
                </div>

                <h4 className="font-bold text-[#3E2723] text-xs md:text-sm mb-1 flex items-center gap-2">
                   <span className="bg-[#8D6E63] text-white w-4 h-4 md:w-5 md:h-5 rounded-full flex items-center justify-center text-[8px] md:text-[10px] shadow-sm">{idx + 1}</span>
                   {step.title}
                </h4>
                <p className="text-[10px] md:text-xs text-[#5D4037] leading-relaxed">
                  {step.text}
                </p>
              </div>
            ))}
          </div>
        )}

        {/* プレースホルダー */}
        {isOpen && (!item.steps || item.steps.length === 0) && (
          <div className="w-full h-24 md:h-32 rounded border-2 border-dashed border-[#D7CCC8] flex items-center justify-center bg-[#F5F5F5]">
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
            className="block w-full text-center py-2 rounded bg-[#C62828] text-white text-xs md:text-sm font-bold shadow hover:bg-[#B71C1C] transition hover:-translate-y-0.5"
          >
            この部屋へ行く &rarr;
          </a>
        ) : (
          <button disabled className="block w-full text-center py-2 rounded bg-[#E0E0E0] text-[#9E9E9E] text-xs md:text-sm font-bold cursor-not-allowed">準備中です...</button>
        )}
      </div>
    </div>
  );
};

export default SantaBookModal;