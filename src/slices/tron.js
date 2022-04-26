import { createSlice } from '@reduxjs/toolkit'
const TronWeb = require('tronweb')
import Config, { TESTNET, MAINNET } from '../config';
const { inventoryScAddress } = Config;

const initialState = {
  loading : false,
  hasErrors : false,
  contractAddress : null,
  currentNet : ''
}

const tronSlice = createSlice({
  name: 'tron',
  initialState,
  reducers: {
    getdata: (state) => {
      state.loading = true;
    },
    setTronWeb: (state, { payload }) => {
      state.contractAddress = payload;
      state.loading = false;
      state.hasErrors = false;
    },
    getdataFailure: (state) => {
      console.log(state);
      state.loading = false;
    },
  }
})

export const { getdata, setTronWeb, getdataFailure } = tronSlice.actions

export default tronSlice.reducer

export function doInitialiseTronWeb () {
  return async (dispatch) => {
    dispatch(getdata());
      try {
          const tronweb = window.tronWeb;
          
          if (!tronweb) {
            console.log("should reset tronweb");
            const HttpProvider = TronWeb.providers.HttpProvider;
            const fullNode = new HttpProvider('https://api.shasta.trongrid.io');
            const solidityNode = new HttpProvider('https://api.shasta.trongrid.io');
            const eventServer = 'https://api.shasta.trongrid.io/';
            
            tronweb = new TronWeb(
                fullNode,
                solidityNode,
                eventServer,
            );
            window.tronWeb = tronweb;
          }
          let currentNet = TESTNET;
        
          const contractAddress = inventoryScAddress[currentNet];
          dispatch(setTronWeb( contractAddress ));
    } catch (error) {
      dispatch(getdataFailure());
    }
  };
}



// const transaction = await tronweb.transactionBuilder.createSmartContract({
//   abi:jsonCompanyModel.abi,
//   bytecode: jsonCompanyModel.bytecode,
//   // parameters:[]
// },jsonCompanyModel.networks[2].address);    //tronweb.defaultAddress.hex  ,