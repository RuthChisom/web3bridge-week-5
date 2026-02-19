
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SchoolManagement {

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    // STRUCTS

    struct Student {
        uint id;
        string name;
        uint level; // 100 - 400
        uint feesPaid;
        bool isRegistered;
        uint paymentTimestamp;
    }

    struct Staff {
        uint id;
        string name;
        string role;
        uint salaryPaid;
        uint paymentTimestamp;
        bool exists;
    }

    // =========================
    // STORAGE
    // =========================

    mapping(uint => Student) public students;
    mapping(uint => Staff) public staffs;

    uint public studentCount;
    uint public staffCount;

    // Level pricing (fees per level)
    mapping(uint => uint) public levelFees;

    // =========================
    // EVENTS
    // =========================

    event StudentRegistered(uint studentId, string name, uint level);
    event FeesPaid(uint studentId, uint amount, uint timestamp);
    event StaffRegistered(uint staffId, string name);
    event StaffPaid(uint staffId, uint amount, uint timestamp);

    // =========================
    // SET LEVEL FEES
    // =========================

    function setLevelFee(uint level, uint fee) external onlyOwner {
        require(level >= 100 && level <= 400, "Invalid level");
        levelFees[level] = fee;
    }

    // =========================
    // REGISTER STUDENT (WITH PAYMENT)
    // =========================

    function registerStudent(
        string memory _name,
        uint _level
    ) external payable {

        require(_level >= 100 && _level <= 400, "Invalid level");

        uint requiredFee = levelFees[_level];
        require(msg.value >= requiredFee, "Insufficient school fee");

        studentCount++;

        students[studentCount] = Student({
            id: studentCount,
            name: _name,
            level: _level,
            feesPaid: msg.value,
            isRegistered: true,
            paymentTimestamp: block.timestamp
        });

        emit StudentRegistered(studentCount, _name, _level);
        emit FeesPaid(studentCount, msg.value, block.timestamp);
    }

    // =========================
    // PAY ADDITIONAL SCHOOL FEES
    // =========================

    function paySchoolFees(uint studentId) external payable {
        require(students[studentId].isRegistered, "Student not found");

        students[studentId].feesPaid += msg.value;
        students[studentId].paymentTimestamp = block.timestamp;

        emit FeesPaid(studentId, msg.value, block.timestamp);
    }

    // =========================
    // REGISTER STAFF
    // =========================

    function registerStaff(
        string memory _name,
        string memory _role
    ) external onlyOwner {

        staffCount++;

        staffs[staffCount] = Staff({
            id: staffCount,
            name: _name,
            role: _role,
            salaryPaid: 0,
            paymentTimestamp: 0,
            exists: true
        });

        emit StaffRegistered(staffCount, _name);
    }

    // =========================
    // PAY STAFF
    // =========================

    function payStaff(uint staffId) external payable onlyOwner {
        require(staffs[staffId].exists, "Staff not found");
        require(msg.value > 0, "No payment sent");

        staffs[staffId].salaryPaid += msg.value;
        staffs[staffId].paymentTimestamp = block.timestamp;

        emit StaffPaid(staffId, msg.value, block.timestamp);
    }

    // =========================
    // GET STUDENT DETAILS
    // =========================

    function getStudent(uint studentId)
        external
        view
        returns (Student memory)
    {
        return students[studentId];
    }

    // =========================
    // GET ALL STAFF IDS (Simple List)
    // =========================

    function getAllStaffCount() external view returns (uint) {
        return staffCount;
    }

    // =========================
    // WITHDRAW SCHOOL FUNDS
    // =========================

    function withdrawFunds(uint amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");

        payable(owner).transfer(amount);
    }

    // =========================
    // CONTRACT BALANCE
    // =========================

    function contractBalance() external view returns (uint) {
        return address(this).balance;
    }
}
