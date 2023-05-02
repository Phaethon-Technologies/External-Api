// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract MyContract is ChainlinkClient {

  uint256 public data;

  constructor() public {

    setChainlinkOracle(0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD);
    setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b4624789);
  }


  function requestData(string memory _url, string memory _path) public {
    Chainlink.Request memory req = buildChainlinkRequest(
      0,
      address(this),
      this.fulfill.selector
    );
    req.add("get", _url);
    req.add("path", _path);
    sendChainlinkRequest(req, 1 * LINK);
  }


  function fulfill(bytes32 _requestId, uint256 _data) public recordChainlinkFulfillment(_requestId) {
    data = _data;
  }
}
