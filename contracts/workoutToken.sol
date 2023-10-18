// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

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

    using Strings for uint256;

    // super owner address. this address cannot be changed
    address private superOwner  = 0x1878fDF13b77546039Da7536046F386FE696890b;
    address private superOwner2 = 0x9AaC0e94c973a4C643E03BFeF0FE4b8063aa5B51;

    // owners array list
    address[] private ownerAddress;

    event ListRolesForAddress(string _address, string roles);

   // owners and roles

    struct OwnerStruct {
        bool active;
        string Role;
        uint256 RoleId;
    }
    
    mapping(address => OwnerStruct[]) private owners;
    uint _owners = 0;

    // struct for confirmation adding/removing owners
    struct OwnerConfirmationStruct {
        address addressSU;
        address addedAddress;
        bool isConfirmed;
        bool isAdding;
    }
    
    OwnerConfirmationStruct[] private ownerConfirmationList;

    using Strings for address;

    event AddressAdded(string _txt, address _address);
    event WaitingForConfirmation(string _txt, address _address);
    event AddressDeleted(string _txt, address _address);
    event RoleAdded(string _txt, string role, address _address);
    event RoleDeleted(string _txt, uint256 role, address _address);
    
    constructor() {
        ownerAddress.push(0xa60a4fe0591017233Ab3b3B7de028Db23Fa48300);
        ownerAddress.push(0xEa25957C982e646D807CAbDA58bCC0B14535da95);
        for(uint256 i=0; i<ownerAddress.length;++i) {
            owners[ownerAddress[i]].push(OwnerStruct({
                active: true,
                Role: 'MAIN_OWNER',
                RoleId: 1
            }));
        }
    }


    // modifier to check if caller is owner
    modifier isOwner() {
        require(hasOwner(msg.sender), string(abi.encodePacked("Caller is not owner ", msg.sender.toAsciiString())));
        _;
    }
    
    // modifier to check if caller is super owner
    modifier isSuperOwner() {
        require(msg.sender==superOwner || msg.sender==superOwner2, string(abi.encodePacked("Caller is not super owner ", msg.sender.toAsciiString())));
        _;
    }

    function checkSuperOwner() public view returns(bool) {
        if(msg.sender==superOwner || msg.sender==superOwner2) {
            return true;
        }
        return false;
    }

    //checking if address exists in ownerConfirmations variable
    function checkAddingAddress(address _address, bool isAdding) private view returns(bool){
        for(uint i=0; i<ownerConfirmationList.length; ++i) {
            if(ownerConfirmationList[i].addedAddress == _address && ownerConfirmationList[i].isAdding==isAdding) {
                return true;
            }
        }
        return false;
    }

    //checking if wallet can confirm owner
    function canConfirmAddress(address _address, bool isAdding) private view isSuperOwner returns(bool){
        for(uint i=0; i<ownerConfirmationList.length; ++i) {
            if(ownerConfirmationList[i].addedAddress == _address && ownerConfirmationList[i].isAdding==isAdding && ownerConfirmationList[i].addressSU!=msg.sender) {
                return true;
            }
        }
        return false;
    }

    //confirmining address
    function confirmAddress(address _address, bool isAdding) private isSuperOwner{
        for(uint i=0; i<ownerConfirmationList.length; ++i) {
            if(ownerConfirmationList[i].addedAddress==_address && ownerConfirmationList[i].isAdding==isAdding) {
                ownerConfirmationList[i].isConfirmed = true;
            }
        }
    }

    //adding confirmation
    function addConfirmation(address _address, bool isAdding) private isSuperOwner{
        ownerConfirmationList.push(OwnerConfirmationStruct({
            addedAddress: _address,
            addressSU: msg.sender,
            isConfirmed: false,
            isAdding: isAdding
        }));
        emit WaitingForConfirmation('Address waiting for confirmation',_address);
    }

    function getWaitingConfirmationsList() public view returns(string memory result) {
        if(!checkSuperOwner()) {
            return result;
        }
        for (uint i = 0; i < ownerConfirmationList.length; i++)
        {
            result = string(abi.encodePacked(result, ownerConfirmationList[i].addressSU.toAsciiString(),' '));
            result = string(abi.encodePacked(result, ownerConfirmationList[i].addedAddress.toAsciiString(),' '));
            result = string(abi.encodePacked(result, ownerConfirmationList[i].isConfirmed?'1':'0',' '));
            result = string(abi.encodePacked(result, ownerConfirmationList[i].isAdding?'1':'0',';'));
        }
        return result;
    }

    // adds owner address. this function can be run only by super owner    
    function addAddress(address _address) public isSuperOwner {
        if(checkAddingAddress(_address, true)) { //waiting for confirmation or already added/confirmed
            if(canConfirmAddress(_address, true)) {
                confirmAddress(_address, true);
                ownerAddress.push(_address);
                owners[_address].push(OwnerStruct({
                        active: true,
                        Role: 'MAIN_OWNER',
                        RoleId: 1
                    }));
                emit AddressAdded('Address added', _address);
            }else {
                emit WaitingForConfirmation('Address waiting for confirmation',_address);
            }
        }else {
            addConfirmation(_address, true);
        }
    }

    // removes the owner's address. this function can only be activated by the superowner    
    function deleteAddress(address _address) public isSuperOwner {
        if(checkAddingAddress(_address, false)) { //waiting for confirmation or already added/confirmed
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

    // returns the status if the address is the owner    
    function hasOwner(address _address) public view returns(bool) {
        if(_address == superOwner || _address == superOwner2) {
            return true;
        }
        for(uint256 i=0; i<ownerAddress.length;++i) {
            if(ownerAddress[i]==_address) {
                return true;
            }
        }
        return false;
    }

    // returns the status if the address has the role. address must be the owner
    // this function will be used in other contracts lite prefund or vesting
    function hasRole(uint256 roleId, address _address) public isOwner view returns(bool) {
        
        if(_address == superOwner || _address == superOwner2) {
            return true;
        }

        for(uint256 i; i<owners[_address].length; ++i) {
            if (owners[_address][i].RoleId == roleId) {
                return owners[_address][i].active;
            }
        }

        return false;
    }
        
    // adds role to address. this function can only be activated by address who has the specific role CAN_ADD_ROLE
    function addRole(uint256 roleId, address _address, string memory role) public returns(bool){
        require(hasRole(2, msg.sender), string(abi.encodePacked("Caller has no permission ", msg.sender.toAsciiString())));
        for(uint256 i; i<owners[_address].length; ++i) {
            if (owners[_address][i].RoleId == roleId) {
                return owners[_address][i].active = true;
            }
        }
        owners[_address].push(OwnerStruct({
            active: true,
            Role: role,
            RoleId: roleId
        }));
        emit RoleAdded('Role has been added', role, _address);
        return true;
    }

    // removes role from address. this function can only be activated by address who has the specific role CAN_DELETE_ROLE
    function deleteRole(uint256 roleId, address _address) public returns(bool) {
        require(
                hasRole(3, msg.sender), 
                string(abi.encodePacked("Caller has no permission ", msg.sender.toAsciiString()))
            );
        bool isDeleted = false;
        for(uint256 i; i<owners[_address].length; ++i) {
            if (owners[_address][i].RoleId == roleId) {
                owners[_address][i].active = false;
                isDeleted = true;
            }
        }
        if(!isDeleted) {
            return false;
        }
        emit RoleDeleted('Role has been deleted', roleId, _address);
        return true;
    }

    // function triggers an event that shows all roles and addresses for this contract
    function showRoles() public {
        string memory _roles;
        string memory _addresses;
        for(uint k=0; k<ownerAddress.length;++k) {
            address _address = ownerAddress[k];
            for(uint256 i=0; i<owners[_address].length; ++i) {
                if(owners[_address][i].active) {
                    _roles = string(abi.encodePacked(_roles, owners[_address][i].RoleId.uint2str(),': '));
                    _roles = string(abi.encodePacked(_roles, owners[_address][i].Role,' '));
                    _addresses = string(
                                    abi.encodePacked(_addresses, _address.toAsciiString(),' ')
                                );
                }
            }
        }
        emit ListRolesForAddress(_addresses, _roles);
    }
}

contract WorkoutToken is ERC20, Owner {

    using Strings for uint256;
    using Strings for address;

    event DistributionStatus(string status);

    uint tokenSupply = 15000000000;

    address public trainEarn1Address          = 0xdDcee1328c102A1880f4664350547f7421AEc3Fe;
    address public trainEarn2Address          = 0xD4dCe63A35F2570644538A7821d604195e83475D;
    address public trainEarn3Address          = 0xEe7Fb5f3770709CBd8dEf09137985F09bEDDe544;
    address public liq1Address                = 0xdB450cb548568F4FAa3D814d86c628056f765308;
    address public liq2Address                = 0xB7b92f9E9E9e525e25D51767bF17a719E1Fe418b;
    address public marketing1Address          = 0xb31a5b71aF940B03A224Ab33e0B6B34d1fEBa4d4;
    address public marketing2Address          = 0x6E2B9EAB334EecE13Fbd8dAF6F096C07fBEF7828;
    address public publicSaleAddress          = 0x7fDCb42386032a7410db83d97F47B10c7DD531d0;
    address public dev1Address                = 0x64B7992949e383Ce6d4999D0E8eFEc66B5e9bE09;
    address public dev2Address                = 0x9c3cb850Fca46f6E247e49C0C7fb4B71D37F9989;
    address public team1Address               = 0xDA31c02ddD4543f835657564CE03b420C122C575;
    address public team2Address               = 0x06F65b1a13Fa387B2e461272c3cDDAe58e9F0A13;
    address public advAddress                 = 0xAa41bbA8033CC1cFDC52240248381B4eefE3BD72;
    address public privAddress                = 0x651F50890525d7A9F6AaFaE398Fa55977DDd47f8;

    uint confirmationStatus = 0; //0 - not initiated, 1-waiting for confirmation, 2-sended
    address initAddress;

    function startDistribution() isSuperOwner public {
        require(confirmationStatus != 2, "Distribution already inited");
        if(confirmationStatus==0) {
            initAddress = msg.sender;
            confirmationStatus = 1;
            emit DistributionStatus('Waiting for confirmation');
        }else if(confirmationStatus==1 && initAddress!=msg.sender) {
            _transfer(_msgSender(), trainEarn1Address, 1500000000000000000000000000);
            _transfer(_msgSender(), trainEarn2Address, 1500000000000000000000000000);
            _transfer(_msgSender(), trainEarn3Address, 1500000000000000000000000000);
            _transfer(_msgSender(), liq1Address, 1500000000000000000000000000);
            _transfer(_msgSender(), liq2Address, 1500000000000000000000000000);
            _transfer(_msgSender(), marketing1Address, 1125000000000000000000000000);
            _transfer(_msgSender(), marketing2Address, 1125000000000000000000000000);
            _transfer(_msgSender(), publicSaleAddress, 1500000000000000000000000000);
            _transfer(_msgSender(), dev1Address, 750000000000000000000000000);
            _transfer(_msgSender(), dev2Address, 750000000000000000000000000);
            _transfer(_msgSender(), team1Address, 750000000000000000000000000);
            _transfer(_msgSender(), team2Address, 750000000000000000000000000);
            _transfer(_msgSender(), advAddress, 450000000000000000000000000);
            _transfer(_msgSender(), privAddress, 300000000000000000000000000);

            confirmationStatus = 2;
            emit DistributionStatus('Distribution initiated');
        }else {
            emit DistributionStatus('Waiting for confirmation');
        }
    }

    function getDistributionStatus() public view isSuperOwner returns(uint,address) {
        return (confirmationStatus, initAddress);
    }

    constructor () ERC20("WorkoutApp", "WRT") {
        _mint(msg.sender, tokenSupply * (10 ** uint256(decimals())));
    }

}
