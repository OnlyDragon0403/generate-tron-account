import React, { useState, useEffect } from 'react';
import { Grid, Header, Step } from 'semantic-ui-react'
import MemberTable from './MemberTable';
import LevelTable from './LevelTable';
import { useSelector, useDispatch } from "react-redux";
import { filterSelector, fetchMembersData } from "../slices/filter";

const Content = () => {

  const spaceArray = ['Space 1', 'Space 2', 'Space 3', 'Space 4', 'Space 5'];
  const { curSpace, selectedMember } = useSelector(filterSelector);
 
  const dispatch = useDispatch();
  
  const [selectedSpace, setSelectedSpace] = useState(0);

  const setTab = (space) => {
    setSelectedSpace(space);
    dispatch(fetchMembersData(space));
  }

  useEffect(() => {
    dispatch(fetchMembersData(0));
  }, [dispatch]);

  return (
    <>    
      {/* Heads up! Override division color to make it visible on dark background. */}
      <style>
      {`
        .ui.grid.divided:not([class*="vertically divided"]) > .row > .column {
            box-shadow: -1px 0 0 0 #d4d4d4;
        }
        .ui[class*="vertically divided"].grid > .row:before {
            box-shadow: 0 -1px 0 0 rgba(212, 212, 212, 1.0);
        }
      `}
      </style>
      <Header as='h2' inverted textAlign='center' color='grey'>
        MEMBER Matrix View
      </Header>
      <Grid columns={2} divided>
        <Grid.Row >
            <Grid.Column width={10}>
              <Step.Group ordered >
                {spaceArray.map((item, index) => {
                  if(index < curSpace)
                    return (
                      <Step completed link key={index} onClick={() => setTab(index)}>
                        <Step.Content>
                          <Step.Title>{item}</Step.Title>
                        </Step.Content>
                      </Step>
                    )
                  else if (index == curSpace)
                    return (
                      <Step active link key={index} onClick={() => setTab(index)}>
                        <Step.Content>
                          <Step.Title>{item}</Step.Title>
                        </Step.Content>
                      </Step>
                    )
                  else
                    return (
                      <Step link key={index} onClick={() => setTab(index)}>
                        <Step.Content>
                          <Step.Title>{item}</Step.Title>
                        </Step.Content>
                      </Step>
                    )
                })}
              </Step.Group>
              <MemberTable />
            </Grid.Column>
            <Grid.Column width={6}>
              <Header as='h2' style={{padding : "0.75em"}}>
                SPACE {curSpace + 1} PAYMENT  : ID {selectedMember + 1}
              </Header>
              <LevelTable />
            </Grid.Column>
        </Grid.Row>
      </Grid>
    </>
  );
}

export default Content;