/*
    This exercise has been updated to use Solidity version 0.5
    Breaking changes from 0.4 to 0.5 can be found here: 
    https://solidity.readthedocs.io/en/v0.5.0/050-breaking-changes.html
*/

pragma solidity ^0.5.0;

contract SupplyChain {

    /* set owner */
    address public owner;

    /* Add a variable called skuCount to track the most recent sku # */
    uint private skuCount;

    /* Add a line that creates a public mapping that maps the SKU (a number) to an Item.
        Call this mappings items
    */
    mapping (uint => Item) public items;

    /* Add a line that creates an enum called State. This should have 4 states
      ForSale
      Sold
      Shipped
      Received
      (declaring them in this order is important for testing)
    */
    enum State { ForSale, Sold, Shipped, Received }

    /* Create a struct named Item.
      Here, add a name, sku, price, state, seller, and buyer
      We've left you to figure out what the appropriate types are,
      if you need help you can ask around :)
    */
    struct Item { // Struct
        string name;
        uint sku;
        uint price;
        uint state;
        address payable seller;
        address payable buyer;
    }
    /* Create 4 events with the same name as each possible State (see above)
      Each event should accept one argument, the sku*/
    event ForSale(uint sku);
    event Sold(uint sku);
    event Shipped(uint sku);
    event Received(uint sku);

    /* Create a modifer that checks if the msg.sender is the owner of the contract */
    modifier isOwner() {
        require (msg.sender == owner, "We apologize, you are not allowed to execute this function");
        _;
    }    

    modifier verifyCaller (address _address) {require (msg.sender == _address, "Ah! looks like you are an imposter"); _;}

    modifier paidEnough(uint _price) {require(msg.value >= _price, "Ah! the item would have been yours, had you been paid enough amount"); _;}
    modifier checkValue(uint _sku) {
        //refund them after pay for item (why it is before, _ checks for logic before func)
        _;
        uint _price = items[_sku].price;
        uint amountToRefund = msg.value - _price;
        msg.sender.transfer(amountToRefund);
    }

    /* For each of the following modifiers, use what you learned about modifiers
    to give them functionality. For example, the forSale modifier should require
    that the item with the given sku has the state ForSale. */
    modifier forSale(uint sku) {
        require (items[sku].state == uint(State.ForSale), "We apologize, the item is not for sale anymore.");
        _;      
    }
    modifier sold(uint sku) {
        require (items[sku].state == uint(State.Sold), "We apologize, the item has been sold.");
        _;      
    }
    modifier shipped(uint sku) {
        require (items[sku].state == uint(State.Shipped), "We apologize, the item has already been shipped by the seller.");
        _;      
    }
    modifier received(uint sku) {
        require (items[sku].state == uint(State.Received), "We apologize, the item has already been received by the buyer.");
        _;      
    }

    constructor() public {
      /* Here, set the owner as the person who instantiated the contract
        and set your skuCount to 0. */
        owner = msg.sender;
        skuCount = 0;
    }

    function addItem(string memory _name, uint _price) public returns(bool){
        emit ForSale(skuCount);
        items[skuCount] = Item({name: _name, sku: skuCount, price: _price, state: uint(State.ForSale), seller: msg.sender, buyer: address(0)});
        skuCount = skuCount + 1;
        return true;
    }

    /* Add a keyword so the function can be paid. This function should transfer money
      to the seller, set the buyer as the person who called this transaction, and set the state
      to Sold. Be careful, this function should use 3 modifiers to check if the item is for sale,
      if the buyer paid enough, and check the value after the function is called to make sure the buyer is
      refunded any excess ether sent. Remember to call the event associated with this function!*/

    function buyItem(uint sku)
      public
      payable
      forSale(sku)
      paidEnough(items[sku].price)
      checkValue(sku)
    {
        //check if the item is for sale (calling modifier: forSale)         
        //check if the buyer paid enough (calling modified: paidEnough)
        //require(msg.sender.balance < items[sku].price, "You don't have sufficient funds in your account");

        //transfer money to the seller
        items[sku].seller.transfer(items[sku].price);

        //set the buyer as the person who called this transaction
        items[sku].buyer = msg.sender;

        //set the state to Sold
        items[sku].state = uint(State.Sold);

        //check the value after the function is called to make sure the buyer is refunded any excess ether sent

        //call the event associated with this function
        emit Sold(sku);
    }

    /* Add 2 modifiers to check if the item is sold already, and that the person calling this function
    is the seller. Change the state of the item to shipped. Remember to call the event associated with this function!*/
    function shipItem(uint sku)
      public
      verifyCaller(items[sku].seller)
      sold(sku)      
    {
        //check the person calling this function is the seller
        //check if the item is sold already

        items[sku].state = uint(State.Shipped);
        emit Shipped(sku);
    }

    /* Add 2 modifiers to check if the item is shipped already, and that the person calling this function
    is the buyer. Change the state of the item to received. Remember to call the event associated with this function!*/
    function receiveItem(uint sku)
      public
      verifyCaller(items[sku].buyer)
      shipped(sku)
    {
        items[sku].state = uint(State.Received);
        emit Received(sku);
    }

    /* We have these functions completed so we can run tests, just ignore it :) */
    function fetchItem(uint _sku) public view returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) {
        name = items[_sku].name;
        sku = items[_sku].sku;
        price = items[_sku].price;
        state = uint(items[_sku].state);
        seller = items[_sku].seller;
        buyer = items[_sku].buyer;
        return (name, sku, price, state, seller, buyer);
    }

}
