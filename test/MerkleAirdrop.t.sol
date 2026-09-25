//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";

contract MerkleAirdropTest is Test {
    using stdJson for string; // enables us to use the json cheatcodes for strings
    BagelToken public bagelToken;
    MerkleAirdrop public merkleAirdrop;

    string private outputPath = "/script/target/output.json";
    bytes32 public merkleRoot;
    address public user;
    uint256 public userPrivKey;
    uint256 public constant AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 public constant AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;
    bytes32[] public proof;

    struct MerkleData {
        string[] inputs;
        bytes32[] proof;
        bytes32 root;
        bytes32 leaf;
    }

    function setUp() public {
        (user, userPrivKey) = makeAddrAndKey("user");
        string memory merkleOutputFile = vm.readFile(string.concat(vm.projectRoot(), outputPath));
        merkleRoot = vm.parseBytes32(merkleOutputFile.readString("[0].root"));
        for (uint256 i = 0; i < 4; ++i) {
            address userInput = merkleOutputFile.readAddress(string.concat("[", vm.toString(i), "].inputs[0]"));
            if (userInput == user) {
                string[] memory stringProof =
                    merkleOutputFile.readStringArray(string.concat("[", vm.toString(i), "].proof"));
                for (uint256 j = 0; j < stringProof.length; j++) {
                    proof.push(vm.parseBytes32(stringProof[j]));
                }
            }
        }
        vm.startBroadcast();
        bagelToken = new BagelToken();
        merkleAirdrop = new MerkleAirdrop(merkleRoot, IERC20(address(bagelToken)));
        bagelToken.mint(bagelToken.owner(), AMOUNT_TO_SEND);
        bagelToken.transfer(address(merkleAirdrop), AMOUNT_TO_SEND);
        vm.stopBroadcast();
    }

    function testUserCanClaim() public {
        uint256 initialBalance = bagelToken.balanceOf(user);
        vm.prank(user);
        merkleAirdrop.claim(user, AMOUNT_TO_CLAIM, proof);
        uint256 finalBalance = bagelToken.balanceOf(user);
        console.log("ENDING BALANCE", finalBalance);
        vm.assertEq(finalBalance - initialBalance, AMOUNT_TO_CLAIM);
    }
}
