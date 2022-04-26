// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./ConstantLib.sol";
import { DonationLib } from "./DonationLib.sol";
import { GlobalPlacementLib } from "./GlobalPlacementLib.sol";
import { MemberGroupLib } from "./MemberGroupLib.sol";
import { MemberWalletLib } from "./MemberWalletLib.sol";

library SpaceMatrixLib {
    using DonationLib for SpaceMatrixLib.SpaceMatrix;
    using GlobalPlacementLib for SpaceMatrixLib.SpaceMatrix;
    using SpaceMatrixLib for SpaceMatrixLib.SpaceMatrix;
    using MemberGroupLib for MemberGroupLib.MemberGroup;
    using MemberWalletLib for MemberWalletLib.MemberWallet;

    struct SpaceMatrix{
        mapping ( uint256 => uint256[6] ) list;                // graph for each space
        mapping( address => MemberGroupLib.MemberGroup ) _addr_member_group;        // member group by address in each space
        address[] _ID_member_group;        // member group by identifier in each space
        uint[3] _arrangement;       // company level, arrangement state  60%, 8% , from left to right number
        uint256 _total_positions;         //total number of members in space
        uint _space_ID;       // space name ex. space 1, space 2 ... space 5
        function(uint, address, uint) external fnNextSpace;
        function( uint256 ) external fnDisplay;
    }

    /// @dev returns true if the list exists
    /// @param space_ID identifier of space in a company model
    /// @param self stored space matrix from contract
    function createSpaceMatrix(
        SpaceMatrixLib.SpaceMatrix storage self,
        uint space_ID
    ) internal {
        self._space_ID = space_ID;
        self._arrangement[0] = 0;        // company level
        self._arrangement[1] = 0;        // column number of nth level
        self._arrangement[2] = 0;        // column number of n+1th level
        self._total_positions = 0;
    }

    /// @dev Insert node `_new` beside existing node `_node` in direction `_nIndex`.
    /// @param self stored company matrix from contract
    function pushPosition(SpaceMatrixLib.SpaceMatrix storage self) internal returns (uint256 col_pos) {         // Generate self.list and _arrangement
        self._total_positions ++;         // member ID of company matrix
        uint256 prevNode;
        uint256 nextNode;
        uint256 nodeIndex;
        // level 0
        if(self._arrangement[0] == 0){
            self._arrangement[0] = 1;       // Level 0 fills in members
            return 1;
        }
        // Level 1
        if(self._arrangement[0] == 1){
            self._arrangement[1]++;         // increase number of column in current level.
            self.insert(ConstantLib.HEAD, self._total_positions - 1, self._arrangement[1]);
            col_pos = self._arrangement[1];         // get position of member in column
            if(self._arrangement[1] == 5){      // Level 1 fills in members
                self._arrangement[0] = 2;
                self._arrangement[1] = 0;
            }
            return col_pos;
        }
        // level 2
        if(self._arrangement[0] == 2){
            self._arrangement[1]++;         // increase number of column in current level.
            uint256 adjacent = self.list[ConstantLib.HEAD][(self._arrangement[1] - 1) / ConstantLib._mem_cnt + 1];          // 0th refers to parent node
            self.insert(adjacent, self._total_positions - 1, (self._arrangement[1] - 1) % ConstantLib._mem_cnt + 1);          // 0th refers to parent node
            self.fnDisplay( (self._arrangement[1] - 1) % ConstantLib._mem_cnt + 1 );
            col_pos = self._arrangement[1];      // get position of member in column
            if(self._arrangement[1] == 25){      // Level 2 fills in members
                self._arrangement[0] = 3;
                self._arrangement[1] = 0;
                self._arrangement[2] = 0;
            }

            return col_pos;
        }

        // level 3 and onwards level 4
        (prevNode, nextNode, nodeIndex) = self.getGlobalPlacement();
        self.insert(prevNode, nextNode, nodeIndex);
        col_pos = self.getCurColumnPos();         // get position of member in column
        if(self._arrangement[1] == 5 ** self._arrangement[0]){
            self._arrangement[0] ++;
            self._arrangement[1] = self._arrangement[2];
            self._arrangement[2] = 0;
        }

        return col_pos;
    }

    /// @dev Insert node `_new` beside existing node `_node` in direction `_nIndex`.
    /// @param self stored company matrix from contract
    function enterSpaceMatrix(
        SpaceMatrixLib.SpaceMatrix storage self,
        mapping( address => MemberWalletLib.MemberWallet ) storage wallet,
        ConstantLib.MainWallet storage main_wallet,
        mapping( address => address ) storage invite_member,
        uint256[2] storage sharing,
        address new_addr,
        uint mem_type
    ) internal  {         // Generate self.list and _arrangement
        uint256 col_pos = self.pushPosition();            // get member id of current space and member position in current level
        self._ID_member_group.push(new_addr);
        self._addr_member_group[new_addr].InsertMember(self._total_positions - 1, mem_type);

        // send money of new current member into following member's wallet
        // Invite Donation  20% money to invite_member[addr]
        if( self._total_positions == 1 ){
            uint16[5] memory limitedPrice = [100, 500, 2500, 12500, 62500];
            main_wallet._unclaimed_wallet += limitedPrice[self._space_ID - 1] / 5;
        }
        else
            self.sendTRXToInvitedAccount(new_addr,  invite_member[new_addr]);
        // Matrix donation
        // Level 1      donation
        self.matrixDonationNthLevel(wallet , main_wallet , new_addr , 1 , col_pos );
        // Level 2      donation ,re-enter and P.I.F
        self.matrixDonationNthLevel(wallet , main_wallet , new_addr , 2 , col_pos );
        // Level 3      donation , upgrade , P.I.F and re-enter
        self.matrixDonationNthLevel(wallet , main_wallet , new_addr , 3 , col_pos );
        // Sharing Donation     3% money into individual company wallet
        self.sendTRXToCompanyWallet(main_wallet , new_addr);
        // 2% money into sharing
        sharing[0] += new_addr.balance ;         // not complete
        sharing[1] += new_addr.balance ;         // not complete
    }

    function setFuncNextSpace(SpaceMatrix storage self, function (uint, address, uint) external nextSpace) internal{     // refers to upgrading into next space
        self.fnNextSpace = nextSpace;
    }

    function enterSpecificSpace(SpaceMatrix storage self, uint space_ID,  address addr) internal{     // refers to upgrading into next space
        self.fnNextSpace(space_ID, addr, 1);
    }

    function enterNextSpace(SpaceMatrix storage self,  address addr) internal{     // refers to upgrading into next space
        if(ConstantLib._mem_cnt >= self._space_ID + 1)
            self.fnNextSpace(self._space_ID + 1, addr, 2);
    }

    function setFuncDisplay(SpaceMatrix storage self, function ( uint256 ) external funcDisplay) internal{
        self.fnDisplay = funcDisplay;
    }

}
