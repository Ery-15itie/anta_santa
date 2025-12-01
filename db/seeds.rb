require 'digest/sha1'

puts "データの生成を開始します..."

# ==========================================
# 1. クリーニング処理 (全データ削除)
# ==========================================
puts "🧹 既存データのクリーニング中..."

# 外部キー制約に引っかからないよう、必ず「末端の子」から順に消す
# destroy_all ではなく delete_all を使い、高速かつ強制的に消去

# --- 新機能: 航海日誌 (Magic Book) ---
# まだモデルを作っていない段階で実行してもエラーにならないよう defined? でチェック
UserReflection.delete_all if defined?(UserReflection)
ReflectionQuestion.delete_all if defined?(ReflectionQuestion)

# --- 新機能: 価値観パズル ---
UserCardSelection.delete_all
ValueCard.delete_all
ValueCategory.delete_all

# --- 既存機能: 関連データ ---
# Userモデルに紐づくデータを全て消去
if defined?(Evaluation)
  Evaluation.delete_all
end

if defined?(Relationship)
  Relationship.delete_all
end

if defined?(EmotionLog)
  EmotionLog.delete_all
end

# --- 既存機能: 通知表機能 ---
if defined?(TemplateItem)
  TemplateItem.delete_all
end

if defined?(Template)
  Template.delete_all
end

# --- 全機能共通: ユーザー ---
# 全ての子要素が消えたので、最後にユーザーを安全に削除
User.delete_all

puts "🧹 クリーニング完了。"

# ==========================================
# 2. 共通ユーザーデータの作成
# ==========================================
puts "👤 ユーザーデータの作成中..."

# 管理者ユーザー
admin = User.find_or_create_by!(email: 'admin@anta-santa.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.username = 'システム管理者'
  user.provider = 'email'
  user.uid = Digest::SHA1.hexdigest(user.email)
end

# テストユーザー (動作確認用)
tester1 = User.find_or_create_by!(email: 'tester1@example.com') do |user|
  user.username = 'テストユーザー1'
  user.password = 'password'
  user.password_confirmation = 'password'
end

User.find_or_create_by!(email: 'tester2@example.com') do |user|
  user.username = 'テストユーザー2'
  user.password = 'password'
  user.password_confirmation = 'password'
end

puts "ユーザー作成完了 (Admin + Tester 2名)"


# ==========================================
# 3. 既存機能: 通知表テンプレートの作成
# ==========================================
puts "通知表テンプレートの作成中..."

# モデルが存在する場合のみ実行（念の為の安全策）
if defined?(Template)
  template = Template.create!(
    user: admin,
    title: '大人のサンタさん通知表 - 評価シート',
    description: 'エンジニアマインドと大人の基礎力から作成した評価テンプレート',
    is_public: true
  )

  # --- 大人の12の基礎力 ---
  basic_skills = [
    {
      category: '考える力',
      sub_category: '課題発見力',
      items: [
        '問題の本質を見抜いて指摘できていた',
        '改善すべき点を積極的に見つけていた',
        'なぜ？を大切にして深く考えていた'
      ]
    },
    {
      category: '考える力',
      sub_category: '計画力',
      items: [
        '目標に向けて段階的な計画を立てていた',
        '優先順位をつけて効率的に進めていた',
        '予想されるリスクを考慮して準備していた'
      ]
    },
    {
      category: '考える力',
      sub_category: '創造力',
      items: [
        '新しいアイデアやアプローチを提案していた',
        '既存の枠にとらわれない発想をしていた',
        '独創性のある解決策を考えていた'
      ]
    },
    {
      category: '行動する力',
      sub_category: '主体性',
      items: [
        '自分から率先して行動していた',
        '責任を持って最後までやり遂げていた',
        '指示を待たずに必要な作業に取り組んでいた'
      ]
    },
    {
      category: '行動する力',
      sub_category: '働きかけ力',
      items: [
        '周りの人を巻き込んで協力を得ていた',
        '積極的にコミュニケーションを取っていた',
        'チームのモチベーション向上に貢献していた'
      ]
    },
    {
      category: '行動する力',
      sub_category: '実行力',
      items: [
        '決めたことを確実に実行していた',
        '困難があっても諦めずに続けていた',
        '成果を出すために粘り強く取り組んでいた'
      ]
    },
    {
      category: 'チームで働く力',
      sub_category: '発信力',
      items: [
        '自分の考えを分かりやすく伝えていた',
        '相手の立場を考えた説明をしていた',
        '積極的に情報共有や報告をしていた'
      ]
    },
    {
      category: 'チームで働く力',
      sub_category: '傾聴力',
      items: [
        '相手の話を最後まで丁寧に聞いていた',
        '相手の気持ちや立場を理解しようとしていた',
        '質問上手で相手から情報を引き出していた'
      ]
    },
    {
      category: 'チームで働く力',
      sub_category: '柔軟性',
      items: [
        '状況の変化に素早く対応していた',
        '異なる意見を受け入れて考えを修正していた',
        '新しい環境や方法に順応していた'
      ]
    },
    {
      category: 'チームで働く力',
      sub_category: '情況把握力',
      items: [
        '周りの状況や雰囲気を適切に読んでいた',
        'チーム全体のことを考えて行動していた',
        '相手のニーズや期待を理解していた'
      ]
    },
    {
      category: 'チームで働く力',
      sub_category: '規律性',
      items: [
        'ルールや約束をしっかり守っていた',
        '時間を守って責任ある行動をしていた',
        '社会人としてのマナーを大切にしていた'
      ]
    },
    {
      category: 'チームで働く力',
      sub_category: 'ストレス耐性',
      items: [
        '困難な状況でも冷静に対処していた',
        'プレッシャーに負けずに力を発揮していた',
        '失敗を次に活かす前向きな姿勢を持っていた'
      ]
    }
  ]

  # --- エンジニアマインド ---
  engineer_skills = [
    {
      category: '学習・成長マインド',
      sub_category: '継続学習力',
      items: [
        '新しい技術やツールを積極的に学んでいた',
        '日々の学習を習慣化していた',
        '学んだことを実践で活用していた'
      ]
    },
    {
      category: '学習・成長マインド',
      sub_category: '好奇心・探究心',
      items: [
        '「なぜそうなるのか？」を追求していた',
        '新しい技術トレンドに関心を示していた',
        '深く掘り下げて理解しようとしていた'
      ]
    },
    {
      category: '学習・成長マインド',
      sub_category: '成長志向',
      items: [
        '自分のスキルアップに貪欲だった',
        '挑戦的な課題に積極的に取り組んでいた',
        'フィードバックを素直に受け入れて改善していた'
      ]
    },
    {
      category: '問題解決マインド',
      sub_category: '論理思考力',
      items: [
        '筋道立てて考えて説明していた',
        '根拠を示して判断していた',
        '複雑な問題を分解して整理していた'
      ]
    },
    {
      category: '問題解決マインド',
      sub_category: 'デバッグマインド',
      items: [
        'エラーや問題を粘り強く調査していた',
        '仮説を立てて検証する姿勢があった',
        '原因を特定するまで諦めなかった'
      ]
    },
    {
      category: '問題解決マインド',
      sub_category: '改善マインド',
      items: [
        'より良い方法を常に考えていた',
        '効率化や最適化を意識していた',
        '小さな改善も積極的に提案していた'
      ]
    },
    {
      category: '協働・共有マインド',
      sub_category: '知識共有力',
      items: [
        '学んだことを他の人と共有していた',
        '分かりやすくドキュメント化していた',
        '質問や相談に丁寧に答えていた'
      ]
    },
    {
      category: '協働・共有マインド',
      sub_category: 'チーム協調性',
      items: [
        'チームの目標達成を意識していた',
        '他のメンバーをサポートしていた',
        '建設的な意見交換ができていた'
      ]
    },
    {
      category: '協働・共有マインド',
      sub_category: 'メンタリングマインド',
      items: [
        '後輩や新人の成長を支援していた',
        '教えることで自分も学ぶ姿勢があった',
        '相手のレベルに合わせた指導をしていた'
      ]
    }
  ]

  position = 0
  (basic_skills + engineer_skills).each do |skill_group|
    skill_group[:items].each do |item_title|
      template.template_items.create!(
        title: item_title,
        category: skill_group[:category],
        sub_category: skill_group[:sub_category],
        item_type: 'checkbox',
        position: position,
        weight: 1
      )
      position += 1
    end
  end
  puts "📝 通知表テンプレート作成完了（#{template.template_items.count}項目）"
end

# ==========================================
# 4. 価値観パズル (サンタの書斎) の作成
# ==========================================
puts "価値観パズルの生成中..."

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
  category = ValueCategory.create!(
    name: cat_data[:name],
    theme_color: cat_data[:theme_color],
    icon_key: cat_data[:icon_key]
  )
  print "☁️ #{category.name} "

  cat_data[:cards].each do |card_data|
    category.value_cards.create!(
      name: card_data[:name],
      description: card_data[:description]
    )
    print "🧩"
  end
  puts ""
end

puts "🧩 価値観パズル作成完了"

# ==========================================
# 5. 航海日誌 (魔法の本) の質問作成
# ==========================================
puts " 航海日誌（質問）の生成中..."

# モデルが存在する場合のみ実行
if defined?(ReflectionQuestion)
  questions = [
    # --- Part 1: 人生のルーツを探る ---
    { cat: 'roots', body: "子供の頃、時間を忘れて夢中になった遊びは何ですか？" },
    { cat: 'roots', body: "あなたの人生で「最高の決断」だったと思うことは何ですか？" },
    { cat: 'roots', body: "これまでの人生で、一番感動した瞬間はいつですか？" },
    { cat: 'roots', body: "一番辛かった経験から、あなたが学んだことは何ですか？" },
    { cat: 'roots', body: "あなたが「自分らしくいられる」と感じるのは、どんな時ですか？" },

    # --- Part 2: 価値観の輪郭を捉える ---
    { cat: 'values', body: "あなたが「許せない」と感じる他人の行動は何ですか？（その裏に大切な価値観があります）" },
    { cat: 'values', body: "憧れている人や尊敬する人は誰ですか？その人のどんなところに惹かれますか？" },
    { cat: 'values', body: "友人や家族から、よく褒められるあなたの長所は何ですか？" },
    { cat: 'values', body: "もしお金の心配が一切ないとしたら、毎日何をしていたいですか？" },
    { cat: 'values', body: "もし魔法が一つだけ使えるとしたら、何を叶えますか？" },

    # --- Part 3: 価値観パズルの振り返り ---
    { cat: 'reflection', body: "すべての時期（過去・現在・未来）で選び続けている「変わらない価値観」はありますか？それはなぜ大切なのでしょう？" },
    { cat: 'reflection', body: "過去には大切だったけれど、今は手放した価値観はありますか？その変化は何を意味していますか？" },
    { cat: 'reflection', body: "未来で大切にしたい価値観を実現するために、今の生活や仕事で変える必要があることは何ですか？" },
    { cat: 'reflection', body: "選んだ価値観を日常で実現するために、明日からどんな小さな行動を起こせそうですか？" },
    { cat: 'reflection', body: "過去から未来への価値観の変化を一つの物語にするなら、どんなタイトルをつけますか？" },

    # --- Part 4: 未来への航海図 ---
    { cat: 'vision', body: "今の自分に足りないと感じているもの、もっと欲しいものは何ですか？" },
    { cat: 'vision', body: "逆に、今の人生ですでに「十分に持っている」と感じるものは何ですか？" },
    { cat: 'vision', body: "5年後の未来、あなたの隣には誰がいて、どんな会話をしていて欲しいですか？" },
    { cat: 'vision', body: "人生の最期に「あぁ、良い人生だった」と言うために、絶対にやっておきたいことは？" },
    { cat: 'vision', body: "サンタクロースが、今のあなたに「一つだけ助言」をくれるとしたら、何と言うと思いますか？" }
  ]

  questions.each.with_index(1) do |q, i|
    ReflectionQuestion.create!(
      body: q[:body], 
      position: i, 
      category: q[:cat]
    )
  end
  puts "📖 航海日誌の準備完了（#{ReflectionQuestion.count}問）"
else
  puts "⚠️ ReflectionQuestionモデルが見つからないため、航海日誌データはスキップされました。"
end

# ==========================================
# 完了
# ==========================================
puts "\n✨ 全データの投入が完了しました！"
puts "   - ユーザー数: #{User.count}"
if defined?(Template)
  puts "   - 通知表テンプレート: #{Template.count}件"
end
puts "   - 価値観カテゴリー数: #{ValueCategory.count}"
puts "   - 価値観カード数: #{ValueCard.count}"
if defined?(ReflectionQuestion)
  puts "   - 航海日誌の質問数: #{ReflectionQuestion.count}"
end
