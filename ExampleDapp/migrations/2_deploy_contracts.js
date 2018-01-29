var BookWishlist = artifacts.require("BookWishlist");
var Crowdfund = artifacts.require("../CrowdFund");

module.exports = function(deployer) {
  deployer.deploy(BookWishlist);
  deployer.deploy(Crowdfund);
};
