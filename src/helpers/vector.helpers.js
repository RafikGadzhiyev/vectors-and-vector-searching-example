function getVectorMagnitude(vector) {
  let vectorMagnitude = 0;

  for (const value of vector) {
    vectorMagnitude += value ** 2;
  }

  vectorMagnitude = Math.sqrt(vectorMagnitude);

  return vectorMagnitude;
}

function getVectorDot(queryVector, dataVector) {
  let dot = 0;

  for (let i = 0; i < queryVector.length; ++i) {
    dot += queryVector[i] * dataVector[i];
  }

  return dot;
}

function getCosine(queryVector, dataVector) {
  let queryMagnitude = getVectorMagnitude(queryVector);
  let dataMagnitude = getVectorMagnitude(dataVector);

  let dot = getVectorDot(queryVector, dataVector);

  return dot / (queryMagnitude * dataMagnitude);
}

module.exports = {
  getCosine,
};
