pragma solidity ^0.4.26;

import "./zombiefactory.sol";

contract KittyInterface {
  function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}

contract ZombieFeeding is ZombieFactory {

    address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
  // `ckAddress`를 이용하여 여기에 kittyContract를 초기화한다
  KittyInterface kittyContract = KittyInterface(ckAddress);

  function feedAndMultiply(uint _zombieId, uint _targetDna, string _species) public {
    //msg.sender가 좀비 주인과 동일
    require(msg.sender == zombieToOwner[_zombieId]);
    // 먹이를 먹는 좀비 DNA를 얻을 필요가 있으므로,
    Zombie storage myZombie = zombies[_zombieId];
    //16자리 보다 크지 않도록
    _targetDna = _targetDna % dnaModulus;
    //새로운 좀비의 dna
    uint newDna = (myZombie.dna + _targetDna) / 2;
    if(keccak256(_species) == keccak256("kitty")){
      newDna = newDna - newDna % 100 + 99;
    }

    _createZombie("NoName",newDna);
  }

  function feedOnKitty(uint _zombieId, uint _kittyId) public {
    uint kittyDna;
    (,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
    feedAndMultiply(_zombieId,kittyDna,"kitty");
  }
}
