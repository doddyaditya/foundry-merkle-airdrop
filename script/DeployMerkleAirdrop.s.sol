//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {stdJson} from "forge-std/StdJson.sol";

import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";

contract DeployMerkleAirdrop is Script {
    using stdJson for string;
    string private outputPath = "/script/target/output.json";
    MerkleAirdrop public merkleAirdrop;
    BagelToken public bagelToken;
    bytes32 private s_merkleRoot;
    uint256 private s_amountToTransfer = 25 * 1e18;

    function run() external returns (MerkleAirdrop, BagelToken, string memory) {
        string memory merkleOutputFile = vm.readFile(string.concat(vm.projectRoot(), outputPath));
        s_merkleRoot = vm.parseBytes32(merkleOutputFile.readString("[0].root"));
        vm.startBroadcast();
        bagelToken = new BagelToken();
        merkleAirdrop = new MerkleAirdrop(s_merkleRoot, IERC20(address(bagelToken)));
        bagelToken.mint(bagelToken.owner(), s_amountToTransfer);
        bagelToken.transfer(address(merkleAirdrop), s_amountToTransfer);
        vm.stopBroadcast();
        return (merkleAirdrop, bagelToken, merkleOutputFile);
    }
}
