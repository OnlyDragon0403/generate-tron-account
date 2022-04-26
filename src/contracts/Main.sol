// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "./ConstantLib.sol";
import { SpaceMatrixLib } from "./SpaceMatrixLib.sol";
import { MemberWalletLib } from "./MemberWalletLib.sol";
import { MemberGroupLib } from "./MemberGroupLib.sol";
import { GlobalPlacementLib } from "./GlobalPlacementLib.sol";

contract Main {
    using SpaceMatrixLib for SpaceMatrixLib.SpaceMatrix;
    using GlobalPlacementLib for SpaceMatrixLib.SpaceMatrix;
    using MemberWalletLib for MemberWalletLib.MemberWallet;
    using Strings for uint256;

    // info of company
    string _companyName;        //name of company
    ConstantLib.MainWallet _main_wallet;

    // info of crowdsale
    uint256[2] _sharing;

    // info of each space
    SpaceMatrixLib.SpaceMatrix[5] _company_space_matrix;       // 5 space matrix for company

    // info of individual member
    mapping( address => MemberWalletLib.MemberWallet ) _member_wallet;       // member's wallet by current address.

    // info of invited member
    mapping( address => address ) _invite_member;       // invited member by current address.
    mapping( address => uint ) _invite_nums;            // invited number of members by current address
    address[] _member_addr;                             // address of all members

    // other value
    uint256 _value;

    constructor ()  {

    }

    // Create a space model
    function createModel () external {
        uint i;
        for ( i = 0 ; i < ConstantLib._mem_cnt; i ++){
            _company_space_matrix[i].createSpaceMatrix( i + 1 );            // create 5 individual space matrix.
            _company_space_matrix[i].setFuncNextSpace( this.enterSpace );
            _company_space_matrix[i].setFuncDisplay( this.setValue );
        }
    }

    function enterSpace(uint space_ID, address addr, uint mem_type) external {         // get memberID of company
        _company_space_matrix[space_ID - 1].enterSpaceMatrix( _member_wallet , _main_wallet , _invite_member, _sharing , addr, mem_type);
    }

    function enterCrowdSale(address addr, address invite_addr) public  {         // new member enters into crowdsale with itself address
        if(_invite_member[addr] == address(0x0)){
            _member_addr.push(addr);
            _invite_member[addr] = invite_addr;
        }
        _invite_nums[invite_addr] ++;
        _company_space_matrix[0].enterSpaceMatrix( _member_wallet , _main_wallet , _invite_member , _sharing , addr, 0);
    }

    // directly tronlink to current upgrade wallet
    function getCurUpgradeSpace(address addr) external view returns ( uint space_ID ){
        space_ID = 1;
        uint i;
        for(i = 0; i < ConstantLib._mem_cnt; i++){
            if( _company_space_matrix[i]._addr_member_group[addr]._member_group.length != 0 ) space_ID = i + 1;
            else    break;
        }

        return space_ID;
    }

    // directly tronlink to current pif wallet
    function pushMoneyToPIF(address addr  , uint256 amount) external {
        _member_wallet[addr]._pif_wallet += amount;
    }

    function pushMoneyToUpgrade ( address addr , uint256 amount) external {
        uint16[6] memory space_price = [1, 100, 500, 2500, 12500, 62500];
        uint space_ID = this.getCurUpgradeSpace(addr);
        // convert dollar to TRX
        if( space_ID == 5) return;

        _member_wallet[addr]._upgrade_wallet[space_ID - 1] += amount;
        while( _member_wallet[addr].CheckUpgradeWallet(space_ID) ){
            _member_wallet[addr]._upgrade_wallet[space_ID - 1] -= space_price[space_ID + 1];       // decrease wallet when upgrade with the money
            this.enterSpace(space_ID , addr , 2);
        }
    }
    // directly

    function getMemberInfo(uint space_ID, address mem_addr , uint nIndex) external view returns ( string memory , string memory , string memory , string memory , string memory ){
        uint256 lv_1 = 0;
        uint256 lv_2 = 0;
        uint256 lv_3 = 0;
        MemberGroupLib.Member memory member = _company_space_matrix[space_ID - 1]._addr_member_group[mem_addr]._member_group[nIndex];

        (lv_1 , lv_2, lv_3) = _company_space_matrix[space_ID - 1].getLevelNumbers(member._member_ID);

        string memory s_lv_1 = Strings.toString( lv_1 );
        string memory s_lv_2 = Strings.toString( lv_2 );
        string memory s_lv_3 = Strings.toString( lv_3 );
        string memory s_pos_ID = Strings.toString( member._member_ID );
        string memory s_type = Strings.toString( uint256( member._member_TYPE ) );

        return ( s_type , s_pos_ID , s_lv_1 , s_lv_2 , s_lv_3 );
    }

    function getMemberCnt( uint space_ID , address mem_addr ) external view returns ( string memory ) {
        MemberGroupLib.Member[] memory member = _company_space_matrix[space_ID - 1]._addr_member_group[mem_addr]._member_group;
        string memory mem_cnt = Strings.toString( member.length );

        return mem_cnt;
    }

    function getMemberWalletInfo( uint space_ID , address mem_addr ) external view returns ( string memory, string memory, string memory ) {
        MemberWalletLib.MemberWallet memory member_wallet = _member_wallet[mem_addr];

        string memory pif_wallet = Strings.toString( member_wallet._pif_wallet);
        string memory upgrade_wallet = Strings.toString( member_wallet._upgrade_wallet[space_ID - 1]);
        string memory re_entry_wallet = Strings.toString( member_wallet._re_entry_wallet[space_ID - 1]);

        return ( pif_wallet , upgrade_wallet , re_entry_wallet);
    }

    function getWalletInfo( ) external view returns ( string memory, string memory, string memory, string memory) {
        string memory unclaimed_money = Strings.toString( _main_wallet._unclaimed_wallet);
        string memory company_wallet_1 = Strings.toString( _main_wallet._company_wallet[0]);
        string memory company_wallet_2 = Strings.toString( _main_wallet._company_wallet[1]);
        string memory company_wallet_3 = Strings.toString( _main_wallet._company_wallet[2]);

        return ( unclaimed_money , company_wallet_1 , company_wallet_2 , company_wallet_3 );
    }

    function getTotalNumBySpace (uint space_ID ) external view returns ( string memory ) {
        string memory total_mem = Strings.toString( _company_space_matrix[space_ID - 1]._total_positions - 1);

        return ( total_mem );
    }

    function setValue ( uint256 value ) external {
        _value = value;
    }

    function output () external view returns ( string memory ) {
        string memory str_value = Strings.toString( _value );
        return str_value;
    }
}

