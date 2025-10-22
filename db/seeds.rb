require 'digest/sha1' 

# ----------------------------------------------------
# 開発環境での既存データクリア
# ----------------------------------------------------
if Rails.env.development?
  if defined?(TemplateItem)
    TemplateItem.destroy_all 
    puts "TemplateItem データをクリアしました。"
  end
  if defined?(Template)
    Template.destroy_all 
    puts "Template データをクリアしました。"
  end
  # ユーザーデータもクリア
  User.destroy_all
  
  puts "既存のユーザーとテンプレートデータをクリアしました。"
end


# ----------------------------------------------------
# 管理者ユーザーの作成 (usernameを使用)
# ----------------------------------------------------
puts "管理者ユーザーの作成を開始..."

admin = User.find_or_create_by!(email: 'admin@anta-santa.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.username = 'システム管理者' 
  user.provider = 'email' 
  user.uid = Digest::SHA1.hexdigest(user.email) 
end
puts "管理者ユーザー (email: admin@anta-santa.com) を作成しました。"


# ----------------------------------------------------
# デフォルトテンプレートの作成 (モデル名: Templateを使用)
# ----------------------------------------------------
puts "デフォルト評価テンプレートの作成を開始..."

# Template モデルを使用
template = Template.create!(
  user: admin,
  title: '大人のサンタさん通知表 - 評価シート',
  description: 'エンジニアマインドと大人の基礎力から作成した評価テンプレート',
  is_public: true
)

# 大人の12の基礎力
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

# エンジニアマインド
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
    # TemplateItem モデルを使用
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

puts "デフォルトテンプレートを作成しました（#{template.template_items.count}項目）"

# ----------------------------------------------------
# 4. テストユーザーとデータの作成（動作確認用）
# ----------------------------------------------------
if User.count <= 1 # 管理者以外のユーザーがいない場合
  User.find_or_create_by!(email: 'tester1@example.com') do |user|
      user.username = 'テストユーザー1'
      user.password = 'password'
      user.password_confirmation = 'password'
  end
  
  User.find_or_create_by!(email: 'tester2@example.com') do |user|
      user.username = 'テストユーザー2'
      user.password = 'password'
      user.password_confirmation = 'password'
  end
  puts "テストユーザー2名を追加しました。"
end

puts "シードデータの投入が完了しました！"