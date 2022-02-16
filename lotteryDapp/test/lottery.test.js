const Lottery = artifacts.require('Lottery');
const { assert } = require('chai');
const assertRevert = require('./assertRevert')
const expectEvent = require('./expectEvent');

//[deployer,user1,user2] : ganache-cli에서 생성한 주소가 차례대로 들어옴.
contract('Lottery', function ([deployer, user1, user2]) {

  let lottery;
  let betAmount = 5 * 10 ** 15;
  let betAmountBN = new web3.utils.BN('5000000000000000');
  let bet_block_interval = 3;

  beforeEach(async () => {
    //console.log('Before each');

    //테스트용 배포
    // new(): 빈칸이면 무조건 0번이 배포자가 됨.
    lottery = await Lottery.new()
  })

  // it('Basic test', async () => {
  //   console.log('Basic test');

  //   let owner = await lottery.owner();
  //   //let value = await lottery.getSomeValue();

  //   console.log(`owner :  ${owner}`);
  //   console.log(`value :  ${value}`);

  //   assert.equal(value, 5);
  // })

  //it.only : 특정 케이스만 테스틑 할 때
  it('getPot should return current pot', async () => {
    let pot = await lottery.getPot();
    // 처음에는 팟머니가 없는 상황이라 0
    assert.equal(pot, 0);
  })

  describe('Bet', function () {
    it('should fail when the bet money is not 0.005 ETH', async () => {
      // Fail transaction
      // assertRevert의 인자가 보내는 에러를 assertRevert가 받아서 try-catch 문으로 받는다.
      // 에러이므로 catch 문으로 들어온다. 에러문에 revert 단어가 있는지 없는지 확인하고 revert 단어가 있다면, 에러를 제대로 확인 하였다는 의미.
      await assertRevert(lottery.bet('0xab', { from: user1, value: 4000000000000000 })) // queue의 0번
      // transaction object {chainId, value, to, from, gas(Limit), gasPrice}
      // chainId : 블록체인마다, 네트워크 마다 다른 체인아이디
      // value : 이더
      // to : address
      // from : 누가 보냇는지


    });

    it('should put the bet to the bet queue with 1 bet', async () => {
      // bet
      // 바이트 하나 보내고, 트랜잭션 오브젝트
      let receipt = await lottery.bet('0xab', { from: user1, value: betAmount })
      //console.log(receipt);

      let pot = await lottery.getPot();
      assert.equal(pot, 0)

      // check contract balance === 0.005
      // 트러플에서 web3가 주입되어 있음.
      let contractBalance = await web3.eth.getBalance(lottery.address);
      assert.equal(contractBalance, betAmount);

      // check bet info
      let currentBlockNumber = await web3.eth.getBlockNumber();
      bet = await lottery.getBetInfo(0);

      assert.equal(bet.answerBlockNumber, currentBlockNumber + bet_block_interval);
      assert.equal(bet.bettor, user1);
      assert.equal(bet.challenges, '0xab');

      // check log
      await expectEvent.inLogs(receipt.logs, "BET");
    })
  })

  describe('Distribute', function () {
    describe('When the answer is checkable', function () {
      it.only('should give the user the pot when the answer matches', async () => {
        // 두 글자 다 맞았을 때

        await lottery.setAnswerForTest('0xabec17438e4f0afb9cc8b77ce84bb7fd501497cfa9a1695095247daa5b4b7bcc', { from: deployer })

        // 베팅이 여러번
        await lottery.betAndDistribute('0xef', { from: user2, value: betAmount }) // 1 -> 4
        await lottery.betAndDistribute('0xef', { from: user2, value: betAmount }) // 2 -> 5
        await lottery.betAndDistribute('0xab', { from: user1, value: betAmount }) // 3 -> 6
        await lottery.betAndDistribute('0xef', { from: user2, value: betAmount }) // 4 -> 7
        await lottery.betAndDistribute('0xef', { from: user2, value: betAmount }) // 5 -> 8
        await lottery.betAndDistribute('0xef', { from: user2, value: betAmount }) // 6 -> 9

        let potBefore = await lottery.getPot(); // == 0.01 ETH
        let userBalanceBefore = await web3.eth.getBalance(user1);

        let receipt7 = await lottery.betAndDistribute('0xef', { from: user2, value: betAmount }) // 7 -> 10 // user1에게 pot이 간다

        let potAfter = await lottery.getPot(); // == 0
        let user1BalanceAfter = await web3.eth.getBalance(); // == before + 0.015

        // pot 의 변화량 확인
        console.log(potBefore);

        // assert.equal(potBefore,betAmountBN)

        // user(winner)의 밸런스를 확인
      })
      it('should give the user the amount he or she when a single character matches', async () => {
        // 한 글자만 맞았을 때
      })
      it('should get the eht of user when the answer does not match at all', async () => {
        // 다 틀렸을 때
      })
    })

    describe('When the answer is not revealed(Not Mined)', function () {

    })

    describe('When the answer id not revealed(Block limit is passed', function () {

    })

  })

  describe('isMatch', function () {
    //아무 해쉬나 가져와서, 테스트를 위해 3,4번째를 a 와 b로 변경.
    let blockHash = '0xabec17438e4f0afb9cc8b77ce84bb7fd501497cfa9a1695095247daa5b4b7bcc';

    it('should be BettingResult.Win when two characters match', async () => {
      let matchingResult = await lottery.isMatch('0xab', blockHash);
      assert.equal(matchingResult, 1)
    })

    it('should be BettingResult.Fail when two characters match', async () => {
      let matchingResult = await lottery.isMatch('0xcd', blockHash);
      assert.equal(matchingResult, 0)
    })

    it('should be BettingResult.Draw when two characters match', async () => {
      let matchingResult = await lottery.isMatch('0xaf', blockHash);
      assert.equal(matchingResult, 2)

      matchingResult = await lottery.isMatch('0xfb', blockHash);
      assert.equal(matchingResult, 2)
    })
  })
})