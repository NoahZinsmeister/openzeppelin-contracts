// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Timers.sol";

library Accumulators {
    using Timers for Timers.BlockNumber;

    // 1 storage slot
    struct BlockNumberAccumulator {
        uint64 blockNumber;
        uint192 sum;
    }

    function initialize(Timers.BlockNumber memory blockNumber)
        internal
        pure
        returns (BlockNumberAccumulator memory)
    {
        return BlockNumberAccumulator({
            blockNumber: blockNumber.getDeadline(),
            sum: 0
        });
    }

    // uses the current block.number
    function initialize() internal view returns (BlockNumberAccumulator memory) {
        return initialize(Timers.BlockNumber({ _deadline: uint64(block.number) }));
    }

    function increment(BlockNumberAccumulator storage accumulator, Timers.BlockNumber memory blockNumber, uint128 value)
        internal
        view
        returns (BlockNumberAccumulator memory)
    {
        require(blockNumber.getDeadline() > accumulator.blockNumber, "Accumulators: no blocks passed");
        uint192 incrementalSum;
        // neither underflow nor overflow are possible, so save some gas by doing unchecked arithmetic
        unchecked {
            uint64 blocksElapsed = blockNumber.getDeadline() - accumulator.blockNumber;
            incrementalSum = uint192(value) * blocksElapsed;
        }
        // the addition below never overflows with correct use, but we still use safe math to ward off misuse
        return BlockNumberAccumulator({
            blockNumber: blockNumber.getDeadline(),
            sum: accumulator.sum + incrementalSum
        });
    }

    // uses the current block.number
    function increment(BlockNumberAccumulator storage accumulator, uint128 value)
        internal
        view
        returns (BlockNumberAccumulator memory)
    {
        return increment(accumulator, Timers.BlockNumber({_deadline: uint64(block.number)}), value);
    }

    function getArithmeticMean(BlockNumberAccumulator memory a, BlockNumberAccumulator memory b)
        internal
        pure
        returns (uint128)
    {
        // ensure that accumulators are sorted in ascending order by block number
        if (a.blockNumber > b.blockNumber) {
            (a, b) = (b, a);
        }
        // the first subtraction below never underflows with correct use, but uses safe math to ward off misuse
        // the second subtraction below never underflows because of the sorting logic above
        // the division fails iff the block numbers of a and b are equal, which indicates misuse
        // the cast cannot truncate
        return uint128((b.sum - a.sum) / (b.blockNumber - a.blockNumber));
    }
}
