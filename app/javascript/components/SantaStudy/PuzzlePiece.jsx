import React, { forwardRef } from 'react';

const PuzzlePiece = forwardRef(({ card, color, isSelected, onClick }, ref) => {
  return (
    <button
      ref={ref}
      onClick={onClick}
      className={`
        group relative flex flex-col items-center justify-center p-1
        transition-all duration-500
        ${isSelected ? 'scale-110 z-10' : 'opacity-70 hover:opacity-100 hover:scale-110'}
      `}
      style={{ width: '80px', height: '80px' }}
    >
      {/* 星のシェイプ */}
      <div 
        className={`
          absolute inset-0 transition-all duration-500
          ${isSelected ? 'animate-pulse' : ''}
        `}
        style={{
          // 五芒星の形（clip-path）
          clipPath: 'polygon(50% 0%, 61% 35%, 98% 35%, 68% 57%, 79% 91%, 50% 70%, 21% 91%, 32% 57%, 2% 35%, 39% 35%)',
          backgroundColor: isSelected ? '#fbbf24' : 'rgba(255, 255, 255, 0.15)',
          // バッククォートを追加 
          boxShadow: isSelected ? `0 0 20px ${color}, 0 0 40px #fbbf24` : 'none',
          backdropFilter: 'blur(4px)',
          // 未選択時はうっすら白い枠線、選択時は枠線なし
          border: isSelected ? 'none' : '1px solid rgba(255,255,255,0.4)',
        }}
      />
      
      {/* 選択時の中央の輝き */}
      {isSelected && (
        <div className="absolute inset-0 bg-yellow-300 opacity-50 blur-md rounded-full transform scale-50"></div>
      )}

      {/* テキスト */}
      <span className={`
        relative z-10 text-[10px] md:text-xs font-bold text-center leading-tight select-none mt-1
        ${isSelected ? 'text-white drop-shadow-[0_2px_2px_rgba(0,0,0,0.8)]' : 'text-slate-200'}
      `}>
        {card.name}
      </span>
    </button>
  );
});

PuzzlePiece.displayName = 'PuzzlePiece';
export default PuzzlePiece;