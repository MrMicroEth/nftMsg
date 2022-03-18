import { List, Button, space } from "antd";
import { useEventListener } from "eth-hooks/events/useEventListener";
import { Address } from ".";
import React, { useEffect, useState } from "react";

/*
  ~ What it does? ~

  Displays a lists of events

  ~ How can I use? ~

  <Events
    contracts={readContracts}
    contractName="YourContract"
    eventName="SetPurpose"
    localProvider={localProvider}
    mainnetProvider={mainnetProvider}
    startBlock={1}
  />
*/

let oldEvents;

export default function MessageInbox({ title, contracts, contractName, eventName, localProvider, mainnetProvider, startBlock, buttonFunction}) {
  // 📟 Listen for broadcast events
  let events = useEventListener(contracts, contractName, eventName, localProvider, startBlock).slice().reverse();

  const [show, setShow] = useState(true);

  
  useEffect(() => {
    const updateTimes = async () => {
      try {
    console.log("EVENTS UPDATED, add dates, or make second array");
    console.log(events[0].blockNumber);
    const msgTime = (await localProvider.getBlock(events[0].blockNumber)).timestamp;
    console.log(new Date(msgTime));
      } catch (e) {
        console.log(e);
      }
    //console.log(newSVG);
    };
    updateTimes(); //uncomment this to use this function
  }, [events]);

  return (
    <div className="messageList" >
      <h2>{title}</h2>
      <List
        pagination={{
          onChange: page => {
            console.log(page);
          },
          pageSize: 5,
        }}
        itemLayout="vertical"
        dataSource={events}
        renderItem={item => {
          return (
            <List.Item 
              key={item.blockNumber + "_" + item.args.sender + "_" + item.args.purpose}
              actions={[
                <Address address={item.args[0]} ensProvider={mainnetProvider} fontSize={16} />,
                <Button
                onClick={async () => {
                  buttonFunction(item.args[0])
                }}
                >
                Reply
                </Button>,
              ]}
            >
              <div className="content">
                {item.args[2]}
                {item.blockNumber}
              </div>
            </List.Item>
          );
        }}
      />
    </div>
  );
}