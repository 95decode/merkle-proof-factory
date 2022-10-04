// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.1;

import "./MerkleDistributor.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MerkleProofFactory {
    event MerkleDistributorCreated(address indexed token, address merkleRoot);

    constructor() {
        //
    }

    function createDistributor(address _token, bytes32 _merkleRoot, uint256 amount) public {
        bytes memory creationCode = type(MerkleDistributor).creationCode;
        bytes memory initCode = abi.encodePacked(creationCode, abi.encode(_token, _merkleRoot));
        bytes32 salt = keccak256(abi.encodePacked(_token, _merkleRoot, msg.sender));
        address merkleDistributor;

        assembly {
            merkleDistributor := create2(0, add(initCode, 32), mload(initCode), salt)
        }

        IERC20(_token).transferFrom(msg.sender, merkleDistributor, amount);

        emit MerkleDistributorCreated(_token, merkleDistributor);
    }

    function checkLeaf(uint256 userIndex, address account, uint256 amount) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(userIndex, account, amount));
    }
/*
    function checkParent(byte32 hash1, byte32 hash2) public view return byte32 {
        return keccak256()
    }
*/
}