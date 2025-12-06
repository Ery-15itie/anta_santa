module Api
  module V1
    class EmotionLogsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_user!

      # GET /api/v1/emotion_logs
      # 暖炉メイン画面用
      def index
        fire_state = EmotionLog.current_fire_state(current_user)
        logs = current_user.emotion_logs.recent.limit(30) # タイムライン用に多めに取得
        render json: { fire_state: fire_state, logs: logs }
      end

      # POST /api/v1/emotion_logs
      # 薪をくべる
      def create
        log = current_user.emotion_logs.build(emotion_log_params)
        if log.save
          fire_state = EmotionLog.current_fire_state(current_user)
          render json: { log: log, fire_state: fire_state }, status: :created
        else
          render json: { errors: log.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/emotion_logs/stats
      # 統計・実績画面用
      def stats
        user_logs = current_user.emotion_logs
        total_logs = user_logs.count
        magic_powder_count = user_logs.where.not(magic_powder: 0).count
        
        # ▼▼▼ 修正: モデルの高速計算メソッドを使用 ▼▼▼
        current_streak = current_user.emotion_streak

        # 1. レベル計算 (段階的ロジック)
        level = calculate_level(total_logs)
        
        # 2. 称号判定
        title = calculate_title(level)

        # 3. カード判定 (計算済みの streak を渡す)
        badges = calculate_badges(user_logs, total_logs, magic_powder_count, current_streak)

        history = user_logs.recent.limit(30)

        render json: {
          stats: {
            total_logs: total_logs,
            magic_powder_count: magic_powder_count,
            level: level,
            title: title,
            streak: current_streak # フロントエンド表示用にここにも含めておくと便利です
          },
          badges: badges,
          history: history
        }
      end

      private

      def emotion_log_params
        params.require(:emotion_log).permit(:emotion, :body, :intensity, :magic_powder)
      end

      # レベル計算 (Lv30まではサクサク、以降は徐々にハードに)
      def calculate_level(total_logs)
        level = 1
        phase1_cap = 150; rate1 = 5
        if total_logs <= phase1_cap
          return level + (total_logs / rate1)
        end
        level += (phase1_cap / rate1)
        remaining = total_logs - phase1_cap
        
        phase2_cap = 300; rate2 = 15
        if remaining <= phase2_cap
          return level + (remaining / rate2)
        end
        level += (phase2_cap / rate2)
        remaining -= phase2_cap

        rate3 = 30
        level += (remaining / rate3)
        return level
      end

      # 称号定義
      def calculate_title(level)
        case level
        when 1..4 then "心の火守り人"
        when 5..9 then "見習い火守"
        when 10..14 then "熟練の火守"
        when 15..19 then "炎の番人"
        when 20..29 then "炎の匠"
        when 30..39 then "灼熱の導師"
        when 40..49 then "永遠の火守"
        when 50..69 then "聖火の守護者"
        when 70..99 then "心の錬金術師"
        else "不滅の炎神"
        end
      end

      # カード判定ロジック
      # ▼▼▼ 修正: streak を引数で受け取るように変更 ▼▼▼
      def calculate_badges(logs, total, powder_total, streak)
        badges = []
        
        # ※以前の非効率な Rubyによる日付計算ロジックは削除しました

        # --- 継続系 ---
        badges << { id: 'first_fire', name: '🕯️ 初点火', desc: '初めて薪をくべる。記念すべき最初の一歩です。', earned: total >= 1 }
        badges << { id: '3_days', name: '🔥 3日の炎', desc: '3日連続で記録する。習慣の種が芽生え始めました。', earned: streak >= 3 }
        badges << { id: 'weekly', name: '🔥🔥 ウィークリーマスター', desc: '7日連続で記録する。一週間、炎を絶やさなかった証です。', earned: streak >= 7 }
        badges << { id: 'monthly', name: '🔥🔥🔥 マンスリーレジェンド', desc: '30日連続で記録する。あなたは真の火守り人です。', earned: streak >= 30 }
        badges << { id: 'immortal', name: '🌟🔥🌟 不滅の炎', desc: '100日連続で記録する。炎はもはやあなたの生活の一部です。', earned: streak >= 100 }

        # --- 感情の多様性 ---
        # NOTE: distinct count はDB側で行われるので高速です
        unique_emotions = logs.select(:emotion).distinct.count
        badges << { id: 'explorer', name: '🎭 感情の探求者', desc: '5種類の異なる感情を記録する。心の色彩に気づき始めました。', earned: unique_emotions >= 5 }
        badges << { id: 'master', name: '🌈 エモーションマスター', desc: '全種類の感情を記録する。全ての感情を受け入れる心が育っています。', earned: unique_emotions >= 10 }

        # --- 魔法の粉 ---
        badges << { id: 'first_magic', name: '✨ はじめての錬金術', desc: '初めて魔法の粉を使う。負の感情を美しく変える術を知りました。', earned: powder_total >= 1 }
        badges << { id: 'apprentice', name: '🔮 錬金術師の弟子', desc: '魔法の粉を10回使用する。昇華の技術が身についてきました。', earned: powder_total >= 10 }
        badges << { id: 'master_alchemist', name: '💫 マスターアルケミスト', desc: '魔法の粉を50回使用する。あなたは感情変容の達人です。', earned: powder_total >= 50 }

        # --- 薪の本数 ---
        badges << { id: '50_logs', name: '🪵 初めての50本', desc: '合計50本の薪をくべる。50の感情、あなたの歴史。', earned: total >= 50 }
        badges << { id: '100_logs', name: '🪵🪵 百薪達成', desc: '合計100本の薪をくべる。100の物語が暖炉に刻まれました。', earned: total >= 100 }

        # --- 時間帯 ---
        # 直近100件だけ取得して判定（全件ロードを防ぐためlimitを使用）
        recent_logs = logs.order(created_at: :desc).limit(100)
        has_night = recent_logs.any? { |l| l.created_at.hour >= 0 && l.created_at.hour < 4 }
        has_morning = recent_logs.any? { |l| l.created_at.hour >= 4 && l.created_at.hour < 6 }

        badges << { id: 'night_owl', name: '🌙 夜更かしの炎', desc: '深夜0時〜4時に記録する。静かな夜、心と向き合った証。', earned: has_night }
        badges << { id: 'early_bird', name: '🌅 朝の儀式', desc: '午前4時〜6時に記録する。朝一番に心を整える習慣。', earned: has_morning }

        badges
      end
    end
  end
end
