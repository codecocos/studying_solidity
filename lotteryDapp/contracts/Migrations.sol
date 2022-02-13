// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Migrations {
  address public owner = msg.sender;
  uint public last_completed_migration;

  modifier restricted() {
    require(
      msg.sender == owner,
      "This function is restricted to the contract's owner"
    );
    _;
  }
  //completed : migrations 폴더의 파일명의 숫자와 매핑된에 인젝션됨.
  function setCompleted(uint completed) public restricted {
    last_completed_migration = completed;
  }
}
