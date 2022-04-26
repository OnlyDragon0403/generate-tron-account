export const TESTNET = 'shasta';
export const MAINNET = 'mainnet';
export const TRONLINK_INITIALISATION_WAIT_TIME = 500;
export const TRONWEB_INITIALISED = 'TRONWEB_INITIALISED';
export const TRONWEB_NOT_FOUND = 'TRONWEB_NOT_FOUND';

import jsonCompanyModel from './abi/CompanyModel.json';

export default {
    inventoryScAddress: {
        [TESTNET]: jsonCompanyModel.networks[2].address,
        [MAINNET]: "TT7awWuV3ohc7PnMdQPkvQY3PgDUCkLo9P"
    }      
};

