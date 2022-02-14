const assert = require('chai').assert;

//인자로 logs 오브젝트를 넣어주고, 찾고자하는 event 명을 넣어주면,
const inLogs = async (logs, eventName) => {
  //logs의 배열에서 event를 가져와서 그 값이 찾고자하는 event명과 일치하는지 확인.
  const event = logs.find(e => e.event === eventName);
  //찾고자 하는 이벤트가 있어야 한다.
  assert.exists(event);
}

module.exports = {
  inLogs
}