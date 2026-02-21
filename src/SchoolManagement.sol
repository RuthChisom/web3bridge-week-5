/*Create a School management system where people can:
    Register students & Staffs. 
    Pay School fees on registration. 
    Pay staffs also. 
    Get the students and their details. 
    Get all Staffs. 
Pricing is based on grade / levels from 100 - 400 level. 
Payment status can be updated once the payment is made which should include the timestamp.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract SchoolManagement {

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    // =========================
    // STRUCTS
    // =========================

    struct Student {
        uint id;
        string name;
        uint level; // 100 - 400
        uint feesPaidETH;
        mapping(address => uint) feesPaidERC20; // ERC20 token payments
        bool isRegistered;
        uint paymentTimestamp;
    }

    struct Staff {
        uint id;
        string name;
        string role;
        uint salaryPaidETH;
        mapping(address => uint) salaryPaidERC20; // ERC20 token payments
        bool isSuspended;
        uint lastPaymentTimestamp;
        bool exists;
    }

    // =========================
    // STORAGE
    // =========================

    mapping(uint => Student) private students;
    mapping(uint => Staff) private staffs;

    uint public studentCount;
    uint public staffCount;

    mapping(uint => uint) public levelFees; // level => fee in ETH

    // =========================
    // EVENTS
    // =========================

    event StudentRegistered(uint studentId, string name, uint level);
    event FeesPaidETH(uint studentId, uint amount, uint timestamp);
    event FeesPaidERC20(uint studentId, address token, uint amount, uint timestamp);
    event StudentRemoved(uint studentId);

    event StaffRegistered(uint staffId, string name);
    event StaffPaidETH(uint staffId, uint amount, uint timestamp);
    event StaffPaidERC20(uint staffId, address token, uint amount, uint timestamp);
    event StaffSuspended(uint staffId, bool suspended);

    // =========================
    // LEVEL FEES
    // =========================

    function setLevelFee(uint level, uint fee) external onlyOwner {
        require(level >= 100 && level <= 400, "Invalid level");
        levelFees[level] = fee;
    }

    // =========================
    // STUDENT FUNCTIONS
    // =========================

    function registerStudent(string memory _name, uint _level) external payable {
        require(_level >= 100 && _level <= 400, "Invalid level");
        uint requiredFee = levelFees[_level];
        require(msg.value >= requiredFee, "Insufficient school fee");

        studentCount++;
        Student storage s = students[studentCount];
        s.id = studentCount;
        s.name = _name;
        s.level = _level;
        s.feesPaidETH = msg.value;
        s.isRegistered = true;
        s.paymentTimestamp = block.timestamp;

        emit StudentRegistered(studentCount, _name, _level);
        emit FeesPaidETH(studentCount, msg.value, block.timestamp);
    }

    function paySchoolFeesETH(uint studentId) external payable {
        Student storage s = students[studentId];
        require(s.isRegistered, "Student not found");

        s.feesPaidETH += msg.value;
        s.paymentTimestamp = block.timestamp;

        emit FeesPaidETH(studentId, msg.value, block.timestamp);
    }

    // ====== ERC20 Student Payment ======
    function paySchoolFeesERC20(uint studentId, address token, uint amount) external {
        Student storage s = students[studentId];
        require(s.isRegistered, "Student not found");
        require(amount > 0, "Amount must be > 0");

        IERC20 erc20 = IERC20(token);
        require(erc20.transferFrom(msg.sender, address(this), amount), "ERC20 transfer failed");

        s.feesPaidERC20[token] += amount;
        s.paymentTimestamp = block.timestamp;

        emit FeesPaidERC20(studentId, token, amount, block.timestamp);
    }

    // ====== Remove Student ======
    function removeStudent(uint studentId) external onlyOwner {
        require(students[studentId].isRegistered, "Student not found");
        delete students[studentId];
        emit StudentRemoved(studentId);
    }

    function getStudent(uint studentId) external view returns (
        uint id,
        string memory name,
        uint level,
        uint feesPaidETH,
        uint paymentTimestamp,
        bool isRegistered
    ) {
        Student storage s = students[studentId];
        return (s.id, s.name, s.level, s.feesPaidETH, s.paymentTimestamp, s.isRegistered);
    }

    function getStudentERC20Balance(uint studentId, address token) external view returns (uint) {
        return students[studentId].feesPaidERC20[token];
    }

    // =========================
    // STAFF FUNCTIONS
    // =========================

    function registerStaff(string memory _name, string memory _role) external onlyOwner {
        staffCount++;
        Staff storage s = staffs[staffCount];
        s.id = staffCount;
        s.name = _name;
        s.role = _role;
        s.salaryPaidETH = 0;
        s.isSuspended = false;
        s.lastPaymentTimestamp = 0;
        s.exists = true;

        emit StaffRegistered(staffCount, _name);
    }

    function payStaffETH(uint staffId) external payable onlyOwner {
        Staff storage s = staffs[staffId];
        require(s.exists, "Staff not found");
        require(!s.isSuspended, "Staff suspended");

        s.salaryPaidETH += msg.value;
        s.lastPaymentTimestamp = block.timestamp;

        emit StaffPaidETH(staffId, msg.value, block.timestamp);
    }

    // ====== ERC20 Staff Payment ======
    function payStaffERC20(uint staffId, address token, uint amount) external onlyOwner {
        Staff storage s = staffs[staffId];
        require(s.exists, "Staff not found");
        require(!s.isSuspended, "Staff suspended");
        require(amount > 0, "Amount must be > 0");

        IERC20 erc20 = IERC20(token);
        require(erc20.transferFrom(msg.sender, address(this), amount), "ERC20 transfer failed");

        s.salaryPaidERC20[token] += amount;
        s.lastPaymentTimestamp = block.timestamp;

        emit StaffPaidERC20(staffId, token, amount, block.timestamp);
    }

    // ====== Suspend Staff ======
    function suspendStaff(uint staffId, bool suspend) external onlyOwner {
        Staff storage s = staffs[staffId];
        require(s.exists, "Staff not found");
        s.isSuspended = suspend;

        emit StaffSuspended(staffId, suspend);
    }

    function getStaff(uint staffId) external view returns (
        uint id,
        string memory name,
        string memory role,
        uint salaryPaidETH,
        uint lastPaymentTimestamp,
        bool isSuspended
    ) {
        Staff storage s = staffs[staffId];
        return (s.id, s.name, s.role, s.salaryPaidETH, s.lastPaymentTimestamp, s.isSuspended);
    }

    function getStaffERC20Balance(uint staffId, address token) external view returns (uint) {
        return staffs[staffId].salaryPaidERC20[token];
    }

    // =========================
    // CONTRACT BALANCE
    // =========================

    function contractBalance() external view returns (uint) {
        return address(this).balance;
    }

    function withdrawFunds(uint amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");
        payable(owner).transfer(amount);
    }
}
