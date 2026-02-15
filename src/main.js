require("dotenv").config();

const path = require("path");
const fs = require("fs");

const { getCosine } = require("./helpers/vector.helpers");

const vectorInfosJSON = fs.readFileSync(
  path.join(__dirname, "samples/vector-data.json"),
);
const vectorInfos = JSON.parse(vectorInfosJSON);

const OLLAMA_BASE_URL = process.env.OLLAMA_BASE_URL || "http://localhost:11434";
const EMBEDDINGS_MODEL = process.env.EMBEDDINGS_MODEL || "qwen3-embedding:0.6b";

const [_, __, tFlag, text, cFlag, count] = process.argv;

async function main() {
  if (tFlag !== "-t" || !text || cFlag !== "-c" || !count) {
    console.error("Missing required arguments");
    return;
  }

  const textVectorResult = await getEmbeddingsResultForPhrase(text);
  const textVector = textVectorResult.embeddings[0];

  const cosineInfos = [];

  for (const vectorInfo of vectorInfos) {
    const cosine = getCosine(textVector, vectorInfo.vector);

    cosineInfos.push({
      text: vectorInfo.text,
      cosine,
    });
  }

  cosineInfos.sort(
    (cosineInfoA, cosineInfoB) => cosineInfoB.cosine - cosineInfoA.cosine,
  );

  for (let i = 0; i < +count; ++i) {
    console.log(
      `Text: ${cosineInfos[i].text} [alignment: ${cosineInfos[i].cosine * 100}%]`,
    );
  }
}

async function getEmbeddingsResultForPhrase(phrase) {
  const textVectorRequest = await fetch(`${OLLAMA_BASE_URL}/api/embed`, {
    method: "POST",
    body: JSON.stringify({
      model: EMBEDDINGS_MODEL,
      input: text,
    }),
    headers: {
      "Content-Type": "application/json",
    },
  });

  return textVectorRequest.json();
}

main();
