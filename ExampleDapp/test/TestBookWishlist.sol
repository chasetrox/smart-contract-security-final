pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/BookWishlist.sol";

contract TestBookWishlist {
  struct Contribution {
    uint256 value;
    string message;
  }
  struct Book {
    string name;
    uint256 value;
    uint256 contributed;
    mapping (address => bool) contributors;
    mapping (address => Contribution) contributions;
  }

  BookWishlist wishlist = BookWishlist(DeployedAddresses.BookWishlist());
  uint nextIndex;

  function TestBookWishlist() public {
    nextIndex = 0;
  }

  function testAddBook() public {
    uint returnedIndex = wishlist.addBook("Harry Potter", 12);
    //Assert.equal(12, 12, "Book not added or index wrong");
  }
}
