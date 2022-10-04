//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MerkleDistributor {
    address public immutable factory;
    address public immutable token;
    bytes32 public immutable merkleRoot;

    mapping(uint256 => uint256) private claimedBitMap;

    event Claimed(address account, uint256 amount);

    constructor(address _token, bytes32 _merkleRoot) {
        factory = msg.sender;
        token = _token;
        merkleRoot = _merkleRoot;
    }

    function isClaimed(uint256 userIndex) public view returns (bool) {
        uint256 claimedIndex = userIndex / 256;
        uint256 claimedBit = userIndex % 256;
        uint256 userBit = claimedBitMap[claimedIndex];
        uint256 mask = (1 << claimedBit);
        return userBit & mask == mask;
    }

    function setClaimed(uint256 userIndex) private {
        uint256 claimedIndex = userIndex / 256;
        uint256 claimedBit = userIndex % 256;
        claimedBitMap[claimedIndex] = claimedBitMap[claimedIndex] | (1 << claimedBit);
    }

    function claim(uint256 userIndex, address account, uint256 amount, bytes32[] calldata merkleProof) public {
        require(!isClaimed(userIndex), 'MerkleDistributor: Airdrop already claimed.');

        bytes32 node = keccak256(abi.encodePacked(userIndex, account, amount));

        require(
            MerkleProof.verify(merkleProof, merkleRoot, node),
            "MerkleDistributor: Invalid proof."
        );

        setClaimed(userIndex);

        require(IERC20(token).transfer(account, amount), 'MerkleDistributor: Transfer failed.');

        emit Claimed(account, amount);
    }
}