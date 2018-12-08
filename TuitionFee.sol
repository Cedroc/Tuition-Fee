pragma solidity ^0.4.24;

contract TuitionFee {

    using SafeMath for uint256;
    uint public endTime;
    address public owner;
    bool public active = true;
    mapping (bytes32 => uint) public courselistMapping;

    struct CourseList {
        uint amount;
        address addr;
        bytes32 title;
    }

    CourseList[] public courselists;

    modifier notEnded() { require(true == active); _; }
    
   


	event Pay(address indexed _from, uint256 indexed _courselist);
    event Ended();

	constructor(uint end) public {
        endTime = end;
        owner = msg.sender;
	}

    function getCourseListCount() public constant returns(uint) {
        return courselists.length;
    }

    function add(address addr, bytes32 title) public notEnded returns(uint) {
        require(owner == msg.sender);
        uint index = courselists.length;
        courselistMapping[title] = index;
        courselists.push(CourseList({
            amount: 0,
            addr: addr,
            title: title
        }));
        return index;
    }

	function pay(uint courselist) public notEnded payable {
		courselists[courselist].amount += msg.value;
        emit Pay(msg.sender, courselist);
	}

    function end() notEnded public {
        require(now > endTime);
        uint max = 0;
        address winnerAddress;
        uint balance = address(this).balance;
        owner.transfer(balance.mul(20).div(100));
        for (uint i = 0; i < courselists.length; i++) {
            if (courselists[i].amount > max) {
                max = courselists[i].amount;
                winnerAddress = courselists[i].addr;
            }
            courselists[i].addr.transfer(courselists[i].amount.mul(70).div(100));
        }
        winnerAddress.transfer(address(this).balance);
        active = false;
        emit Ended();
    }
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
