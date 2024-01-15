// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenSale is Ownable {
    using SafeMath for uint256;

    ERC20 public projectTokenAddress;

    uint256 public presaleMinCap;
    uint256 public presaleMaxCap;
    uint256 public publicSaleMinCap;
    uint256 public publicSaleMaxCap;

    uint256 public presaleMinContribution;
    uint256 public presaleMaxContribution;
    uint256 public publicSaleMinContribution;
    uint256 public publicSaleMaxContribution;

    uint256 public presaleEndTime;
    uint256 public publicSaleStartTime;
    uint256 public publicSaleEndTime;

    uint256 public totalAmountRaisedInPresale;
    uint256 public totalAmountRaisedInPublicSale;

    uint256 public constant FIXED_CONVERSION_VALUE = 10;

    string public constant PRE_SALE_LITERAL = "PRE_SALE";
    string public constant PUBLIC_SALE_LITERAL = "PUBLIC_SALE";

    mapping(address => uint256) presaleContributions;
    mapping(address => uint256) publicSaleContributions;

    event TokenBought(
        address indexed buyer,
        uint256 numberOfTokensBought,
        string saleType
    );
    event RefundProcessed(address indexed contributor, uint256 refundedAmount);
    event DistributedToken(address indexed recipient, uint256 numberOfTokens);

    modifier isPresaleOngoing() {
        require(block.timestamp < presaleEndTime, "Presale is closed");
        _;
    }

    modifier isPublicSaleOngoing() {
        require(
            block.timestamp > publicSaleStartTime &&
                block.timestamp <= publicSaleEndTime,
            "Public sale is either closed or hasn't started yet"
        );
        _;
    }

    constructor(
        ERC20 _projectTokenAddress,
        uint256 _presaleMinCap,
        uint256 _presaleMaxCap,
        uint256 _publicSaleMinCap,
        uint256 _publicSaleMaxCap,
        uint256 _presaleMinContribution,
        uint256 _presaleMaxContribution,
        uint256 _publicSaleMinContribution,
        uint256 _publicSaleMaxContribution,
        uint256 _presaleEndTime,
        uint256 _publicSaleEndTime
    ) Ownable(msg.sender) {
        require(
            _presaleEndTime < _publicSaleEndTime,
            "Public Sale has to begin and therefore end after Presale ends"
        );
        require(
            _presaleMinCap < _presaleMaxCap,
            "Presale Min cap is greater than presale Max cap"
        );
        require(
            _publicSaleMinCap < _publicSaleMaxCap,
            "Public Sale Min cap is greater than public sale Max cap"
        );
        require(
            _presaleMinContribution < _presaleMaxContribution,
            "Presale Min Contribution is greater than Presale Max Contribution"
        );
        require(
            _publicSaleMinContribution < _publicSaleMaxContribution,
            "Public Sale Min Contribution is greater than public Sale Max Contribution"
        );

        projectTokenAddress = _projectTokenAddress;
        presaleMinCap = _presaleMinCap;
        presaleMaxCap = _presaleMaxCap;
        publicSaleMinCap = _publicSaleMinCap;
        publicSaleMaxCap = _publicSaleMaxCap;
        presaleMinContribution = _presaleMinContribution;
        presaleMaxContribution = _presaleMaxContribution;
        publicSaleMinContribution = _publicSaleMinContribution;
        publicSaleMaxContribution = _publicSaleMaxContribution;
        presaleEndTime = _presaleEndTime;
        publicSaleStartTime = _presaleEndTime;
        publicSaleEndTime = _publicSaleEndTime;
    }

    function contributeEtherToPresale() external payable isPresaleOngoing {
        require(
            msg.value >= presaleMinContribution,
            "Presale Minumum cap on contribution violation"
        );
        require(
            presaleContributions[msg.sender].add(msg.value) <=
                presaleMaxContribution,
            "Presale Maximum cap on contribution violation"
        );
        require(
            totalAmountRaisedInPresale.add(msg.value) <= presaleMaxCap,
            "Presale Maximum cap violation"
        );

        presaleContributions[msg.sender] = presaleContributions[msg.sender].add(
            msg.value
        );

        totalAmountRaisedInPresale = totalAmountRaisedInPresale.add(msg.value);
        // send token to users.
        _executeTokenPurchase(msg.sender, msg.value, PRE_SALE_LITERAL);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function contributeEtherToPublicSale()
        external
        payable
        isPublicSaleOngoing
    {
        require(
            msg.value >= publicSaleMinContribution,
            "Public Sale Minimum cap on contribution violation"
        );
        require(
            publicSaleContributions[msg.sender].add(msg.value) <=
                publicSaleMaxContribution,
            "Public Sale Maximum cap on contribution violation"
        );

        require(
            totalAmountRaisedInPublicSale.add(msg.value) <= publicSaleMaxCap,
            "Public Sale Maximum Cap violation"
        );

        publicSaleContributions[msg.sender] = publicSaleContributions[
            msg.sender
        ].add(msg.value);
        totalAmountRaisedInPublicSale = totalAmountRaisedInPublicSale.add(
            msg.value
        );
        // send token to users
        _executeTokenPurchase(msg.sender, msg.value, PUBLIC_SALE_LITERAL);
    }

    function distributeToken(address recipient, uint256 numberOfTokens)
        external
        onlyOwner
    {
        // check the token supply
        require(
            projectTokenAddress.balanceOf(address(this)) >= numberOfTokens,
            "Insufficient supply"
        );
        projectTokenAddress.transfer(recipient, numberOfTokens);

        emit DistributedToken(recipient, numberOfTokens);
    }

    function claimFullRefund() external {
        // user is able to claim a refund only after the end of the public sale
        require(
            block.timestamp > publicSaleEndTime,
            "Public sale or Presale has not ended. Please wait for the completion."
        );
        require(
            totalAmountRaisedInPresale < presaleMinCap ||
                totalAmountRaisedInPublicSale < publicSaleMinCap,
            "Both Min caps were reached"
        );

        uint256 refundAmount = presaleContributions[msg.sender];
        refundAmount = refundAmount.add(publicSaleContributions[msg.sender]);
        require(
            refundAmount > 0,
            "Message sender is not a contributor or has already claimed the refund"
        );

        require(
            projectTokenAddress.allowance(msg.sender, address(this)) >=
                getExchangeRate(refundAmount),
            "Insuffucient allowance"
        );

        require(
            projectTokenAddress.balanceOf(msg.sender) >=
                getExchangeRate(refundAmount),
            "Insufficient Project Token in your account"
        );

        presaleContributions[msg.sender] = 0;
        publicSaleContributions[msg.sender] = 0;

        // transfer ERC20 token to ourselves
        projectTokenAddress.transferFrom(
            msg.sender,
            address(this),
            getExchangeRate(refundAmount)
        );
        // send ether back
        payable(msg.sender).transfer(refundAmount);

        emit RefundProcessed(msg.sender, refundAmount);
    }

    // Utility functions
    function _executeTokenPurchase(
        address buyer,
        uint256 amountInWei,
        string memory saleType
    ) internal {
        uint256 projectTokenAmount = getExchangeRate(amountInWei);

        // assume token is already minted and we have a fix supply already instead of on-fly-minting
        // which could also have been done
        require(
            projectTokenAddress.balanceOf(address(this)) >= projectTokenAmount,
            "Insufficient supply"
        );
        projectTokenAddress.transfer(buyer, projectTokenAmount);

        emit TokenBought(buyer, projectTokenAmount, saleType);
    }

    function getExchangeRate(uint256 amountInWei)
        internal
        pure
        returns (uint256)
    {
        // I am predefining a conversion rate at
        // 1 ETHER = 10 tokens (FIXED_CONVERSION_VALUE)
        // project Token has denomination of 10^18
        return amountInWei.mul(FIXED_CONVERSION_VALUE);
    }
}
