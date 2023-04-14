pragma solidity ^0.8.17;
// SPDX-License-Identifier: AGPL-3.0-or-later
// Origami (interfaces/investments/IOrigamiInvestment.sol)

/**
 * @title Origami Investment
 * @notice Users invest in the underlying protocol and receive a number of this Origami investment in return.
 * Origami will apply the accepted investment token into the underlying protocol in the most optimal way.
 */
interface IOrigamiInvestment {

    /**
     * @notice Quote data required when entering into this investment.
     */
    struct InvestQuoteData {
        /// @notice The token used to invest, which must be one of `acceptedInvestTokens()`
        address fromToken;

        /// @notice The quantity of `fromToken` to invest with
        uint256 fromTokenAmount;

        /// @notice The maximum acceptable slippage of the `expectedInvestmentAmount`
        uint256 maxSlippageBps;

        /// @notice The maximum deadline to execute the transaction.
        uint256 deadline;

        /// @notice The expected amount of this Origami Investment token to receive in return
        uint256 expectedInvestmentAmount;

        /// @notice The minimum amount of this Origami Investment Token to receive after
        /// slippage has been applied.
        uint256 minInvestmentAmount;

        /// @notice Any extra quote parameters required by the underlying investment
        bytes underlyingInvestmentQuoteData;
    }

    /**
     * @notice Quote data required when exoomg this investment.
     */
    struct ExitQuoteData {
        /// @notice The amount of this investment to sell
        uint256 investmentTokenAmount;

        /// @notice The token to sell into, which must be one of `acceptedExitTokens()`
        address toToken;

        /// @notice The maximum acceptable slippage of the `expectedToTokenAmount`
        uint256 maxSlippageBps;

        /// @notice The maximum deadline to execute the transaction.
        uint256 deadline;

        /// @notice The expected amount of `toToken` to receive in return
        /// @dev Note slippage is applied to this when calling `invest()`
        uint256 expectedToTokenAmount;

        /// @notice The minimum amount of `toToken` to receive after
        /// slippage has been applied.
        uint256 minToTokenAmount;

        /// @notice Any extra quote parameters required by the underlying investment
        bytes underlyingInvestmentQuoteData;
    }


    /**
      * @notice User buys this Origami investment with an amount of one of the approved ERC20 tokens.
      * @param quoteData The quote data received from investQuote()
      * @return investmentAmount The actual number of this Origami investment tokens received.
      */
    function investWithToken(
        InvestQuoteData calldata quoteData
    ) external returns (
        uint256 investmentAmount
    );

    /**
      * @notice User buys this Origami investment with an amount of native chain token (ETH/AVAX)
      * @param quoteData The quote data received from investQuote()
      * @return investmentAmount The actual number of this Origami investment tokens received.
      */
    function investWithNative(
        InvestQuoteData calldata quoteData
    ) external payable returns (
        uint256 investmentAmount
    );

    /**
      * @notice Sell this Origami investment to receive one of the accepted tokens.
      * @param quoteData The quote data received from exitQuote()
      * @param recipient The receiving address of the `toToken`
      * @return toTokenAmount The number of `toToken` tokens received upon selling the Origami investment tokens.
      */
    function exitToToken(
        ExitQuoteData calldata quoteData,
        address recipient
    ) external returns (
        uint256 toTokenAmount
    );

    /**
      * @notice Sell this Origami investment to native ETH/AVAX.
      * @param quoteData The quote data received from exitQuote()
      * @param recipient The receiving address of the native chain token.
      * @return nativeAmount The number of native chain ETH/AVAX/etc tokens received upon selling the Origami investment tokens.
      */
    function exitToNative(
        ExitQuoteData calldata quoteData,
        address payable recipient
    ) external returns (
        uint256 nativeAmount
    );
}