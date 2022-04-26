// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

library ConstantLib {
    // struct, enum or constant variable declaration
    enum Package { SPACE_1, SPACE_2, SPACE_3, SPACE_4, SPACE_5 }        // refers to 5 space according to price.
    uint constant _mem_cnt = 5;         // refers to 5 child nodes from parent nodes.

    // constant of space matrix
    uint256 constant NULL = 0;
    uint256 constant HEAD = 0;
    uint constant PARENT = 0;

    /* company wallet address information */
    address constant _unclaimed_Wallet = 0x158de12EE547EAe06Cbdb200A017aCa6B75D230D;
    address constant _company_Wallet_1 = 0x158de12EE547EAe06Cbdb200A017aCa6B75D230D;
    address constant _company_Wallet_2 = 0x158de12EE547EAe06Cbdb200A017aCa6B75D230D;
    address constant _company_Wallet_3 = 0x158de12EE547EAe06Cbdb200A017aCa6B75D230D;

    // rate between TRX and dollar
    uint256 constant _rate = 1;     //14
    struct MainWallet {
        uint256 _unclaimed_wallet;
        uint256[3] _company_wallet;
    }
    // function definition with body
}
