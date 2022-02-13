pragma solidity >=0.4.22 <0.9.0;

contract Lottery {
  //주소를 오너로 설정
  //public : 자동으로 getter를 만들어 준다, 스마트 컨트랙트 외부에서 바로 오너의 값을 알 수 있다.
  address public owner;

//스마트 컨트랙트가 생성될 때,, 배포가 될때, 가장 먼저 실행되는 함수.
  constructor() public {
    owner = msg.sender;
    // 배포가 될 때, 보낸사람을 오너로 저장하겠다.
    // msg.sender : 스마트 컨트랙트에서 사용하는 전역변수 
  }

  function getSomeValue() public pure returns (uint256 value){
    return 5;
  }
} 