let addr_list = require('./address_list.json')

var Crowdsale = artifacts.require("./Main.sol");
let crowdsale;

contract('Crowdsale', function([alice]) {
  before(async function() {
    crowdsale = await Crowdsale.deployed()
    this.timeout(40000);
  });


  context("Test Crowdsale function", () => {
    it("call createModel", async function() {
        let nIndex = 0;
        let i,j;
        // get virtual address of new member
        addr_list = JSON.parse( JSON.stringify( addr_list ) );
        const key_addr_list = Object.keys(addr_list);

        // create a crowdsale model
        await crowdsale.createModel();
        // Level 0
        console.log("Level 0");
        await crowdsale.enterCrowdSale( key_addr_list[nIndex], addr_list[key_addr_list[nIndex]]);           // founder enters into company matrix at first.
        let total_count = await crowdsale.getTotalNumBySpace(1);
        console.log('member ID in space 0:' , total_count);
        let wallet_info = await crowdsale.getWalletInfo();
        console.log('wallet :', wallet_info);
        // level1
        console.log("Level 1");
        for(i = 0; i < 5; i++){
            nIndex ++;
            await crowdsale.enterCrowdSale(key_addr_list[nIndex], addr_list[key_addr_list[nIndex]]);
            let total_count = await crowdsale.getTotalNumBySpace(1);
            console.log('member ID in space 0:' , total_count);
            let wallet_info = await crowdsale.getWalletInfo();
            console.log('wallet :', wallet_info);
            let result = await crowdsale.getMemberWalletInfo(1, key_addr_list[0]);
            console.log("Member wallet :", result);
        }

        //level2
        console.log("Level 2");
        for(i = 0; i < 24; i++){
            nIndex ++;
            await crowdsale.enterCrowdSale(key_addr_list[nIndex], addr_list[key_addr_list[nIndex]]);
            let total_count = await crowdsale.getTotalNumBySpace(1);
            console.log('member ID in space 0:' , total_count);
            let wallet_info = await crowdsale.getWalletInfo();
            console.log('wallet :', wallet_info);
            let result = await crowdsale.getMemberWalletInfo(1, key_addr_list[0]);
            console.log("Member wallet :", result);
        }

        let result = await crowdsale.getMemberWalletInfo(1, key_addr_list[0]);
        console.log("Member wallet :", result);

        console.log( await crowdsale.output() );
        // level3
        // console.log("Level 3");
        // for(i = 0; i < 5; i++){    //125
        //     nIndex ++;
        //     await crowdsale.enterCrowdSale(key_addr_list[nIndex], addr_list[key_addr_list[nIndex]]);
        //     let total_count = await crowdsale.getTotalNumBySpace(1);
        //     console.log('member ID in space 0:' , total_count);
        //     let wallet_info = await crowdsale.getWalletInfo();
        //     console.log('wallet :', wallet_info);
        //     let result = await crowdsale.getMemberWalletInfo(1, key_addr_list[0]);
        //     console.log("Member wallet :", result);
        // }
        // assert.equal(1, result, "is not call method f");
    });
  });
});



