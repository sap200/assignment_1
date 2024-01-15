// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {TokenSale} from "../src/TokenSale.sol";
import {ProjectToken} from "../src/ProjectToken.sol";

contract TokenSaleTest is Test {
    ProjectToken public projectToken;
    TokenSale public tokenSale;

    uint256 public _presaleMinCap;
    uint256 public _presaleMaxCap;
    uint256 public _publicSaleMinCap;
    uint256 public _publicSaleMaxCap;
    uint256 public _presaleMinContribution;
    uint256 public _presaleMaxContribution;
    uint256 public _publicSaleMinContribution;
    uint256 public _publicSaleMaxContribution;
    uint256 public _presaleEndTime;
    uint256 public _publicSaleEndTime;

    uint256 conversionValue;

    address account1;
    address account2;
    address account3;
    address account4;

    function setUp() public {
        projectToken = new ProjectToken();
        uint256 decimalMultiplier = 10**18;
        _presaleMinCap = 10 ether;
        _presaleMaxCap = 15 ether;
        _publicSaleMinCap = 20 ether;
        _publicSaleMaxCap = 25 ether;
        _presaleMinContribution = 1 ether;
        _presaleMaxContribution = 5 ether;
        _publicSaleMinContribution = 1 ether;
        _publicSaleMaxContribution = 10 ether;
        _presaleEndTime = block.timestamp + 20 seconds;
        _publicSaleEndTime = block.timestamp + 40 seconds;

        conversionValue = 10;

        tokenSale = new TokenSale(
             projectToken,
            _presaleMinCap,
            _presaleMaxCap,
            _publicSaleMinCap,
            _publicSaleMaxCap,
            _presaleMinContribution,
            _presaleMaxContribution,
            _publicSaleMinContribution,
            _publicSaleMaxContribution,
            _presaleEndTime,
            _publicSaleEndTime        
        );

        // assign 1 million token in tokensale's reserve
        projectToken.mint(address(tokenSale), 1000000 * decimalMultiplier);

        // generate 3 accounts with ether balances
        account1 = vm.addr(1);
        account2 = vm.addr(2);
        account3 = vm.addr(3);
        account4 = vm.addr(4);
        vm.deal(account1, 100 ether);
        vm.deal(account2, 100 ether);
        vm.deal(account3, 100 ether);
        vm.deal(account4, 100 ether);
    }

    // TestDescription: A customer contributes ether to presale sending valid amount
    // Expected: The contract balance is expected to increase and customer's address is expected to have ProjectToken
    function test_contributeEtherToPresale() public {
        uint256 initialEtherBalanceOfCustomer = account1.balance;
        uint256 initialProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 intialEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 initialProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        uint256 valueToSend = 3 ether;

        vm.expectEmit(true, false, false, true, address(tokenSale));
        emit TokenSale.TokenBought(account1, valueToSend * 10, tokenSale.PRE_SALE_LITERAL());
        vm.prank(account1);
        tokenSale.contributeEtherToPresale{value : valueToSend }();

        uint256 finalEtherBalanceOfCustomer = account1.balance;
        uint256 finalProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 finalEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 finalProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        assertEq(finalEtherBalanceOfCustomer, initialEtherBalanceOfCustomer - valueToSend);
        assertEq(finalProjectTokenBalanceOfCustomer, initialProjectTokenBalanceOfCustomer + valueToSend*conversionValue);
        assertEq(finalEtherBalanceOfTokenSaleContract, intialEtherBalanceOfTokenSaleContract + valueToSend);
        assertEq(finalProjectTokenBalanceOfTokenSaleContract, initialProjectTokenBalanceOfTokenSaleContract - valueToSend*conversionValue);
    }  

    // TestDescription: A customer contributes ether to presale but violates presaleMinimumCapContribution
    // Expected: We expect vm to revert the transaction
    function test_contributeEtherToPresaleViolatePresaleMinCapContribution() public {
        uint256 initialEtherBalanceOfCustomer = account1.balance;
        uint256 initialProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 intialEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 initialProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        uint256 valueToSend = 3000000000 wei;

        vm.prank(account1);
        vm.expectRevert("Presale Minumum cap on contribution violation");
        tokenSale.contributeEtherToPresale{value : valueToSend }();   

        uint256 finalEtherBalanceOfCustomer = account1.balance;
        uint256 finalProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 finalEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 finalProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        assertEq(finalEtherBalanceOfCustomer, initialEtherBalanceOfCustomer);
        assertEq(finalProjectTokenBalanceOfCustomer, initialProjectTokenBalanceOfCustomer);
        assertEq(finalEtherBalanceOfTokenSaleContract, intialEtherBalanceOfTokenSaleContract);
        assertEq(finalProjectTokenBalanceOfTokenSaleContract, initialProjectTokenBalanceOfTokenSaleContract);
    }

    // TestDescription: A customer contributes ether to presale but violates presaleMaxCapContribution
    // Expected: We expect vm to revert the transaction
    function test_contributeEtherToPresaleViolatePresaleMaxCapContribution() public {
        uint256 initialEtherBalanceOfCustomer = account1.balance;
        uint256 initialProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 intialEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 initialProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        uint256 valueToSend = 6 ether;

        vm.prank(account1);
        vm.expectRevert("Presale Maximum cap on contribution violation");
        tokenSale.contributeEtherToPresale{value : valueToSend }();   

        uint256 finalEtherBalanceOfCustomer = account1.balance;
        uint256 finalProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 finalEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 finalProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        assertEq(finalEtherBalanceOfCustomer, initialEtherBalanceOfCustomer);
        assertEq(finalProjectTokenBalanceOfCustomer, initialProjectTokenBalanceOfCustomer);
        assertEq(finalEtherBalanceOfTokenSaleContract, intialEtherBalanceOfTokenSaleContract);
        assertEq(finalProjectTokenBalanceOfTokenSaleContract, initialProjectTokenBalanceOfTokenSaleContract);
    }

    // TestDescription: A customer contributes ether to presale but maximum cap on presale is violated on contribution
    // Expected: We expect vm to revert
    function test_contribtueEtherToPresaleViolatePresaleMaxCap() public {
        // Account 2,3,4 sends 5,5,4 ether respectively to the presale, that makes 14 ether
        vm.prank(account2);
        tokenSale.contributeEtherToPresale{value : 5 ether }();

        vm.prank(account3);
        tokenSale.contributeEtherToPresale{value : 5 ether }();


        vm.prank(account4);
        tokenSale.contributeEtherToPresale{value : 4 ether }();



        // Track intial balances 
        uint256 initialEtherBalanceOfCustomer = account1.balance;
        uint256 initialProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 intialEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 initialProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        // Account 1 sends 3 ether to presale that violates presaleMaxEtherCap, and hence is not considered
        vm.prank(account1);
        vm.expectRevert("Presale Maximum cap violation");
        tokenSale.contributeEtherToPresale{value: 3 ether}();

        // we expect the txn to reverse and hence no change in balance
        uint256 finalEtherBalanceOfCustomer = account1.balance;
        uint256 finalProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 finalEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 finalProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        assertEq(finalEtherBalanceOfCustomer, initialEtherBalanceOfCustomer);
        assertEq(finalProjectTokenBalanceOfCustomer, initialProjectTokenBalanceOfCustomer);
        assertEq(finalEtherBalanceOfTokenSaleContract, intialEtherBalanceOfTokenSaleContract);
        assertEq(finalProjectTokenBalanceOfTokenSaleContract, initialProjectTokenBalanceOfTokenSaleContract);
    }

    // TestDescription: User tries to contribute to presale after the presale has ended
    // Expected: We expect the VM to revert
    function test_contributeEtherToPresaleAfterPresaleEnded() public {
        // end presale by forwarding time
        vm.warp(block.timestamp + 21 seconds);

         // Track intial balances 
        uint256 initialEtherBalanceOfCustomer = account1.balance;
        uint256 initialProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 intialEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 initialProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        // Account 1 sends 3 ether to presale that violates presaleMaxEtherCap, and hence is not considered
        vm.prank(account1);
        vm.expectRevert("Presale is closed");
        tokenSale.contributeEtherToPresale{value: 3 ether}();

        
        // we expect the txn to reverse and hence no change in balance
        uint256 finalEtherBalanceOfCustomer = account1.balance;
        uint256 finalProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 finalEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 finalProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        assertEq(finalEtherBalanceOfCustomer, initialEtherBalanceOfCustomer);
        assertEq(finalProjectTokenBalanceOfCustomer, initialProjectTokenBalanceOfCustomer);
        assertEq(finalEtherBalanceOfTokenSaleContract, intialEtherBalanceOfTokenSaleContract);
        assertEq(finalProjectTokenBalanceOfTokenSaleContract, initialProjectTokenBalanceOfTokenSaleContract);
    }

    // TestDescription: User tries to contribute ether to public sale but public sale has not begun yet
    // Expected: We expect the VM to revert
    function test_contributeEtherToPublicSaleBeforeItBegan() public {
        // Track intial balances 
        uint256 initialEtherBalanceOfCustomer = account1.balance;
        uint256 initialProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 intialEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 initialProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        // Account 1 sends 3 ether to presale that violates presaleMaxEtherCap, and hence is not considered
        vm.prank(account1);
        vm.expectRevert("Public sale is either closed or hasn't started yet");
        tokenSale.contributeEtherToPublicSale{value: 3 ether}();

        
        // we expect the txn to reverse and hence no change in balance
        uint256 finalEtherBalanceOfCustomer = account1.balance;
        uint256 finalProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 finalEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 finalProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        assertEq(finalEtherBalanceOfCustomer, initialEtherBalanceOfCustomer);
        assertEq(finalProjectTokenBalanceOfCustomer, initialProjectTokenBalanceOfCustomer);
        assertEq(finalEtherBalanceOfTokenSaleContract, intialEtherBalanceOfTokenSaleContract);
        assertEq(finalProjectTokenBalanceOfTokenSaleContract, initialProjectTokenBalanceOfTokenSaleContract);
    }

    // TestDescription: On Start of public sale, user tries to contribute to public sale but violates minimum cap on contribution
    // Expected: We expect txn to be reverted
    function test_contributeEtherToPublicSaleViolatePublicSaleMinCapContribution() public {
        // fast forward vm time to start public sale
        vm.warp(block.timestamp + 21 seconds);

        // Track intial balances 
        uint256 initialEtherBalanceOfCustomer = account1.balance;
        uint256 initialProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 intialEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 initialProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        // Account 1 sends 3 ether to presale that violates presaleMaxEtherCap, and hence is not considered
        vm.prank(account1);
        vm.expectRevert("Public Sale Minimum cap on contribution violation");
        tokenSale.contributeEtherToPublicSale{value: 300000 wei}();

        
        // we expect the txn to reverse and hence no change in balance
        uint256 finalEtherBalanceOfCustomer = account1.balance;
        uint256 finalProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 finalEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 finalProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        assertEq(finalEtherBalanceOfCustomer, initialEtherBalanceOfCustomer);
        assertEq(finalProjectTokenBalanceOfCustomer, initialProjectTokenBalanceOfCustomer);
        assertEq(finalEtherBalanceOfTokenSaleContract, intialEtherBalanceOfTokenSaleContract);
        assertEq(finalProjectTokenBalanceOfTokenSaleContract, initialProjectTokenBalanceOfTokenSaleContract);
    }

    // TestDescription: Public sale is ongoing, user tries to contribute to public sale but violates maximum cap on contribution
    // Expected: We expect the txn to revert
    function test_contributeEtherToPublicSaleViolateMaximumCapOnContribution() public {
        // fast forward vm time to start public sale
        vm.warp(block.timestamp + 21 seconds);

        // Track intial balances 
        uint256 initialEtherBalanceOfCustomer = account1.balance;
        uint256 initialProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 intialEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 initialProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        // Account 1 sends 3 ether to presale that violates presaleMaxEtherCap, and hence is not considered
        vm.prank(account1);
        vm.expectRevert("Public Sale Maximum cap on contribution violation");
        tokenSale.contributeEtherToPublicSale{value: 13 ether}();

        
        // we expect the txn to reverse and hence no change in balance
        uint256 finalEtherBalanceOfCustomer = account1.balance;
        uint256 finalProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 finalEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 finalProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        assertEq(finalEtherBalanceOfCustomer, initialEtherBalanceOfCustomer);
        assertEq(finalProjectTokenBalanceOfCustomer, initialProjectTokenBalanceOfCustomer);
        assertEq(finalEtherBalanceOfTokenSaleContract, intialEtherBalanceOfTokenSaleContract);
        assertEq(finalProjectTokenBalanceOfTokenSaleContract, initialProjectTokenBalanceOfTokenSaleContract);
    }

    // TestDescription: Public sale is ongoing, user contributes valid amount to public sale adhering the limit of capping
    // Expected: Txn is executed successfully, ether is added to the account balance of contract and user receives ProjectToken
    function test_contributeEtherToPublicSale() public {
        // fast forward vm time to start public sale
        vm.warp(block.timestamp + 21 seconds);

        // Track intial balances 
        uint256 initialEtherBalanceOfCustomer = account1.balance;
        uint256 initialProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 intialEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 initialProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        // Account 1 sends 3 ether to presale that violates presaleMaxEtherCap, and hence is not considered
        uint256 valueToSend = 7 ether;
        vm.expectEmit(true, false, false, true, address(tokenSale));
        emit TokenSale.TokenBought(account1, valueToSend * 10, tokenSale.PUBLIC_SALE_LITERAL());
        vm.prank(account1);
        tokenSale.contributeEtherToPublicSale{value: valueToSend}();

        
        // we expect the txn to reverse and hence no change in balance
        uint256 finalEtherBalanceOfCustomer = account1.balance;
        uint256 finalProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 finalEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 finalProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        assertEq(finalEtherBalanceOfCustomer, initialEtherBalanceOfCustomer - 7 ether);
        assertEq(finalProjectTokenBalanceOfCustomer, initialProjectTokenBalanceOfCustomer + conversionValue * valueToSend);
        assertEq(finalEtherBalanceOfTokenSaleContract, intialEtherBalanceOfTokenSaleContract + valueToSend);
        assertEq(finalProjectTokenBalanceOfTokenSaleContract, initialProjectTokenBalanceOfTokenSaleContract - conversionValue * valueToSend);
    }

    // TestDescription: public sale is ongoing, user contributes valid amount to public sale adhering the limit of capping, but public sale max cap is violated
    // Expected: We expect the txn to be reverted by VM
    function test_contributeEtherToPublicSaleViolateMaximumCapOnPublicSale() public {
        // fast forward vm time to start public sale
        vm.warp(block.timestamp + 21 seconds);

        // account 2, 3 sends 10, 10 ether making up balance of 20 ether on public sale.

        vm.prank(account2);
        tokenSale.contributeEtherToPublicSale{value: 10 ether}();

        vm.prank(account3);
        tokenSale.contributeEtherToPublicSale{value: 10 ether}();

        // Track intial balances 
        uint256 initialEtherBalanceOfCustomer = account1.balance;
        uint256 initialProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 intialEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 initialProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));


        vm.prank(account1);
        vm.expectRevert("Public Sale Maximum Cap violation");
        tokenSale.contributeEtherToPublicSale{value: 6 ether}();

        // we expect the txn to reverse and hence no change in balance
        uint256 finalEtherBalanceOfCustomer = account1.balance;
        uint256 finalProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 finalEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 finalProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        assertEq(finalEtherBalanceOfCustomer, initialEtherBalanceOfCustomer);
        assertEq(finalProjectTokenBalanceOfCustomer, initialProjectTokenBalanceOfCustomer);
        assertEq(finalEtherBalanceOfTokenSaleContract, intialEtherBalanceOfTokenSaleContract);
        assertEq(finalProjectTokenBalanceOfTokenSaleContract, initialProjectTokenBalanceOfTokenSaleContract);
    }

    // TestDescription: Public Sale has Ended, User tries to contribute to public sale
    // Expected: We expect txn to be reverted by the VM
    function test_contributeEtherToPublicSaleWhenItHasEnded() public {
        // fast forward vm time to end public sale
        vm.warp(block.timestamp + 41 seconds);

        // Track intial balances 
        uint256 initialEtherBalanceOfCustomer = account1.balance;
        uint256 initialProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 intialEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 initialProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        vm.prank(account1);
        vm.expectRevert("Public sale is either closed or hasn't started yet");
        tokenSale.contributeEtherToPublicSale{value: 6 ether}();

        // we expect the txn to reverse and hence no change in balance
        uint256 finalEtherBalanceOfCustomer = account1.balance;
        uint256 finalProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 finalEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 finalProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        assertEq(finalEtherBalanceOfCustomer, initialEtherBalanceOfCustomer);
        assertEq(finalProjectTokenBalanceOfCustomer, initialProjectTokenBalanceOfCustomer);
        assertEq(finalEtherBalanceOfTokenSaleContract, intialEtherBalanceOfTokenSaleContract);
        assertEq(finalProjectTokenBalanceOfTokenSaleContract, initialProjectTokenBalanceOfTokenSaleContract);
    }

    // TestDescription: Owner tries to distribute token to a account1
    // Expected: Project token balance of account1 increases
    function test_distributeTokenByOwner() public {
        // Track intial balances 
        uint256 initialEtherBalanceOfCustomer = account1.balance;
        uint256 initialProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 intialEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 initialProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        vm.expectEmit(true, false, false, true, address(tokenSale));
        emit TokenSale.DistributedToken(account1, 100);
        tokenSale.distributeToken(account1, 100);

        // we expect the txn to reverse and hence no change in balance
        uint256 finalEtherBalanceOfCustomer = account1.balance;
        uint256 finalProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 finalEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 finalProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        assertEq(finalEtherBalanceOfCustomer, initialEtherBalanceOfCustomer);
        assertEq(finalProjectTokenBalanceOfCustomer, initialProjectTokenBalanceOfCustomer + 100);
        assertEq(finalEtherBalanceOfTokenSaleContract, intialEtherBalanceOfTokenSaleContract);
        assertEq(finalProjectTokenBalanceOfTokenSaleContract, initialProjectTokenBalanceOfTokenSaleContract - 100);

    }

    // TestDescription: Non Owner tries to distribute token
    // Expected: The txn is reverted by VM
    function test_distributeTokenByNonOwner() public {
        vm.prank(account1);
        vm.expectRevert();
        tokenSale.distributeToken(account2, 100);
    }

    // TestDescription: Owner tries to distribute token, but distributes more token than present in tokensale contract's reserve
    // Expected: The txn is reverted by VM
    function test_distributeExcessTokenByOwner() public {
        vm.expectRevert("Insufficient supply");
        tokenSale.distributeToken(account4, 1000001 * 10**18);
    }

    // TestDescription: Presale Min cap is not reached, user asks for refund
    // Expected: Expect the transaction to succeed and ether to be refunded back to the user
    function test_claimFullRefundPresaleMinCapNotReached() public {
        // contribute to presale
        vm.prank(account1);
        uint256 valueToSend = 4 ether;
        tokenSale.contributeEtherToPresale{value: valueToSend}();

        // end presale and public sale
        vm.warp(block.timestamp + 41 seconds);

        // Track intial balances 
        uint256 initialEtherBalanceOfCustomer = account1.balance;
        uint256 initialProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 intialEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 initialProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        // claim refund
        vm.prank(account1);
        projectToken.approve(address(tokenSale), valueToSend*conversionValue);
        vm.expectEmit(true, false, false, true, address(tokenSale));
        emit TokenSale.RefundProcessed(account1, valueToSend);
        vm.prank(account1);
        tokenSale.claimFullRefund();

        // Track final balance
        uint256 finalEtherBalanceOfCustomer = account1.balance;
        uint256 finalProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 finalEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 finalProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        // asserts
        assertEq(finalEtherBalanceOfCustomer, initialEtherBalanceOfCustomer + valueToSend);
        assertEq(finalProjectTokenBalanceOfCustomer, initialProjectTokenBalanceOfCustomer - conversionValue * valueToSend );
        assertEq(finalEtherBalanceOfTokenSaleContract, intialEtherBalanceOfTokenSaleContract - valueToSend);
        assertEq(finalProjectTokenBalanceOfTokenSaleContract, initialProjectTokenBalanceOfTokenSaleContract + conversionValue * valueToSend);
    }

    // TestDescription: Public sale Min cap is not reached, user asks for refund
    // Expected: Transaction is executed successfully, ether is refunded and ERC20 token is put back in the reserve
    function test_claimFullRefundPublicSaleMinCapIsNotReached() public {
        // contribute to presale
        vm.prank(account1);
        uint256 valueToSend1 = 5 ether;
        tokenSale.contributeEtherToPresale{value: valueToSend1}();
        
        vm.prank(account2);
        uint256 valueToSend2 = 5 ether;
        tokenSale.contributeEtherToPresale{value: valueToSend2}();

        vm.prank(account3);
        uint256 valueToSend3 = 5 ether;
        tokenSale.contributeEtherToPresale{value: valueToSend3}();

        // fast forward to public sale
        vm.warp(block.timestamp + 21 seconds);

        // contribute to public sale
        vm.prank(account1);
        uint256 valueToSend4 = 7 ether;
        tokenSale.contributeEtherToPublicSale{value: valueToSend4}();

        // end token sale
        vm.warp(block.timestamp + 41 seconds);

        // Track intial balances 
        uint256 initialEtherBalanceOfCustomer = account1.balance;
        uint256 initialProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 intialEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 initialProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        // claim refund
        vm.prank(account1);
        projectToken.approve(address(tokenSale), (valueToSend4 * conversionValue) + (valueToSend1 * conversionValue));
        vm.expectEmit(true, false, false, true, address(tokenSale));
        emit TokenSale.RefundProcessed(account1, valueToSend1 + valueToSend4);
        vm.prank(account1);
        tokenSale.claimFullRefund();

        // Track final balance
        uint256 finalEtherBalanceOfCustomer = account1.balance;
        uint256 finalProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 finalEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 finalProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        // asserts
        assertEq(finalEtherBalanceOfCustomer, initialEtherBalanceOfCustomer + valueToSend1 + valueToSend4);
        assertEq(finalProjectTokenBalanceOfCustomer, initialProjectTokenBalanceOfCustomer - (conversionValue * valueToSend1) - (conversionValue * valueToSend4) );
        assertEq(finalEtherBalanceOfTokenSaleContract, intialEtherBalanceOfTokenSaleContract - valueToSend1 - valueToSend4);
        assertEq(finalProjectTokenBalanceOfTokenSaleContract, initialProjectTokenBalanceOfTokenSaleContract + (conversionValue * valueToSend1) + (conversionValue * valueToSend4));
    }

    // TestDescription: User claimed refund before public sale has ended
    // Expected: VM reverts with error
    function test_claimFullRefundBeforePublicSaleEnded() public {
        vm.prank(account1);
        vm.expectRevert("Public sale or Presale has not ended. Please wait for the completion.");
        tokenSale.claimFullRefund();
    }

    // TestDescription: User claimed refund but public sale and presale min cap was reached
    // Expected: VM reverts with error
    function test_ClaimFullRefundThougBothCapsAreReached() public {
        // contribute to presale
        vm.prank(account1);
        uint256 valueToSend1 = 5 ether;
        tokenSale.contributeEtherToPresale{value: valueToSend1}();
        
        vm.prank(account2);
        uint256 valueToSend2 = 5 ether;
        tokenSale.contributeEtherToPresale{value: valueToSend2}();

        
        // fast forward to public sale
        vm.warp(block.timestamp + 21 seconds);

        // contribute to public sale
        vm.prank(account1);
        uint256 valueToSend3 = 10 ether;
        tokenSale.contributeEtherToPublicSale{value: valueToSend3}();

        vm.prank(account2);
        uint256 valueToSend4 = 10 ether;
        tokenSale.contributeEtherToPublicSale{value: valueToSend4}();

        // end token sale
        vm.warp(block.timestamp + 41 seconds);

        // Track intial balances 
        uint256 initialEtherBalanceOfCustomer = account1.balance;
        uint256 initialProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 intialEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 initialProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        // claim refund
        vm.prank(account1);
        vm.expectRevert("Both Min caps were reached");
        tokenSale.claimFullRefund();

        
        // Track final balance
        uint256 finalEtherBalanceOfCustomer = account1.balance;
        uint256 finalProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 finalEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 finalProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        // asserts
        assertEq(finalEtherBalanceOfCustomer, initialEtherBalanceOfCustomer);
        assertEq(finalProjectTokenBalanceOfCustomer, initialProjectTokenBalanceOfCustomer);
        assertEq(finalEtherBalanceOfTokenSaleContract, intialEtherBalanceOfTokenSaleContract);
        assertEq(finalProjectTokenBalanceOfTokenSaleContract, initialProjectTokenBalanceOfTokenSaleContract);
    }

    // TestDescription: User who didn't contribute to tokensale has demanded a refund
    // Expected: VM reverted with error
    function test_claimFullRefundByANonContributor() public {
        // fast forward and end public sale
        vm.warp(block.timestamp + 41 seconds);
        vm.prank(account1);
        vm.expectRevert("Message sender is not a contributor or has already claimed the refund");
        tokenSale.claimFullRefund();
    }

    // TestDescription: User claimed a refund, but didnot approve token sale smart contract of enough tokens proportional to full refund amount
    // Expected: VM reverts with error
    function test_claimFullRefundButLessAllowanceProvided() public {
        // contribute to presale
        vm.prank(account1);
        uint256 valueToSend1 = 5 ether;
        tokenSale.contributeEtherToPresale{value: valueToSend1}();

        // end token sale
        vm.warp(block.timestamp + 41 seconds);

        // Track intial balances 
        uint256 initialEtherBalanceOfCustomer = account1.balance;
        uint256 initialProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 intialEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 initialProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        // claim full refund but provide less allowance
        vm.prank(account1);
        projectToken.approve(address(tokenSale), 1 ether * conversionValue);
        vm.prank(account1);
        vm.expectRevert("Insuffucient allowance");
        tokenSale.claimFullRefund();

                
        // Track final balance
        uint256 finalEtherBalanceOfCustomer = account1.balance;
        uint256 finalProjectTokenBalanceOfCustomer = projectToken.balanceOf(account1);
        uint256 finalEtherBalanceOfTokenSaleContract = address(tokenSale).balance;
        uint256 finalProjectTokenBalanceOfTokenSaleContract = projectToken.balanceOf(address(tokenSale));

        // asserts
        assertEq(finalEtherBalanceOfCustomer, initialEtherBalanceOfCustomer);
        assertEq(finalProjectTokenBalanceOfCustomer, initialProjectTokenBalanceOfCustomer);
        assertEq(finalEtherBalanceOfTokenSaleContract, intialEtherBalanceOfTokenSaleContract);
        assertEq(finalProjectTokenBalanceOfTokenSaleContract, initialProjectTokenBalanceOfTokenSaleContract);
    }
}