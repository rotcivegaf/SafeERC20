pragma solidity ^0.5.0;

import "zos-lib/contracts/Initializable.sol";
import "openzeppelin-eth/contracts/math/SafeMath.sol";


contract ERC20WithoutRevert is Initializable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    event Transfer(
      address indexed from,
      address indexed to,
      uint256 value
    );

    event Approval(
      address indexed owner,
      address indexed spender,
      uint256 value
    );

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
    * @dev Function to check the amount of tokens that an owner _allowed to a spender.
    * @param owner address The address which owns the funds.
    * @param spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
    */
    function allowance(
        address owner,
        address spender
    )
      public
      view
      returns (uint256)
    {
        return _allowed[owner][spender];
    }

    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * Beware that changing an allowance with this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param spender The address which will spend the funds.
    * @param value The amount of tokens to be spent.
    */
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
    * @dev Increase the amount of tokens that an owner _allowed to a spender.
    * approve should be called when allowed_[_spender] == 0. To increment
    * _allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param spender The address which will spend the funds.
    * @param addedValue The amount of tokens to increase the allowance by.
    */
    function increaseAllowance(
        address spender,
        uint256 addedValue
    )
      public
      returns (bool)
    {
        require(spender != address(0));

        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
    * @dev Decrease the amount of tokens that an owner _allowed to a spender.
    * approve should be called when allowed_[_spender] == 0. To decrement
    * _allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param spender The address which will spend the funds.
    * @param subtractedValue The amount of tokens to decrease the allowance by.
    */
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    )
        public
        returns (bool)
    {
        require(spender != address(0));

        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (_balances[msg.sender] >= _value) {
            _balances[msg.sender] = _balances[msg.sender].sub(_value);
            _balances[_to] = _balances[_to].add(_value);
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool success)
    {
        if (_balances[_from] >= _value && _allowed[_from][msg.sender] >= _value) {
            _balances[_to] = _balances[_to].add(_value);
            _balances[_from] = _balances[_from].sub(_value);
            _allowed[_from][msg.sender] = _allowed[_from][msg.sender].sub(_value);
            emit Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    /**
    * @dev Internal function that mints an amount of the token and assigns it to
    * an account. This encapsulates the modification of _balances such that the
    * proper events are emitted.
    * @param account The account that will receive the created tokens.
    * @param amount The amount that will be created.
    */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0));
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
    * @dev Internal function that burns an amount of the token of a given
    * account.
    * @param account The account whose tokens will be burnt.
    * @param amount The amount that will be burnt.
    */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0));
        require(amount <= _balances[account]);

        _totalSupply = _totalSupply.sub(amount);
        _balances[account] = _balances[account].sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
    * @dev Internal function that burns an amount of the token of a given
    * account, deducting from the sender's allowance for said account. Uses the
    * internal burn function.
    * @param account The account whose tokens will be burnt.
    * @param amount The amount that will be burnt.
    */
    function _burnFrom(address account, uint256 amount) internal {
        require(amount <= _allowed[account][msg.sender]);

        // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
        // this function needs to emit an event with the updated approval.
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(amount);
        _burn(account, amount);
    }

    function setBalance(address _holder, uint256 _amount) public {
        _mint(_holder, _amount);
    }

    uint256[50] private ______gap;
}
