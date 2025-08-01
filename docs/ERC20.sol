pragma solidity ^0.4.25;

contract ERC20 {
 
    // Public variables of the token
    string public name = "TUM Energy Coin";
    string public symbol = "TEC";
    uint8 public decimals = 0;
    address Owner;
    address public ExchangeAddr;
    address public Utility;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply = 100000000000000000000000000000000000000000000000000000000000000000000000000;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) allowance;
    mapping (address => address) AppToSmartmeter;

    /**
    * Constructor 
    *
    * Initializes contract with initial supply tokens to the creator of the contract
    */
    constructor() public {
        Owner = msg.sender;
        balanceOf[msg.sender]=totalSupply;
    }  
    
    modifier onlyOwner() {
        require(msg.sender == Owner,
		"Sender not Authorised.");
        _;
    }
    
    modifier onlyAlarm() {
        require(msg.sender == ExchangeAddr,
		"Sender not Authorised.");
        _;
    }
    

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    // This generates a public event on the blockchain that will notify clients
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
    event Mined(address indexed from, uint256 value);
   
    
    function ChangeTokenSymbName (string tokenName, string tokenSymbol) public onlyOwner() {  
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
    }


    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal returns(bool) {
        // Check if the sender has enough
        if(balanceOf[_from] >= _value){
            // Check for overflows
            uint previousBalances = balanceOf[_from] + balanceOf[_to];
            // Subtract from the sender
            balanceOf[_from] -= _value;
            // Add the same to the recipient
            balanceOf[_to] += _value;
            emit Transfer(_from, _to, _value);
            // Asserts are used to use static analysis to find bugs in your code. They should never fail
            assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
            return true;
        }
        else{
            return false;
        }
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public  returns (bool success) {
       bool  logic=_transfer(msg.sender, _to, _value);
        return logic;
    }

    
    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` on behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
     //bool logic;
    function transferFrom(address _from, address _to, uint256 _value) public  returns (bool success) {
        bool logic;
        if( msg.sender==ExchangeAddr || msg.sender== Owner){
          logic= _transfer(_from, _to, _value);
        return logic;  
        }
        else
        {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        logic=_transfer(_from, _to, _value);
        return logic;
        }
    }

    
    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend, this value will be added to initial approroved value if any
     */
    function approve(address _spender, uint256 _value) public 
        returns (bool success) {
        allowance[msg.sender][_spender] += _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    
    /**
    * update allowance for other address
    *
    * Allows `_spender` to spend no more than `_value` tokens on your behalf
    *
    * @param _spender The address authorized to spend
    * @param _value the max amount they can spend
    */
    function UpdateAllowance(address _spender, uint256 _value) public 
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    
    function AddToken(uint256 _value) public onlyOwner()  returns (bool success) {
        
        balanceOf[msg.sender] += _value;            // Add to owner
        totalSupply += _value;                      // Updates totalSupply
        emit Mined(msg.sender, _value);
        return true;
    }
    
    
    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public  returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }


    /*Destroy tokens from other account
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public  onlyOwner() returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        totalSupply -= _value;                              // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }
    
    
    function Checkbalance(address addr) internal view returns (uint){
        return balanceOf[addr];
    }
    
	
    /*This function is used by the users app to check the balance in the corresponding smart meter address*/
	function CheckMybalance(address addr) public view returns (uint){
        return balanceOf[AppToSmartmeter[addr]];    
    }
}