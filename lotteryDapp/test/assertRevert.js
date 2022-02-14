module.exports = async (promise) => {
  try {
    //promise니까 await 걸기.
    await promise;
    // promise를 기다렸는데 에러가 catch문 쪽으로 넘어가지 않으면 문제가 있으므로,
    // 리버트가 예상되었으나 일어나지 않았다는 문구를 작성.
    assert.fail('Expected revert not received')
  } catch (error) {
    //원하는 대로 에러가 캐치문으로 온다면, 에러 메세지를 받아 search한다. search는 revert의 인덱스를 구할 수 있게 함.
    const revertFound = error.message.search('revert') >= 0;
    assert(revertFound, `Expected "revert", get ${error} instead`);
  }
}