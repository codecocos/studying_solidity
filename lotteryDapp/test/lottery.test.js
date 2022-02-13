const Lottery = artifacts.require('Lottery');

//[deployer,user1,user2] : ganache-cli에서 생성한 주소가 차례대로 들어옴.
contract('Lottery', function ([deployer, user1, user2]) {

  let lottery;

  beforeEach(async () => {
    console.log('Before each');

    //테스트용 배포
    lottery = await Lottery.new()
  })

  it('Basic test', async () => {
    console.log('Basic test');

    let owner = await lottery.owner();
    let value = await lottery.getSomeValue();

    console.log(`owner :  ${owner}`);
    console.log(`value :  ${value}`);

    assert.equal(value, 5);
  })
})