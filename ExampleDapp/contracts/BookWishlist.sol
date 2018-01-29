pragma solidity ^0.4.4;

/*
 * A contract which allows external parties to contribute funds
 * to a list of books the contract owner creates. Contributors
 * also have the option to rescind their contributions.
 */
contract BookWishlist {
  /*
   * Struct definitions describing Contributions
   * and desired Books.
   * Used mapping as array for lower gas usage
   */
  struct Contribution {
    address from;
    uint256 value;
  }
  struct Book {
    string  name;
    uint256 value;
    uint256 totalContributed;
    uint    numContributors;
    mapping(uint => Contribution) contributions;
    mapping(address => uint) contributors;
  }

  /*
   * Contract state variables
   */
  address private owner;
  mapping(uint => Book) public books;
  uint public numBooks;

  // Allows only contract owner can execute modified functions
  modifier onlyOwner() {
      require(msg.sender == owner);
      _;
  }

  // constructor
  function BookWishlit() public {
    owner = msg.sender;
  }

  /*
   * Contributor functions
   */

  //Given a valid book ID, adds message sender's contribution to book @ id
  function contribute(uint id) public payable {
      require(msg.value > 0 && id < numBooks && id >= 0);
      // if the person has already contributed, add to old contribution
      if (books[id].contributors[msg.sender] != 0) {
          books[id].contributions[books[id].contributors[msg.sender]].value += msg.value;
      } else { // create new contribution for new sender
          uint n = ++books[id].numContributors;
          books[id].contributions[n] = Contribution(msg.sender, msg.value);
          books[id].contributors[msg.sender] = books[id].numContributors+1;
      }
      books[id].totalContributed += msg.value;
  }

  // Given a valid book id, refunds the contribution of the message sender
  function rescind(uint id) public payable returns (bool) {
      require(id < numBooks && id >= 0 && books[id].contributors[msg.sender] != 0);
      uint contributorId = books[id].contributors[msg.sender]-1;
      uint val = books[id].contributions[contributorId].value;
      if (val == 0) {
          return false;
      }
      if (!msg.sender.call.value(val)()){
          return false;
      }
      books[id].totalContributed -= val;
      books[id].contributors[msg.sender] = 0;
      books[id].contributions[contributorId].value = 0;
      return true;
  }

  /*
   * Owner functions
   */

  // Adds a book to book map
  function addBook(string _name, uint256 _val) public onlyOwner returns (uint){
      uint bookID = numBooks++;
      books[bookID] = Book({name: _name, value: _val, totalContributed: 0, numContributors: 0});
      return bookID;
  }

  // Sends all contributions back to contributors
  function refundAll() public onlyOwner {
      for (uint i = 0; i < numBooks; i++) {
          for (uint j = 0; j < books[i].numContributors; j++) {
              if (books[i].contributions[j].value != 0) {
                  require(books[i].contributions[j].
                                from.send(books[i].contributions[j].value));
              }
          }
      }
  }

  // Destroys this contract and forwards all value to owner
  function kill() public onlyOwner {
      selfdestruct(owner);
  }

  /*
   * View/Frontend functions
   */

  // Returns information about book @ id
  function getListItem(uint id) public view returns (string, uint256, uint256) {
      require(id < numBooks && id >= 0);
      return (books[id].name, books[id].value, books[id].totalContributed);
  }

  // Returns the contribution of the sender to book @ id
  function getContribution(uint id) public view returns (uint256) {
      require(id < numBooks && id >= 0);
      if (books[id].contributors[msg.sender] == 0) { return 0; }
      else { return books[id].contributions[books[id].contributors[msg.sender]-1].value; }
  }

  // Fallback function (accepts payment)
  function () public payable {
  }
}
