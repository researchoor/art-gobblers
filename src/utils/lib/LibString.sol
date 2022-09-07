// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/// @notice Efficient library for creating string representations of integers.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/v7/src/utils/LibString.sol)
library LibString {
    function toString(uint256 n) internal pure returns (string memory str) {
        if (n == 0) return "0"; // Otherwise it'd output an empty string for 0.

        assembly {
            let k := 96 // The max length of a uint256 string, 78 bytes, word aligned to 96 bytes as is convention.

            // Grab the destination of the free memory pointer. We'll store our string length and content offset from it.
            str := mload(0x40)

            // Update the free memory pointer to prevent overriding our string. We
            // need to allocate 5 32-byte words for our string, so we increment the free
            // memory pointer by 160 (32 * 5). The first word is used to store the length of the
            // string. We use up to 3 words to store digits (96 bytes). We also leave an extra word
            // of zeros at the end, such that there are no dirty bits at the end of our string encoding.
            mstore(0x40, add(str, 160))

            // Clean last two words of memory as they may not be overwritten.
            mstore(add(str, 96), 0)
            mstore(add(str, 128), 0)

            // We'll populate the string from right to left.
            // prettier-ignore
            for {} n {} {
                // The ASCII digit offset for '0' is 48.
                let char := add(48, mod(n, 10))

                // Write the current character into str. We could use mstore8 here, but we'd
                // have to handle offsetting the pointer by 31 bytes which would take extra gas.
                mstore(add(str, k), char)

                k := sub(k, 1)
                n := div(n, 10)
            }

            // Shift the pointer to the start of the string.
            str := add(str, k)

            // Set the length of the string to the correct value.
            mstore(str, sub(96, k))
        }
    }
}
