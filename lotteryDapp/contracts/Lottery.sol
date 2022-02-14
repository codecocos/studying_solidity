pragma solidity >=0.4.22 <0.9.0;

contract Lottery {
  struct BetInfo {
    uint256 answerBlockNumber;
    address payable bettor; //payable : 해당 주소로 트랜스퍼 하기 위해서 붙임.
    bytes challenges; // 0Xab..
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

  //이벤트
  event BET(uint256 index, address bettor, uint256 amount, bytes challenges, uint256 answerBlockNumber);

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
  function bet(bytes memory challenges) public payable returns (bool result){
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
    // check the answer
  
  //getter
  function getBetInfo(uint256 index) public view returns (uint256 answerBlockNumber, address bettor, bytes memory challenges){
    BetInfo memory b = _bets[index];
    answerBlockNumber = b.answerBlockNumber;
    bettor = b.bettor;
    challenges = b.challenges;
  }

  //queue 이용하니 puch와 pop의 개념이 필요
  function pushBet(bytes memory challenges) internal returns (bool) {
    BetInfo memory b;
    //베터는 보낸사람 , 버전업이 되어 전송하려면 payable 붙여줘야함.
    b.bettor = payable(msg.sender);
    //block.number : 현재 트랜잭션에 들어가는 블럭의 수를 가져옴
    b.answerBlockNumber = block.number + BET_BLOCK_INTERVAL;
    b.challenges = challenges;
    
    _bets[_tail] = b;
    _tail++;

    return true;
  }

  function popBet(uint256 index) internal returns (bool){
    //매핑 이기때문에 리스트에서 삭제하기보다는 단순히 값을 초기화 하자.
    //맵에 있는 값을 delete하게 되면, gas를 돌려받게 된다. 이것의 의미는 더이상 데이터를 블록체인 데이터에 저장하지 않겠다의 의미. state database에 저장된 값을 그냥 없앤다
    delete _bets[index];
    return true;
  }
} 