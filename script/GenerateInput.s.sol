//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";

contract GenerateInput is Script {
    uint256 private constant AMOUNT = 25 * 1e18;
    string[] types = new string[](2);
    uint256 count;
    string[] whitelist = new string[](4);
    string private constant INPUT_PATH = "/script/target/input.json";

    function run() public {
        types[0] = "address";
        types[1] = "uint";
        whitelist[0] = "0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D";
        whitelist[1] = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
        whitelist[2] = "0xa7D069b1bA1bc4ef9298d88A6a3Ff39e6a4e58cd";
        whitelist[3] = "0x87E579d724aEe0dfFd9D2cc4E5b2329D2f6dfDC0";
        count = whitelist.length;
        string memory input = _createJSON();
        vm.writeFile(string.concat(vm.projectRoot(), INPUT_PATH), input);
    }

    function _createJSON() public view returns (string memory) {
        string memory countString = vm.toString(count);
        string memory amountString = vm.toString(AMOUNT);
        string memory json = string.concat('{ "types": ["address","uint"], "count": ', countString, ',"values": {');
        for (uint256 i = 0; i < count; i++) {
            if (i == count - 1) {
                json = string.concat(
                    json,
                    '"',
                    vm.toString(i),
                    '"',
                    ': { "0": ',
                    '"',
                    whitelist[i],
                    '"',
                    ',"1": ',
                    '"',
                    amountString,
                    '"',
                    " }"
                );
            } else {
                json = string.concat(
                    json,
                    '"',
                    vm.toString(i),
                    '"',
                    ': { "0": ',
                    '"',
                    whitelist[i],
                    '"',
                    ',"1": ',
                    '"',
                    amountString,
                    '"',
                    " },"
                );
            }
        }
        json = string.concat(json, " } }");
        return json;
    }
}
