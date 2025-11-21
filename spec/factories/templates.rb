FactoryBot.define do
  factory :template do
    title { "サンタさん通知表" }
    association :user

    # テンプレート作成時に、評価項目（TemplateItem）も一緒に作る
    after(:create) do |template|
      create(:template_item, title: "行動力がすごい", category: "行動力", template: template)
      create(:template_item, title: "笑顔が素敵", category: "マインド", template: template)
    end
  end
end
