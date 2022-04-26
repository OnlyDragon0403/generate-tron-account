import React from 'react';
import { Table } from 'semantic-ui-react'
import { useSelector } from "react-redux";
import { levelSelector } from "../slices/filter";

const LevelTable = () => {

  const price = [5,20,50];
  const levels = useSelector(levelSelector);
  // initialize tronweb
  
  return (
    <>    
      <Table sortable celled fixed textAlign='center'>
            <Table.Header>
                <Table.Row>
                    <Table.HeaderCell>Level</Table.HeaderCell>
                    <Table.HeaderCell>Wallet</Table.HeaderCell>
                    <Table.HeaderCell>Donation</Table.HeaderCell>
                    <Table.HeaderCell>Received</Table.HeaderCell>
                </Table.Row>
            </Table.Header>
            <Table.Body>
                {levels.map(( item , index) => (
                <Table.Row key={index}>
                    <Table.Cell>{index+1}</Table.Cell>
                    <Table.Cell>{item}</Table.Cell>
                    <Table.Cell>{price[index]}</Table.Cell>
                    <Table.Cell>{item * price[index]}</Table.Cell>
                </Table.Row>
                ))}
                { 
                    levels.length ?
                    (<Table.Row >
                        <Table.Cell colSpan='3'>Total Matrix Donation</Table.Cell>
                        <Table.Cell>550</Table.Cell>
                    </Table.Row>) :
                    (<></>)
                }
            </Table.Body>
        </Table>
    </>
  );
}

export default LevelTable;