import React, { useEffect, useState } from 'react';
import { fetchUserSelections } from '../../api/values';
import { ArrowLeft, Book, Clock, Star } from 'lucide-react';

const ReflectionsList = ({ onBack }) => {
  const [logs, setLogs] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadLogs = async () => {
      try {
        const res = await fetchUserSelections();
        // 振り返り(description)があるデータのみ抽出し、更新日時順にソート
        const history = res.data
          .filter(item => item.description && item.description.length > 0)
          .sort((a, b) => new Date(b.updated_at) - new Date(a.updated_at));
        setLogs(history);
      } catch (error) {
        console.error("日誌の読み込みに失敗しました", error);
      } finally {
        setLoading(false);
      }
    };
    loadLogs();
  }, []);

  return (
    <div className="fixed inset-0 z-[60] bg-[#0f172a]/95 backdrop-blur-xl flex flex-col items-center animate-fade-in overflow-hidden">
      
      {/* ヘッダー */}
      <div className="w-full max-w-4xl px-6 py-6 flex items-center justify-between border-b border-white/10">
        <h2 className="text-2xl font-bold text-yellow-100 flex items-center gap-3 font-serif">
          <Book className="text-yellow-500" />
          過去の航海日誌
        </h2>
        <button 
          onClick={onBack} 
          className="flex items-center gap-2 px-4 py-2 rounded-full bg-white/10 hover:bg-white/20 text-sm text-slate-300 transition-colors"
        >
          <ArrowLeft size={16} /> 星空に戻る
        </button>
      </div>

      {/* リストコンテンツ */}
      <div className="flex-1 w-full max-w-4xl overflow-y-auto p-6 pb-20">
        {loading ? (
          <div className="text-center mt-20 text-slate-400 animate-pulse">ページをめくっています...</div>
        ) : logs.length === 0 ? (
          <div className="text-center mt-20 text-slate-500">
            <p className="mb-4 text-6xl">📜</p>
            <p>まだ日誌の記録がありません。</p>
            <p className="text-sm mt-2">星を選んで「決定して振り返る」と、ここに記録が残ります。</p>
          </div>
        ) : (
          <div className="space-y-8">
            {logs.map((log) => (
              <div key={log.id} className="bg-[#1e1b4b]/50 border border-white/10 rounded-2xl p-6 shadow-lg relative overflow-hidden group hover:border-yellow-500/30 transition-colors">
                {/* 装飾ライン */}
                <div className="absolute left-0 top-0 bottom-0 w-1 bg-gradient-to-b from-transparent via-yellow-500/50 to-transparent"></div>
                
                <div className="flex justify-between items-start mb-4">
                  <div className="flex items-center gap-3">
                    <span className={`
                      px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider
                      ${log.timeframe === 'past' ? 'bg-blue-500/20 text-blue-300' : 
                        log.timeframe === 'current' ? 'bg-green-500/20 text-green-300' : 'bg-purple-500/20 text-purple-300'}
                    `}>
                      {log.timeframe}
                    </span>
                    <div className="flex items-center gap-1 text-slate-400 text-xs">
                      <Clock size={12} />
                      {new Date(log.updated_at).toLocaleDateString()} {new Date(log.updated_at).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})}
                    </div>
                  </div>
                  <div className="text-yellow-500/50">
                    <Star size={20} />
                  </div>
                </div>

                <div className="prose prose-invert max-w-none">
                  <p className="text-slate-200 whitespace-pre-wrap leading-relaxed font-serif text-lg">
                    {log.description}
                  </p>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default ReflectionsList;