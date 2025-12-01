import axios from 'axios';

// 1. Railsのセキュリティトークン(CSRF)を取得
// これがないと、データの保存(POST/PUT)や削除(DELETE)がRailsに拒否されてしまう
const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');

// 2. Axiosの共通設定
const client = axios.create({
  baseURL: '/api/v1', // 接続先のベースURL
  headers: {
    'X-CSRF-Token': csrfToken,
    'Content-Type': 'application/json',
  },
});

// 3. API関数の定義

// --- 価値観パズル (Starry Workshop) 用 ---

// パズル一覧（カテゴリーとカード）を取得
export const fetchValueCategories = () => {
  return client.get('/value_categories');
};

// 自分が選んだカード一覧を取得
export const fetchUserSelections = () => {
  return client.get('/user_card_selections');
};

// カードを選ぶ（保存）
// data形式: { value_card_id: 1, timeframe: 'current', description: '...' }
export const createSelection = (data) => {
  return client.post('/user_card_selections', data);
};

// 選択を解除する（削除）
export const deleteSelection = (cardId, timeframe) => {
  // Railsの仕様上、DELETEメソッドでbodyを送るよりクエリパラメータが確実なためparamsで送る
  return client.delete(`/user_card_selections/0`, { 
    params: { id: cardId, timeframe } 
  });
};

// --- 心の航海日誌 (Magic Book) 用 ---

// 質問と自分の回答一覧を取得
export const fetchReflections = () => {
  return client.get('/reflections');
};

// 回答を保存する
// questionId: 質問ID, answer: 回答テキスト
export const saveReflection = (questionId, answer) => {
  return client.put(`/reflections/${questionId}`, { answer });
};