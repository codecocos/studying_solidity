pragma solidity >=0.4.22 <0.9.0;

contract Lottery {
  struct BetInfo {
    uint256 answerBlockNumber;
    address payable bettor; //payable : 해당 주소로 트랜스퍼 하기 위해서 붙임.
    bytes1 challenges; // 0Xab..
  }

//tail이 증가하면서 값을 넣어줌
  uint256 private _tail;
  //값을 검증할 때는 _head 부터 차례대로 값을 가져와서 검증
  uint256 private _head;
  //자료구조 queue
  mapping(uint256 => BetInfo) private _bets;


  //주소를 오너로 설정
  //public : 자동으로 getter를 만들어 준다, 스마트 컨트랙트 외부에서 바로 오너의 값을 알 수 있다.
  address public owner;

  // 블록해시로 확인할 수 있는 제한 256으로 고정 
  uint256 constant internal BLOCK_LIMIT = 256;
  // +3 번째블럭으로 고정
  uint256 constant internal BET_BLOCK_INTERVAL = 3;
  // 배팅금액 0.005eth 고정
  uint256 constant internal BET_AMOUNT = 5 * 10 ** 15; 

  //팟머니 
  uint256 private _pot;

  enum BlockStatus {Checkable, NotRevealed, BlockLimitPassed}
  enum BettingResult {Fail, Win, Draw}

  //이벤트
  event BET(uint256 index, address bettor, uint256 amount, bytes1 challenges, uint256 answerBlockNumber);

//스마트 컨트랙트가 생성될 때,, 배포가 될때, 가장 먼저 실행되는 함수.
  constructor() public {
    owner = msg.sender;
    // 배포가 될 때, 보낸사람을 오너로 저장하겠다.
    // msg.sender : 스마트 컨트랙트에서 사용하는 전역변수 
  }

  // 테스트용 코드 주석처리
  // function getSomeValue() public pure returns (uint256 value){
  //   return 5;
  // }

// view : 스마트 컨트랙트에 있는 변수를 조회할 때
  function getPot() public view returns (uint256 pot){
    return _pot;
  }

  
  // /**
  // * 베팅 함수
  // *
  // * @dev 베팅을 한다. 유저는 0.005 ETH를 보내야 하고, 베팅용 1 byte 글자를 보낸다.
  // * 큐에 저장된 베팅 정보는 이후 distribute 함수에서 해결된다.
  // * @param challenges 유저가 베팅하는 글자
  // * @return 함수가 잘 수행되었는지 확인하는 bool 값
  // *
  // */
  function bet(bytes1 challenges) public payable returns (bool result){
    // Check the proper ether is sent
    require(msg.value == BET_AMOUNT, "not enough ETH");
    // Push bet to the queue
    require(pushBet(challenges),"Fail to add a new Bet Info");
    // Emit event
    emit BET(_tail - 1, msg.sender, msg.value, challenges, block.number + BET_BLOCK_INTERVAL);

    return true;
  }
    // Save the bet to the queue

  // Distribute : 검증
  function distribute() public {
    // head 3 4 5 6 7 8 9 10 11 12 tail
    uint256 cur;
    BetInfo memory b;
    BlockStatus currentBlockStatus;

    // head 부터 tail까지 도는 루프 : 각각에 대해서 상태확인이 필요
    for (cur = _head; cur < _tail; cur++) {
      b = _bets[cur];
      currentBlockStatus = getBlockStatus(b.answerBlockNumber);
     
      // Checkable : block.number > AnswerBlockNumber && block.number - BLOCK_LIMIT < AnswerBlockNumber 1
      // 현재 블록넘버 보다 정답 블록 넘버 + 블록리밋 한 값보다 작고,
      if(currentBlockStatus == BlockStatus.Checkable){
        // if win, bettor gets pot

        // if fail, bettor's money goes pot

        // if draw, refund bettor's money
        
      }

      // 블록해쉬를 알 수 없을 때 : 아직 마이닝이 되지 않은 경우 혹은 블럭이 마이닝 되었지만, 너무 오래되어 확인 할 수 없을 때
      // Not Revealed : 아직 마이닝 되지 않은 경우 : block.number <= AnswerBlockNuumber 2
      if(currentBlockStatus == BlockStatus.NotRevealed){
        break;
      }

      // Block Limit Passed : 너무 오래되어 확인 할 수 없는 경우 : block.number >= AnswerBlockNumber + BLOCK_LIMIT 3
      if(currentBlockStatus == BlockStatus.BlockLimitPassed){
        // refund
        // emit refund
      }
      popBet(cur);
    }
  }

  // /**
  // * @dev 베팅글자와 정답을 확인한다.
  // * @param challenges 베팅글자
  // * @param answer 블락해쉬
  // * @return 정답결과  
  // */
  function isMatch(bytes1 challenges, bytes32 answer) public pure returns (BettingResult){
    // challenges 0xab
    // answer 0xab......ff 32 bytes

    bytes1 c1 = challenges;
    bytes1 c2 = challenges;

    bytes1 a1 = answer[0];
    bytes1 a2 = answer[0];

    // Get first number : shift연산
    c1 = c1 >> 4; // 0xab -> 0x0a
    c1 = c1 << 4; // 0x0a -> 0xa0

    a1 = a1 >> 4;
    a1 = a1 << 4;

    // Get Second number
    c2 = c2 << 4; // 0xab -> 0xb0
    c2 = c2 >> 4; // 0xb0 -> 0x0b

    a2 = a2 << 4;
    a2 = a2 >> 4;

    if(a1 == c1 && a2 == c2){
      return BettingResult.Win;
    }

    if(a1 == c1 || a2 == c2){
      return BettingResult.Draw;
    }

    return BettingResult.Fail;
  }
    

  function getBlockStatus(uint256 answerBlockNumber) internal view returns (BlockStatus){
    if(block.number > answerBlockNumber && block.number - BLOCK_LIMIT < answerBlockNumber) {
      return BlockStatus.Checkable;
    }

    if(block.number <= answerBlockNumber){
      return BlockStatus.NotRevealed;
    }

    if(block.number >= answerBlockNumber + BLOCK_LIMIT){
      return BlockStatus.BlockLimitPassed;
    }
    //3가지 중 하나에서 걸리겠지만 만일의 경우를 대비하여, 문제가 있는 경우 환불해주는 것이 안전하므로,,,
    return BlockStatus.BlockLimitPassed;
  }
  
  //getter
  function getBetInfo(uint256 index) public view returns (uint256 answerBlockNumber, address bettor, bytes1 challenges){
    BetInfo memory b = _bets[index];
    answerBlockNumber = b.answerBlockNumber;
    bettor = b.bettor;
    challenges = b.challenges;
  }

  //queue 이용하니 puch와 pop의 개념이 필요
  function pushBet(bytes1 challenges) internal returns (bool) {
    BetInfo memory b;
    //베터는 보낸사람 , 버전업이 되어 전송하려면 payable 붙여줘야함.
    b.bettor = payable(msg.sender); // 20 bytes
    //block.number : 현재 트랜잭션에 들어가는 블럭의 수를 가져옴
    b.answerBlockNumber = block.number + BET_BLOCK_INTERVAL; // 32 bytes  20000 gas
    b.challenges = challenges; // byte  // 20000gas 가정
    
    _bets[_tail] = b;
    _tail++; // 32 bytes 값 변화 // 20000gas 가정 -> 5000 gas 

    return true;
  }

  function popBet(uint256 index) internal returns (bool){
    //매핑 이기때문에 리스트에서 삭제하기보다는 단순히 값을 초기화 하자.
    //맵에 있는 값을 delete하게 되면, gas를 돌려받게 된다. 이것의 의미는 더이상 데이터를 블록체인 데이터에 저장하지 않겠다의 의미. state database에 저장된 값을 그냥 없앤다
    delete _bets[index];
    return true;
  }
} 