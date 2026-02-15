#!/bin/bash

PHRASES_FILE_PATH="./src/samples/phrases.txt"

VECTOR_DATA_FILE_NAME="vector-data"
VECTOR_DATA_FILE_EXTENSTION='json'
VECTOR_DATA_FILE_PATH="./src/samples/${VECTOR_DATA_FILE_NAME}.${VECTOR_DATA_FILE_EXTENSTION}"

DEV_FOLDER_PATH="./src/dev"
OLLAMA_LOG_FILE_PATH="./src/dev/ollama.log"

EMBEDDINGS_MODEL="qwen3-embedding:0.6b"

if [[ ! -e "$PHRASES_FILE_PATH" ]] then
  echo "File does not exist!"
  echo "Finishing work"
  exit 1
fi

if [[ -e "$VECTOR_DATA_FILE_PATH" ]] then
  timestamp=$(date +%s)

  echo "Found old embedding info"
  echo "Copying..."

  cp "$VECTOR_DATA_FILE_PATH" "./src/samples/${VECTOR_DATA_FILE_NAME}__${timestamp}.${VECTOR_DATA_FILE_EXTENSTION}"

  echo "Copied. Deleting original"

  rm "$VECTOR_DATA_FILE_PATH"
fi

if ! nc -z localhost 11434; then
  echo "Ollama is not running"
  echo "Trying to run Ollama"

  echo "=================="

  if [[ ! -d "$DEV_FOLDER_PATH" ]] then
    mkdir "$DEV_FOLDER_PATH"
  fi

  if [[ ! -e "$OLLAMA_LOG_FILE_PATH" ]] then
    touch "$OLLAMA_LOG_FILE_PATH"
  fi

  nohup ollama serve > "$OLLAMA_LOG_FILE_PATH" 2>&1 &

  echo "=================="
fi

if ! ollama list | grep -q "${EMBEDDINGS_MODEL}"; then
  echo "Required embeddings model (${EMBEDDINGS_MODEL}) does not exist. Please install it"
  exit 1;
fi

echo "========================================================================="
echo "STARTING EMBEDDINGS"
echo "========================================================================="

preparedPhraseCount=0
preparedData="[]"

while IFS= read -r line; do
  echo "Starting embeddings for ${line}"

  embeddings=$(ollama run "${EMBEDDINGS_MODEL}" "${line}" </dev/null)
  preparedData="$(jq --arg text "$line" --argjson vector "$embeddings" \
      '. + [{"text": $text, "vector": $vector}]' <<< "$preparedData")"

  echo "Finished embeddings for ${line}"

done < "${PHRASES_FILE_PATH}"

touch "${VECTOR_DATA_FILE_PATH}"
echo "${preparedData}" > "${VECTOR_DATA_FILE_PATH}"

echo "Phrases embeddings are ready"
