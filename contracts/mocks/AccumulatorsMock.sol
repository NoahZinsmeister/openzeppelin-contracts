// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/structs/Accumulators.sol";
import "../utils/Timers.sol";

contract AccumulatorsMock {
    using Accumulators for Accumulators.BlockNumberAccumulator;

    Accumulators.BlockNumberAccumulator public blockNumberAccumulator;

    function prepareForFailingTestUNSAFE() external {
        blockNumberAccumulator.sum = type(uint192).max;
    }

    function initialize(uint64 blockNumber) external {
        blockNumberAccumulator = Accumulators.initialize(Timers.BlockNumber({ _deadline: blockNumber }));
    }

    function increment(uint64 blockNumber, uint128 value) external {
        blockNumberAccumulator = blockNumberAccumulator.increment(Timers.BlockNumber({ _deadline: blockNumber }), value);
    }

    function getArithmeticMean(Accumulators.BlockNumberAccumulator calldata a) external view returns (uint128) {
        return blockNumberAccumulator.getArithmeticMean(a);
    }
}
