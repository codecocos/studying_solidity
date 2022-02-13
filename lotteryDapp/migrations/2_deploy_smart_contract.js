// build/Migrations.json의 데이터를 가져옴.
const Lottery = artifacts.require("Lottery");

module.exports = function (deployer) {
  //deployer가 배포하는 형식
  deployer.deploy(Lottery);
};

//스마트 컨트랙트를 배포하기 위해서는 이더리움의 주소가 필요함.
// truffle-config.js 에서 내가 사용할 주소를 셋팅하고, 그 주소를 통해서 , 그 주고가 deployer 변수에 매핑이 됨.(인젝션)
// 이 deployer가 스마트 컨트랙트를 배포해줌.