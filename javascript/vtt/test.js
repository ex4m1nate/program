const fs = require('fs').promises;
const kuromoji = require('kuromoji');
const axios = require('axios');

const INPUT_FILE = 'input.vtt';
const OUTPUT_FILE = 'output.vtt'
const OUTPUT_FILE_SUM = 'gijiroku.md'

// チャンク分割時のトークン数
const CHUNK_TOKEN_LIMIT = 1900;

// Open AIのトークンリミット数
const OPENAI_TOKEN_LIMIT = 1900;

// 要約作成用のプロンプト
const SUMMARIZE_PROMPT = '以下を意味や重要な点を損なうことなく、日本語で要約してください。';

// 議事録作成用のプロンプト
const GIJIROKU_PROMPT = '以下の文章から議事録を作成してください。タイトル・出席者・議題・議論の概要・決定事項・課題を整理してください。句点の後ろに改行をいれてください。';

const OPENAI_API_ENDPOINT = 'https://test-123046.openai.azure.com/openai/deployments/gpt-4o-mini/chat/completions?api-version=2023-03-15-preview';
const OPENAI_API_KEY = '199eb25781f54a3687f938cb6a74877f';

function cleanText(text) {
    if (typeof text !== 'string') return '';
    return text.replace(/\s+/g, ' ').trim();
  }

  async function readSummariesFromFile() {
    try {
      const summaries = await fs.readFile('output.vtt', 'utf8');
      return summaries;
    } catch (err) {
      console.error('Error reading file:', err);
      return null;
    }
  }

// まとめた要約から議事録を作成してファイルに出力する
async function useOpenAi(prompt,chunk) {
    chunk = cleanText(chunk);
    const input_prompt = `${prompt}
    ${chunk}`;
  
    const uri = OPENAI_API_ENDPOINT;
    const header = {
      'Content-Type': 'application/json',
      'api-key': OPENAI_API_KEY
    };
    const postBody = {
      max_tokens: OPENAI_TOKEN_LIMIT,
      temperature: 0.7,
      top_p: 0.95,
      frequency_penalty: 0,
      presence_penalty: 0,
      stop: ['##'],
      messages: [
        {
          role: 'user',
          content: input_prompt
        }
      ]
    };
    try {
      const response = await axios.post(uri, postBody, {
        headers: header
      });
  
      console.log('API Response:', response.data); // APIレスポンスをログに出力して確認
      const answer = response.data.choices[0].message.content;
      return answer;
    } catch (error) {
      console.error(error);
      return 'OpenAIでの処理に失敗しました。';
    }
}

async function splitAndSummarizeVttFile() {
    try {
            giji = await useOpenAi(GIJIROKU_PROMPT,readSummariesFromFile());
            console.log('Giji:', giji); // 議事録をログに出力して確認
            fs.writeFile(OUTPUT_FILE_SUM, giji, 'utf8', (err) => {
            if (err) {
            console.error('Error writing giji to file:', err.message);
            } else {
            console.log(`Giji written to ${OUTPUT_FILE_SUM}`);
  }
});
} catch (err) {
console.error('Error:', err.message);
}}

splitAndSummarizeVttFile();