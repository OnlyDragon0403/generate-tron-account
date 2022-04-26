import { createSlice } from "@reduxjs/toolkit";
import _ from 'lodash';

const memberData = [
  [
    { type: 'UPGRADE', levels : [5, 25, 0]},
    { type: 'RE-ENTRY', levels : [5, 25, 10]},
    { type: 'UPGRADE', levels : [5, 25, 100]},
    { type: 'RE-ENTRY', levels : [5, 25, 125]}
  ],
]

export const initialState = {
  loading: false,
  hasErrors: false,
  reverse_users: {
    curSpace : 0,
    selectedMember : null,
    column: null,
    data: [],
    direction: 'ascending',
  }
};

// https://redux-toolkit.js.org/api/createslice
const filterSlice = createSlice({
  name: "data",
  initialState,
  reducers: {
    getdata: (state) => {
      state.loading = true;
    },
    getMemberSuccess: (state, { payload }) => {
      state.reverse_users.data = payload;
      state.loading = false;
      state.hasErrors = false;
    },
    selectMemberSuccess: (state, { payload }) => {
      state.reverse_users.selectedMember = payload;
    },
    getdataFailure: (state) => {
      state.loading = false;
    },
    sortdata: (state, { payload }) => {
      let reserver_users = state.reverse_users;
      if (reserver_users.column === payload) {
        reserver_users.data =  reserver_users.data.slice().reverse(),
        reserver_users.direction = reserver_users.direction === 'ascending' ? 'descending' : 'ascending';
      }
      else{
        reserver_users.column = payload;
        reserver_users.data = _.sortBy(reserver_users.data, [payload]);
        reserver_users.direction = 'ascending';
      }
      state.reverse_users = reserver_users;

      state.loading = false;
      state.hasErrors = false;
    },
  },
});

// Actions generated from the slice:
export const { getdata, getMemberSuccess, getdataFailure, selectMemberSuccess, sortdata } =
  filterSlice.actions;

// Selector:
export const filterSelector = (state) => state.filters.reverse_users;
export const levelSelector = (state) => state.filters.reverse_users.selectedMember !== null ? state.filters.reverse_users.data[state.filters.reverse_users.selectedMember].levels : [];


// Reducer:
export default filterSlice.reducer;

// Async thunk action:
export function fetchMembersData(space) {
  return async (dispatch) => {
    dispatch(getdata());
    try {
      // get member IDs
      dispatch(getMemberSuccess(memberData[space]));
      curSpace = space;
    } catch (error) {
      dispatch(getdataFailure());
    }
  };
}

export function selectMemberData(member) {
  return async (dispatch) => {
    dispatch(selectMemberSuccess(member));
  };
}

export function sortData(column) {
  return async (dispatch) => {
    dispatch(getdata());
    try {
      // sort member matrix
      dispatch(sortdata(column));
    } catch (error) {
      dispatch(getdataFailure());
    }
  };
}
