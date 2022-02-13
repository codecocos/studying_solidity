// 솔리디티 버전
pragma solidity ^0.4.26;

//상태 변수는 컨트랙트 저장소에 영구적으로 저장
contract ZombieFactory{

// 이벤트 : 컨트랙트가 블록체인 상, 앱의 사용자 단에서 무언가 액션이 발생했을 때 의사소통하는 방법
event NewZombie(uint zombieId, string name, uint dna);

  //부호 없는 정수: uint
  //부호 있는 정수: int
  uint dnaDigits = 16;
  //지수연산 **
  uint dnaModulus = 10 ** dnaDigits;

//구조체
  struct Zombie{
    string name;
    uint dna;
  }
  
  //Zombie 구조체의 public 배열을 생성
  Zombie[] public zombies;

  //좀비 소유자의 주소를 추적
    mapping (uint=> address) public zombieToOwner;
    // 소유한 좀비의 숫자를 추적
    mapping (address => uint) ownerZombieCount;

// 좀비 생성 함수
// 솔리디티에서 함수는 기본적으로 public으로 선언
// private는 컨트랙트 내의 다른 함수들만이 이 함수를 호출하여 배열로 무언가를 추가할 수 있음.
// private 함수명도 언더바(_)
// view 함수로 선언 : 데이터를 보기만 하고 변경하지 않는다는 뜻
// pure 함수 : 앱에서 어떤 데이터도 접근하지 않는 것을 의미
// internal로 바꾸어 선언하여 이 함수가 정의된 컨트랙트를 상속하는 컨트랙트에서도 접근 가능하게 함.
  function _createZombie(string _name, uint _dna) private {
    //새로운 Zombie를 생성하여 zombies 배열에 추가
    uint id = zombies.push(Zombie(_name, _dna))-1;
    // zombieToOwner 매핑을 업데이트하여 id에 대하여 msg.sender가 저장
    zombieToOwner[id]=msg.sender;
    //저장된 msg.sender을 고려하여 ownerZombieCount를 증가
    ownerZombieCount[msg.sender]++;
    NewZombie(id,_name,_dna);
  }

  function _generateRandomDna(string _str) private view returns (uint){
    //_str을 이용한 keccak256 해시값을 받아서 의사 난수 16진수를 생성하고 이를 uint로 형 변환한 다음, rand라는 uint에 결과값을 저장
    uint rand = uint(keccak256(_str));
    //%모듈로 dnaModulus로 연산한 값을 반환
    return rand % dnaModulus;
  }

//좀비의 이름을 입력값으로 받아 랜덤 DNA를 가진 좀비를 만드는 함수
  function createRandomZombie(string _name) public {
    require(ownerZombieCount[msg.sender] == 0);
    uint randDna = _generateRandomDna(_name);
    _createZombie(_name,randDna);

  }

}

// //솔리디티 배열
// // 2개의 원소를 담을 수 있는 고정 길이의 배열:
// uint[2] fixedArray;
// // 또다른 고정 배열으로 5개의 스트링을 담을 수 있다:
// string[5] stringArray;
// // 동적 배열은 고정된 크기가 없으며 계속 크기가 커질 수 있다:
// uint[] dynamicArray;

// // public으로 배열을 선언
// // getter 메소드를 자동적으로 생성 : 다른 컨트랙트들이 이 배열을 읽을 수 있지만, 쓸 수 는 없음.
// Person[] public people;

