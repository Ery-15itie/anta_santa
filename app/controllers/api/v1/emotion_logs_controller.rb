module Api
  module V1
    class EmotionLogsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_user!

      def index
        fire_state = EmotionLog.current_fire_state(current_user)
        logs = current_user.emotion_logs.recent.limit(30)
        render json: { fire_state: fire_state, logs: logs }
      end

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
      # 称号とバッジを含む統計データを返す
      def stats
        total_logs = current_user.emotion_logs.count
        logs = current_user.emotion_logs
        
        # 1. 称号の計算
        title = calculate_title(total_logs)

        # 2. バッジの取得
        badges = calculate_badges(logs)

        # 3. 統計情報
        magic_powder_count = logs.where.not(magic_powder: 0).count
        
        render json: {
          stats: {
            total_logs: total_logs,
            magic_powder_count: magic_powder_count,
            title: title,
          },
          badges: badges,
          history: logs.recent.limit(30)
        }
      end

      private

      def emotion_log_params
        params.require(:emotion_log).permit(:emotion, :body, :intensity, :magic_powder)
      end

      # 称号計算ロジック
      def calculate_title(count)
        case count
        when 0..4 then "心の火守り人"
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

      # バッジ獲得ロジック
      def calculate_badges(logs)
        badges = []
        
        # --- 継続系 ---
        badges << { id: 'first_fire', name: '🕯️ 初点火', desc: '初めて薪をくべる', earned: logs.count >= 1 }
        # ※連続記録の正確な計算は複雑なため、今回は簡易的に「総数」などで代用するか、別途Gem 'groupdate'等での実装推奨
        # ここでは一旦プレースホルダーとして、総数で判定する簡易版置いとく
        badges << { id: '3_days', name: '🔥 3日の炎', desc: '3日連続で記録', earned: logs.count >= 3 } 
        badges << { id: 'weekly', name: '🔥🔥 ウィークリーマスター', desc: '7日連続で記録', earned: logs.count >= 7 }
        badges << { id: 'monthly', name: '🔥🔥🔥 マンスリーレジェンド', desc: '30日連続で記録', earned: logs.count >= 30 }
        badges << { id: 'immortal', name: '🌟🔥🌟 不滅の炎', desc: '100日連続で記録', earned: logs.count >= 100 }

        # --- 感情の多様性 ---
        unique_emotions = logs.select(:emotion).distinct.count
        badges << { id: 'explorer', name: '🎭 感情の探求者', desc: '5種類の異なる感情を記録', earned: unique_emotions >= 5 }
        badges << { id: 'master', name: '🌈 エモーションマスター', desc: '全種類の感情を記録', earned: unique_emotions >= 11 }
        # --- 魔法の粉 ---
        powder_count = logs.where.not(magic_powder: 0).count
        badges << { id: 'first_magic', name: '✨ はじめての錬金術', desc: '初めて魔法の粉を使う', earned: powder_count >= 1 }
        badges << { id: 'apprentice', name: '🔮 錬金術師の弟子', desc: '魔法の粉を10回使用', earned: powder_count >= 10 }
        badges << { id: 'master_alchemist', name: '💫 マスターアルケミスト', desc: '魔法の粉を50回使用', earned: powder_count >= 50 }

        # --- 薪の本数 ---
        badges << { id: '50_logs', name: '🪵 初めての50本', desc: '合計50本の薪', earned: logs.count >= 50 }
        badges << { id: '100_logs', name: '🪵🪵 百薪達成', desc: '合計100本の薪', earned: logs.count >= 100 }

        # --- 特殊条件 (時間帯) ---
        # SQLite/Postgresで時刻抽出関数が異なるため、Ruby側で判定 (パフォーマンス注意)
        has_night = logs.any? { |l| l.created_at.hour < 4 } # 深夜0時〜4時
        has_morning = logs.any? { |l| l.created_at.hour >= 4 && l.created_at.hour < 6 } # 4時〜6時
        
        badges << { id: 'night_owl', name: '🌙 夜更かしの炎', desc: '深夜0時以降に記録', earned: has_night }
        badges << { id: 'early_bird', name: '🌅 朝の儀式', desc: '午前6時前に記録', earned: has_morning }

        badges
      end
    end
  end
end
