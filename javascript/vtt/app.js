const fs = require('fs');
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

// 日本語テキストをトークン化する関数
function tokenizeText(text, callback) {
  kuromoji.builder({ dicPath: 'node_modules/kuromoji/dict' }).build((err, tokenizer) => {
    if (err) throw err;
    const tokens = tokenizer.tokenize(text);
    callback(tokens);
  });
}

// VTTファイルを読み込む関数
function readVttFile(file) {
  return new Promise((resolve, reject) => {
    fs.readFile(file, 'utf8', (err, data) => {
      if (err) reject(err);
      resolve(data);
    });
  });
}

function cleanText(text) {
  if (typeof text !== 'string') return '';
  return text.replace(/\s+/g, ' ').trim();
}

/**********************************************
 *  OpenAI APIで要約や議事録作成を行う関数
 **********************************************/
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

    const answer = response.data.choices[0].message.content;
    return answer;
  } catch (error) {
    console.error(error);
    return 'OpenAIでの処理に失敗しました。';
  }
}

/**********************************************
 *  VTTファイルを分割し、要約し、コンソールに出力する関数
 **********************************************/
async function splitAndSummarizeVttFile(vttContent) {
  try {
    if (!vttContent) {
        // 何もアップロードされなかったらサンプルファイルから議事録を作成する
        console.log('ローカルファイル');
        vttContent = await readVttFile(INPUT_FILE);
    } else {
      console.log('アップロードファイル');
    }
    const vttLines = vttContent.split('\n');

    // 変数・フラグの初期化
    let currentTokenCount = 0;
    let currentChunk = '';
    let chunkIndex = 0;
    let isTextLine = false;
    let summaries = '';
    let count = 1;

    // チャンク分割し、要約を作成
    for (const line of vttLines) {
      // 進捗を更新
      progress = ((count / vttLines.length) * 100).toFixed(2) + '%';
      console.log(progress);
      count++;

      if (line.startsWith('WEBVTT')) {
        currentChunk = '\n\n';
        continue;
      }

      if (line.match(/^\d+$/)) {
        isTextLine = false;
        currentChunk += line + '\n';
        continue;
      }

      if (line.match(/(\d\d:){2}\d\d\.\d\d\d --> (\d\d:){2}\d\d\.\d\d\d/)) {
        isTextLine = true;
        currentChunk += line + '\n';
        continue;
      }

      if (isTextLine) {
        const tokens = await new Promise((resolve) => tokenizeText(line, resolve));
        currentTokenCount += tokens.length;
        if (currentTokenCount >= CHUNK_TOKEN_LIMIT) {
          // Open AIで要約する
          const summary = await useOpenAi(SUMMARIZE_PROMPT,currentChunk);
          summaries += summary.trim() + '\n\n';

          currentChunk = '\n\n';
          currentTokenCount = tokens.length;
          chunkIndex++;
        }
      }
      currentChunk += line + '\n';
    }

    // 最後のチャンクを要約し、結果を追加する
    if (currentChunk) {
      // Open AIで要約する
      const summary = await useOpenAi(SUMMARIZE_PROMPT,currentChunk);
      summaries += summary.trim() + '\n\n';
    }

    // まとめた要約をコンソールに出力する
    console.log(summaries);

    // まとめた要約をファイルに出力する
    fs.writeFile(OUTPUT_FILE, summaries, 'utf8', (err) => {
      if (err) {
          console.error('Error writing summaries to file:', err.message);
      } else {
          console.log(`Summaries written to ${OUTPUT_FILE}`);
      }
    });

    // まとめた要約から議事録を作成してファイルに出力する
    giji = await useOpenAi(GIJIROKU_PROMPT,summaries);
    fs.writeFile(OUTPUT_FILE_SUM, giji, 'utf8', (err) => {
      if (err) {
          console.error('Error writing summaries to file:', err.message);
      } else {
          console.log(`Summaries written to ${OUTPUT_FILE_SUM}`);
      }
    });
    isCompleted = true;

  } catch (err) {
    console.error('Error:', err.message);
  }
}

splitAndSummarizeVttFile();
