module Api
  module V1
    class EmotionLogsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_user!

      # GET /api/v1/emotion_logs
      # 暖炉メイン画面用
      def index
        fire_state = EmotionLog.current_fire_state(current_user)
        logs = current_user.emotion_logs.recent.limit(30)
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
        
        # 現在の連続日数 (Userモデルのメソッド)
        current_streak = current_user.emotion_streak

        # レベルと称号の計算
        level = calculate_level(total_logs)
        title = calculate_title(level)

        # バッジ判定 (獲得済みのものはDBから読み出し、新規獲得ならDBへ保存)
        badges = check_and_award_badges(user_logs, total_logs, magic_powder_count, current_streak)

        history = user_logs.recent.limit(30)

        render json: {
          stats: {
            total_logs: total_logs,
            magic_powder_count: magic_powder_count,
            level: level,
            title: title,
            streak: current_streak
          },
          badges: badges,
          history: history
        }
      end

      private

      def emotion_log_params
        params.require(:emotion_log).permit(:emotion, :body, :intensity, :magic_powder)
      end

      # レベル計算
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

      # バッジ判定＆DB保存ロジック
      def check_and_award_badges(logs, total, powder_total, current_streak)
        # バッジの獲得条件定義
        all_badge_defs = [
          # --- 継続系 (DB保存されるため、ストリークが途切れてもバッジは残る) ---
          { id: 'first_fire', name: '🕯️ 初点火', desc: '初めて薪をくべる。記念すべき最初の一歩です。', condition: -> { total >= 1 } },
          { id: '3_days', name: '🔥 3日の炎', desc: '3日連続で記録する。習慣の種が芽生え始めました。', condition: -> { current_streak >= 3 } },
          { id: 'weekly', name: '🔥🔥 ウィークリーマスター', desc: '7日連続で記録する。一週間、炎を絶やさなかった証です。', condition: -> { current_streak >= 7 } },
          { id: 'monthly', name: '🔥🔥🔥 マンスリーレジェンド', desc: '30日連続で記録する。あなたは真の火守り人です。', condition: -> { current_streak >= 30 } },
          { id: 'immortal', name: '🌟🔥🌟 不滅の炎', desc: '100日連続で記録する。炎はもはやあなたの生活の一部です。', condition: -> { current_streak >= 100 } },

          # --- 感情の多様性 ---
          { id: 'explorer', name: '🎭 感情の探求者', desc: '5種類の異なる感情を記録する。', condition: -> { logs.select(:emotion).distinct.count >= 5 } },
          { id: 'master', name: '🌈 エモーションマスター', desc: '全種類の感情を記録する。', condition: -> { logs.select(:emotion).distinct.count >= 10 } },

          # --- 魔法の粉 ---
          { id: 'first_magic', name: '✨ はじめての錬金術', desc: '初めて魔法の粉を使う。', condition: -> { powder_total >= 1 } },
          { id: 'apprentice', name: '🔮 錬金術師の弟子', desc: '魔法の粉を10回使用する。', condition: -> { powder_total >= 10 } },
          { id: 'master_alchemist', name: '💫 マスターアルケミスト', desc: '魔法の粉を50回使用する。', condition: -> { powder_total >= 50 } },

          # --- 薪の本数 ---
          { id: '50_logs', name: '🪵 初めての50本', desc: '合計50本の薪をくべる。', condition: -> { total >= 50 } },
          { id: '100_logs', name: '🪵🪵 百薪達成', desc: '合計100本の薪をくべる。', condition: -> { total >= 100 } },
          
          # --- 時間帯 ---
          { id: 'night_owl', name: '🌙 夜更かしの炎', desc: '深夜0時〜4時に記録する。', condition: -> { 
              logs.order(created_at: :desc).limit(100).any? { |l| l.created_at.hour >= 0 && l.created_at.hour < 4 } 
            } 
          },
          { id: 'early_bird', name: '🌅 朝の儀式', desc: '午前4時〜6時に記録する。', condition: -> { 
              logs.order(created_at: :desc).limit(100).any? { |l| l.created_at.hour >= 4 && l.created_at.hour < 6 } 
            } 
          }
        ]

        # 1. ユーザーが既にDBに持っているバッジIDリストを取得
        earned_badge_ids = current_user.user_badges.pluck(:badge_id)
        result_badges = []

        all_badge_defs.each do |badge_def|
          is_earned = false

          if earned_badge_ids.include?(badge_def[:id])
            # A. 既にDBにある場合 -> 獲得済みとする (再計算しないので途切れてもOK)
            is_earned = true
          else
            # B. 持っていない場合 -> 条件チェック
            if badge_def[:condition].call
              # 条件達成！ -> DBに保存して永続化する
              current_user.user_badges.create(badge_id: badge_def[:id], earned_at: Time.current)
              is_earned = true
            end
          end

          result_badges << {
            id: badge_def[:id],
            name: badge_def[:name],
            desc: badge_def[:desc],
            earned: is_earned
          }
        end

        result_badges
      end
    end
  end
end
