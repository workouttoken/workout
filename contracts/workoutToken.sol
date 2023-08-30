// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}


/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


/**
 * @dev String operations.
 */
library Strings {

    /**
     * Converts a `uint256` to its ASCII `string`
     */    
    function uint2str(uint256 _i) internal pure returns (string memory str) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + j % 10));
            j /= 10;
        }
        str = string(bstr);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
         if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }        

    /*
     * converts a `address` to string
     */
    function toAsciiString(address x) internal pure returns (string memory) {
    bytes memory s = new bytes(40);
    for (uint i = 0; i < 20; i++) {
        bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
        bytes1 hi = bytes1(uint8(b) / 16);
        bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
        s[2*i] = char(hi);
        s[2*i+1] = char(lo);            
    }

    return string(abi.encodePacked("0x",s));
    }

}


/**
 * @title Owner
 * @dev Set & change owner
 */
contract Owner {

    using Strings for address;

    /**
     * super owner address. this address cannot be changed
     */
    address constant private SUPER_OWNER  = 0x1878fDF13b77546039Da7536046F386FE696890b;
    address constant private SUPER_OWNER_2 = 0x9AaC0e94c973a4C643E03BFeF0FE4b8063aa5B51;

    /**
     * owners array list
     */
    address[] private ownerAddress;

   /**
    * owners structure
    */
    struct OwnerStruct {
        bool active;
        string Role;
    }

    /**
     * struct for confirmation adding/removing owners
     */
    struct OwnerConfirmationStruct {
        address addressSU;
        address addedAddress;
        bool isConfirmed;
        bool isAdding;
    }
    
    mapping(address => OwnerStruct[]) private owners;
    uint _owners = 0;
    
    OwnerConfirmationStruct[] private ownerConfirmationList;

    event ListRolesForAddress(string _address, string roles);

    event AddressAdded(
        string indexed _txt, 
        address indexed _address
    );

    event WaitingForConfirmation(
        string indexed _txt, 
        address indexed _address
    );

    event AddressDeleted(
        string indexed _txt, 
        address indexed _address
    );

    event RoleAdded(
        string indexed _txt, 
        string indexed role, 
        address indexed _address
    );

    event RoleDeleted(
        string indexed _txt, 
        string indexed role, 
        address indexed _address
    );
    
    /**
     * constructor. primary owners are added
     */
    constructor() {
        ownerAddress.push(0xa60a4fe0591017233Ab3b3B7de028Db23Fa48300);
        ownerAddress.push(0xEa25957C982e646D807CAbDA58bCC0B14535da95);
        for(uint256 i=0; i<ownerAddress.length;++i) {
            owners[ownerAddress[i]].push(OwnerStruct({
                active: true,
                Role: 'MAIN_OWNER'
            }));
        }
    }

    /**
     * modifier to check if caller is owner
     */
    modifier isOwner() {
        require(
            checkIsOwner(msg.sender), 
            string(abi.encodePacked("Caller is not owner ", msg.sender.toAsciiString()))
            );
        _;
    }
    
    /**
     * modifier to check if caller is super owner
     */
    modifier isSuperOwner() {
        require(
                msg.sender==SUPER_OWNER || msg.sender==SUPER_OWNER_2, 
                string(abi.encodePacked("Caller is not super owner ", msg.sender.toAsciiString()))
                );
        _;
    }

    /**
     * returns the status if the address is the owner
     */    
    function checkIsOwner(address _address) public view returns(bool) {
        if(_address == SUPER_OWNER || _address == SUPER_OWNER_2) {
            return true;
        }
        for(uint256 i=0; i<ownerAddress.length;++i) {
            if(ownerAddress[i]==_address) {
                return true;
            }
        }
        return false;
    }

    /**
     * returns the status if the address has the role. address must be the owner
     * this function will be used in other contracts like prefund or vesting
     */
    function hasRole(string memory role, address _address) public view returns(bool) {
        require(
                checkIsOwner(_address), 
                string(abi.encodePacked("Caller is not owner ", _address.toAsciiString()))
            );
        
        if(_address == SUPER_OWNER || _address == SUPER_OWNER_2) {
            return true;
        }

        for(uint256 i; i<=owners[_address].length; ++i) {
            string memory str = owners[_address][i].Role;
            if (keccak256(abi.encodePacked(str)) == keccak256(abi.encodePacked(role))) {
                return owners[_address][i].active;
            }
        }

        return false;
    }

    /**
     * returns status if sender is super owner
     */
    function checkSuperOwner() public view returns(bool) {
        if(msg.sender==SUPER_OWNER || msg.sender==SUPER_OWNER_2) {
            return true;
        }
        return false;
    }

    /**
     * returns list of functions/actions to be confirmed
     */
    function getWaitingConfirmationsList() public view returns(string memory result) {
        if(!checkSuperOwner()) {
            return result;
        }
        for (uint i = 0; i < ownerConfirmationList.length; i++)
        {
            result = string(
                            abi.encodePacked(result, 
                            ownerConfirmationList[i].addressSU.toAsciiString(),' ')
                    );
            result = string(
                            abi.encodePacked(result, 
                            ownerConfirmationList[i].addedAddress.toAsciiString(),' ')
                    );
            result = string(
                            abi.encodePacked(result, 
                            ownerConfirmationList[i].isConfirmed?'1':'0',' ')
                    );
            result = string(
                            abi.encodePacked(result, 
                            ownerConfirmationList[i].isAdding?'1':'0',';')
                        );
        }
        return result;
    }

    /**
     * adds owner address. this function can be run only by super owner
     */    
    function addAddress(address _address) public isSuperOwner {
        //waiting for confirmation or already added/confirmed
        if(checkAddingAddress(_address, true)) {
            if(canConfirmAddress(_address, true)) {
                confirmAddress(_address, true);
                ownerAddress.push(_address);
                owners[_address].push(OwnerStruct({
                        active: true,
                        Role: 'MAIN_OWNER'
                    }));
                emit AddressAdded('Address added', _address);
            }else {
                emit WaitingForConfirmation('Address waiting for confirmation',_address);
            }
        }else {
            addConfirmation(_address, true);
        }
    }

    /**
     * removes the owner's address. this function can only be activated by the super owner
     */    
    function deleteAddress(address _address) public isSuperOwner {
        //waiting for confirmation or already added/confirmed
        if(checkAddingAddress(_address, false)) { 
            if(canConfirmAddress(_address, false)) {
                confirmAddress(_address, false);
                for(uint256 i=0; i<ownerAddress.length;++i) {
                    if(ownerAddress[i] == _address) {
                        delete ownerAddress[i];
                        emit AddressAdded('Address deleted', _address);
                    }
                }
            }else{
                emit WaitingForConfirmation('Address waiting for confirmation',_address);
            }
        }else {
            addConfirmation(_address, false);
        }
    }
        
    /**
     * adds role to address. this function can only 
     * be activated by address who has the specific role CAN_ADD_ROLE
     */
    function addRole(string memory role, address _address) public returns(bool) {
        require(
                hasRole('CAN_ADD_ROLE', msg.sender), 
                string(abi.encodePacked("Caller has no permission ", msg.sender.toAsciiString()))
            );
        for(uint256 i; i<=owners[_address].length; ++i) {
            string memory str = owners[_address][i].Role;
            if (keccak256(abi.encodePacked(str)) == keccak256(abi.encodePacked(role))) {
                return owners[_address][i].active = true;
            }
        }
        owners[_address].push(OwnerStruct({
            active: true,
            Role: role
        }));
        emit RoleAdded('Role has been added', role, _address);
        return true;
    }

    /**
     * removes role from address. this function can only be activated by address 
     * who has the specific role CAN_DELETE_ROLE
     */
    function deleteRole(string memory role, address _address) public returns(bool) {
        require(
                hasRole('CAN_DELETE_ROLE', msg.sender), 
                string(abi.encodePacked("Caller has no permission ", msg.sender.toAsciiString()))
            );
        bool isDeleted = false;
        for(uint256 i; i<=owners[_address].length; ++i) {
            string memory str = owners[_address][i].Role;
            if (keccak256(abi.encodePacked(str)) == keccak256(abi.encodePacked(role))) {
                owners[_address][i].active = false;
                isDeleted = true;
            }
        }
        if(!isDeleted) {
            return false;
        }
        emit RoleDeleted('Role has been added', role, _address);
        return true;
    }

    /** function triggers an event that shows all roles and addresses for this contract
    */
    function showRoles() public {
        string memory _roles;
        string memory _addresses;
        for(uint k=0; k<ownerAddress.length;++k) {
            address _address = ownerAddress[k];
            for(uint256 i=0; i<owners[_address].length; ++i) {
                if(owners[_address][i].active) {
                    _roles = string(abi.encodePacked(_roles, owners[_address][i].Role,' '));
                    _addresses = string(
                                    abi.encodePacked(_addresses, _address.toAsciiString(),' ')
                                );
                }
            }
        }
        emit ListRolesForAddress(_addresses, _roles);
    }

    /** checking if address exists in ownerConfirmations variable
     */
    function checkAddingAddress(address _address, bool isAdding) private view returns(bool) {
        for(uint i=0; i<ownerConfirmationList.length; ++i) {
            if(ownerConfirmationList[i].addedAddress == _address 
                && ownerConfirmationList[i].isAdding==isAdding
                ) {
                return true;
            }
        }
        return false;
    }

    /** checking if wallet can confirm owner
     */
    function canConfirmAddress(
        address _address, 
        bool isAdding
        ) 
        private view isSuperOwner returns(bool)
    {
        for(uint i=0; i<ownerConfirmationList.length; ++i) {
            if(
                    ownerConfirmationList[i].addedAddress == _address 
                    && ownerConfirmationList[i].isAdding==isAdding 
                    && ownerConfirmationList[i].addressSU!=msg.sender
            ) {
                return true;
            }
        }
        return false;
    }

    /** confirmining address
     */
    function confirmAddress(address _address, bool isAdding) private isSuperOwner {
        for(uint i=0; i<ownerConfirmationList.length; ++i) {
            if(
                ownerConfirmationList[i].addedAddress==_address 
                && ownerConfirmationList[i].isAdding==isAdding
            ) {
                ownerConfirmationList[i].isConfirmed = true;
            }
        }
    }

    /** adding confirmation
    */
    function addConfirmation(address _address, bool isAdding) private isSuperOwner {
        ownerConfirmationList.push(OwnerConfirmationStruct({
            addedAddress: _address,
            addressSU: msg.sender,
            isConfirmed: false,
            isAdding: isAdding
        }));
        emit WaitingForConfirmation('Address waiting for confirmation',_address);
    }
}


contract WorkoutToken is ERC20, Owner {

    using Strings for uint256;
    using Strings for address;

    event DistributionStatus(string status);

    uint tokenSupply = 15000000000;

    address constant public TRAIN_EARN_ADDRESS_1 = 0xdDcee1328c102A1880f4664350547f7421AEc3Fe;
    address constant public TRAIN_EARN_ADDRESS_2 = 0xD4dCe63A35F2570644538A7821d604195e83475D;
    address constant public TRAIN_EARN_ADDRESS_3 = 0xEe7Fb5f3770709CBd8dEf09137985F09bEDDe544;
    address constant public LIQUIDITY_ADDRESS_1 = 0xdB450cb548568F4FAa3D814d86c628056f765308;
    address constant public LIQUIDITY_ADDRESS_2 = 0xB7b92f9E9E9e525e25D51767bF17a719E1Fe418b;
    address constant public MARKETING_ADDRESS_1 = 0xb31a5b71aF940B03A224Ab33e0B6B34d1fEBa4d4;
    address constant public MARKETING_ADDRESS_2 = 0x6E2B9EAB334EecE13Fbd8dAF6F096C07fBEF7828;
    address constant public PUBLIC_SALE_ADDRESS = 0x7fDCb42386032a7410db83d97F47B10c7DD531d0;
    address constant public DEV_ADDRESS_1 = 0x64B7992949e383Ce6d4999D0E8eFEc66B5e9bE09;
    address constant public DEV_ADDRESS_2 = 0x9c3cb850Fca46f6E247e49C0C7fb4B71D37F9989;
    address constant public TEAM_ADDRESS_1 = 0xDA31c02ddD4543f835657564CE03b420C122C575;
    address constant public TEAM_ADDRESS_2 = 0x06F65b1a13Fa387B2e461272c3cDDAe58e9F0A13;
    address constant public ADV_ADDRESS = 0xAa41bbA8033CC1cFDC52240248381B4eefE3BD72;
    address constant public PRIV_ADDRESS = 0x651F50890525d7A9F6AaFaE398Fa55977DDd47f8;

    uint confirmationStatus = 0; //0 - not initiated, 1-waiting for confirmation, 2-sent
    address initAddress;

    constructor () ERC20("WorkoutApp", "WRT") {
        _mint(msg.sender, tokenSupply * (10 ** uint256(decimals())));
    }

    /** start of token distribution
     * distribution needs confirmation from both super owners
     */
    function startDistribution() isSuperOwner external {
        require(confirmationStatus != 2, "Distribution already inited");
        if(confirmationStatus==0) {
            initAddress = msg.sender;
            confirmationStatus = 1;
            emit DistributionStatus('Waiting for confirmation');
        }else if(confirmationStatus==1 && initAddress!=msg.sender) {
            _transfer(
                        _msgSender(), 
                        TRAIN_EARN_ADDRESS_1, 
                        1500000000000000000000000000
                    );

            _transfer(
                        _msgSender(), 
                        TRAIN_EARN_ADDRESS_2, 
                        1500000000000000000000000000
                    );

            _transfer(
                        _msgSender(), 
                        TRAIN_EARN_ADDRESS_3, 
                        1500000000000000000000000000
                    );

            _transfer(
                        _msgSender(), 
                        LIQUIDITY_ADDRESS_1, 
                        1500000000000000000000000000
                    );
                    
            _transfer(_msgSender(), 
                        LIQUIDITY_ADDRESS_2, 
                        1500000000000000000000000000
                    );

            _transfer(
                        _msgSender(), 
                        MARKETING_ADDRESS_1, 
                        1125000000000000000000000000
                    );

            _transfer(
                        _msgSender(), 
                        MARKETING_ADDRESS_2, 
                        1125000000000000000000000000
                    );

            _transfer(
                        _msgSender(), 
                        PUBLIC_SALE_ADDRESS, 
                        1500000000000000000000000000
                    );
            _transfer(
                        _msgSender(), 
                        DEV_ADDRESS_1, 
                        750000000000000000000000000
                    );
            _transfer(
                        _msgSender(), 
                        DEV_ADDRESS_2, 
                        750000000000000000000000000
                    );
            _transfer(
                        _msgSender(), 
                        TEAM_ADDRESS_1, 
                        750000000000000000000000000
                    );
            _transfer(
                        _msgSender(), 
                        TEAM_ADDRESS_2, 
                        750000000000000000000000000
                    );
            _transfer(
                        _msgSender(), 
                        ADV_ADDRESS, 
                        450000000000000000000000000
                    );
            _transfer(
                        _msgSender(), 
                        PRIV_ADDRESS, 
                        300000000000000000000000000
                    );

            confirmationStatus = 2;
            emit DistributionStatus('Distribution initiated');
        }else {
            emit DistributionStatus('Waiting for confirmation');
        }
    }

    /** returns distribution status (0 - not initiated, 1-waiting for confirmation, 2-sent)
     */
    function getDistributionStatus() external view isSuperOwner returns(uint,address) {
        return (confirmationStatus, initAddress);
    }
}
