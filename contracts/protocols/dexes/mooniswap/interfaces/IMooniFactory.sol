// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "contracts/tokens/erc20/interfaces/IERC20.sol";
import "./IMooniPair.sol";


interface IMooniFactory {
    // uint256 public fee;
    // Mooniswap[] public allPools;
    // mapping(Mooniswap => bool) public isPool;
    // mapping(IERC20 => mapping(IERC20 => Mooniswap)) public pools;
    function pools(
        IERC20 tokenA,
        IERC20 tokenB
    ) external view returns (IMooniPair);

    // function getAllPools() external view returns(Mooniswap[] memory);

    function setFee(uint256 newFee) external;

    function deployTokens(
        IERC20 tokenA,
        IERC20 tokenB
    ) external returns (IMooniPair pool);

    function sortTokens(
        IERC20 tokenA,
        IERC20 tokenB
    ) external pure returns (IERC20, IERC20);
}
