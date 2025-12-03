# このスクリプトは既存のデータを削除せず、
# 「サンタの書斎」と「航海日誌」に必要なマスターデータのみを安全に追加・更新します。

puts "🎅 サンタの書斎：データの安全な追加を開始します..."

# ==========================================
# 1. 価値観パズル (ValueCategory & ValueCard)
# ==========================================
puts "🧩 価値観パズルのデータをチェック中..."

categories_data = [
  {
    name: '🎓 学び・成長',
    theme_color: '#4F46E5', # Indigo
    icon_key: 'book',
    cards: [
      { name: '好奇心', description: '新しいことを知るワクワク、「なぜ？」を追求したい' },
      { name: '達成感', description: 'できなかったことができる喜び、成長を実感したい' },
      { name: '自律性', description: '自分のペースで進む、自分で決めて学びたい' },
      { name: '深さ', description: '一つのことを深く掘り下げる、本質を理解したい' },
      { name: '広さ', description: '様々なことに触れる、幅広い知識を得たい' },
      { name: '実践', description: '学んだことをすぐ使う、体験を通して学びたい' },
      { name: '継続', description: 'コツコツ積み重ねる、習慣として続けたい' }
    ]
  },
  {
    name: '💼 仕事・キャリア',
    theme_color: '#0EA5E9', # Sky Blue
    icon_key: 'briefcase',
    cards: [
      { name: 'やりがい', description: '意味のある仕事、心から打ち込めることをしたい' },
      { name: '成果', description: '目に見える結果を出す、達成の喜びを感じたい' },
      { name: '挑戦', description: '難しい課題に取り組む、自分の限界を超えたい' },
      { name: '創造', description: '新しいものを生み出す、アイデアを形にしたい' },
      { name: '協働', description: '仲間と力を合わせる、チームで成し遂げたい' },
      { name: '自由', description: '働く時間や場所を選べる、自分らしく働きたい' },
      { name: '貢献', description: '誰かの役に立つ、社会に価値を提供したい' }
    ]
  },
  {
    name: '❤️ 人間関係',
    theme_color: '#E11D48', # Rose
    icon_key: 'users',
    cards: [
      { name: 'つながり', description: '人と深く関わる、心を通わせたい' },
      { name: '信頼', description: '信頼し合える関係、安心して本音を話せる' },
      { name: '共感', description: '相手の気持ちを理解する、寄り添いたい' },
      { name: '楽しさ', description: '一緒に笑う、楽しい時間を過ごしたい' },
      { name: '支え合い', description: '助け合う、困った時に頼り頼られたい' },
      { name: '尊重', description: '違いを認め合う、互いの個性を大切にしたい' },
      { name: '居場所', description: '自分らしくいられる場所、帰れるコミュニティがほしい' }
    ]
  },
  {
    name: '🏠 家族',
    theme_color: '#F97316', # Orange
    icon_key: 'home',
    cards: [
      { name: '愛情', description: '家族を愛する、愛される、大切にしたい' },
      { name: '安心', description: '家が安全な場所、ホッとできる空間がほしい' },
      { name: '時間', description: '家族と過ごす時間、一緒にいることを大切にしたい' },
      { name: '支え', description: '家族を支える、家族に支えられたい' },
      { name: '対話', description: '家族と話す、理解し合いたい' },
      { name: '成長', description: '家族の成長を見守る、共に育ちたい' },
      { name: '思い出', description: '家族との思い出を作る、楽しい時間を重ねたい' }
    ]
  },
  {
    name: '💪 健康・身体',
    theme_color: '#16A34A', # Green
    icon_key: 'leaf',
    cards: [
      { name: '活力', description: 'エネルギッシュでいたい、元気に過ごしたい' },
      { name: 'バランス', description: '心身のバランス、無理なく健やかでいたい' },
      { name: 'リフレッシュ', description: '体を動かしてスッキリ、気分転換したい' },
      { name: 'ケア', description: '自分を大切にする、体調を整えたい' },
      { name: '心の健康', description: 'ストレスと上手く付き合う、穏やかでいたい' },
      { name: '長く元気', description: '将来も健康でいたい、人生を楽しみ続けたい' },
      { name: '自然', description: '外で過ごす、自然の中で体を動かしたい' }
    ]
  },
  {
    name: '🎨 創造・表現',
    theme_color: '#9333EA', # Purple
    icon_key: 'palette',
    cards: [
      { name: '独創性', description: 'オリジナルを生み出す、自分だけのものを作りたい' },
      { name: '美しさ', description: '美しいものを作る、見た目にもこだわりたい' },
      { name: '表現', description: '自分の内側を形にする、思いを伝えたい' },
      { name: '完成', description: '最後まで作り上げる、形にする喜びを感じたい' },
      { name: '探求', description: '試行錯誤を楽しむ、新しい方法を試したい' },
      { name: '技術', description: '技を磨く、丁寧に作り上げたい' },
      { name: '感動', description: '人の心を動かす、誰かに響くものを作りたい' }
    ]
  },
  {
    name: '🌍 社会貢献',
    theme_color: '#0D9488', # Teal
    icon_key: 'globe',
    cards: [
      { name: '役に立つ', description: '誰かの困りごとを解決する、助けたい' },
      { name: 'より良い社会', description: '世の中を良くする、問題を改善したい' },
      { name: '教える', description: '知識や経験を伝える、誰かの学びを支えたい' },
      { name: '公平', description: '不公平をなくす、みんなに機会があってほしい' },
      { name: '環境', description: '地球を守る、未来の世代のために行動したい' },
      { name: '弱者支援', description: '困難な状況の人に寄り添う、支えたい' },
      { name: '次世代', description: '後世に良い影響を残す、未来につなぎたい' }
    ]
  },
  {
    name: '🎮 遊び・余暇',
    theme_color: '#EAB308', # Gold
    icon_key: 'sparkles',
    cards: [
      { name: '楽しさ', description: '純粋に楽しむ、笑って過ごしたい' },
      { name: '自由', description: '何も考えない時間、縛られずに過ごしたい' },
      { name: '冒険', description: '新しい場所や体験、未知を楽しみたい' },
      { name: 'リラックス', description: 'ゆったりする、心と体を休めたい' },
      { name: '没頭', description: '好きなことに集中する、時間を忘れて楽しみたい' },
      { name: '仲間と遊ぶ', description: '友達と過ごす、一緒に楽しい時間を作りたい' },
      { name: '何もしない', description: '生産性から離れる、無駄な時間を楽しみたい' }
    ]
  }
]

categories_data.each do |cat_data|
  # 名前で検索し、なければ作成、あれば更新（安全策）
  category = ValueCategory.find_or_initialize_by(name: cat_data[:name])
  category.theme_color = cat_data[:theme_color]
  category.icon_key = cat_data[:icon_key]
  category.save!
  
  print "☁️ #{category.name} "

  cat_data[:cards].each do |card_data|
    card = category.value_cards.find_or_initialize_by(name: card_data[:name])
    card.description = card_data[:description]
    card.save!
    print "🧩"
  end
  puts ""
end

# ==========================================
# 2. 航海日誌 (Magic Book) の質問
# ==========================================
puts "📖 航海日誌の質問をチェック中..."

questions = [
  { cat: 'roots', body: "子供の頃、時間を忘れて夢中になった遊びは何ですか？" },
  { cat: 'roots', body: "あなたの人生で「最高の決断」だったと思うことは何ですか？" },
  { cat: 'roots', body: "これまでの人生で、一番感動した瞬間はいつですか？" },
  { cat: 'roots', body: "一番辛かった経験から、あなたが学んだことは何ですか？" },
  { cat: 'roots', body: "あなたが「自分らしくいられる」と感じるのは、どんな時ですか？" },
  { cat: 'values', body: "あなたが「許せない」と感じる他人の行動は何ですか？（その裏に大切な価値観があります）" },
  { cat: 'values', body: "憧れている人や尊敬する人は誰ですか？その人のどんなところに惹かれますか？" },
  { cat: 'values', body: "友人や家族から、よく褒められるあなたの長所は何ですか？" },
  { cat: 'values', body: "もしお金の心配が一切ないとしたら、毎日何をしていたいですか？" },
  { cat: 'values', body: "もし魔法が一つだけ使えるとしたら、何を叶えますか？" },
  { cat: 'reflection', body: "すべての時期（過去・現在・未来）で選び続けている「変わらない価値観」はありますか？それはなぜ大切なのでしょう？" },
  { cat: 'reflection', body: "過去には大切だったけれど、今は手放した価値観はありますか？その変化は何を意味していますか？" },
  { cat: 'reflection', body: "未来で大切にしたい価値観を実現するために、今の生活や仕事で変える必要があることは何ですか？" },
  { cat: 'reflection', body: "選んだ価値観を日常で実現するために、明日からどんな小さな行動を起こせそうですか？" },
  { cat: 'reflection', body: "過去から未来への価値観の変化を一つの物語にするなら、どんなタイトルをつけますか？" },
  { cat: 'vision', body: "今の自分に足りないと感じているもの、もっと欲しいものは何ですか？" },
  { cat: 'vision', body: "逆に、今の人生ですでに「十分に持っている」と感じるものは何ですか？" },
  { cat: 'vision', body: "5年後の未来、あなたの隣には誰がいて、どんな会話をしていて欲しいですか？" },
  { cat: 'vision', body: "人生の最期に「あぁ、良い人生だった」と言うために、絶対にやっておきたいことは？" },
  { cat: 'vision', body: "サンタクロースが、今のあなたに「一つだけ助言」をくれるとしたら、何と言うと思いますか？" }
]

questions.each.with_index(1) do |q, i|
  # 質問文で検索し、なければ作成
  question = ReflectionQuestion.find_or_initialize_by(body: q[:body])
  question.position = i
  question.category = q[:cat]
  question.save!
end

puts "✨ データの追加が完了しました！"
puts "   - 価値観カテゴリー数: #{ValueCategory.count}"
puts "   - 価値観カード数: #{ValueCard.count}"
puts "   - 航海日誌の質問数: #{ReflectionQuestion.count}"