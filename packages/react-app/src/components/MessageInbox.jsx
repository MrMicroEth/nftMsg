import { List, Button, space } from "antd";
import { useEventListener } from "eth-hooks/events/useEventListener";
import { Address } from ".";
import React, { useEffect, useState } from "react";
import { exit } from "process";
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


export default function MessageInbox({ title, contracts, contractName, eventName, localProvider, mainnetProvider, startBlock, buttonFunction}) {
  // 📟 Listen for broadcast events
  let events = useEventListener(contracts, contractName, eventName, localProvider, startBlock).slice().reverse();

  const [dateTime, setDateTime] = useState();

  useEffect(() => {
    const updateTimes = async () => {
      const someFunction = async (myArray) => {
         const promises = events.map(async (i) => {
            const newTime = (await i.getBlock()).timestamp;
            const dateTime = new Date(newTime *1000);
            return dateTime.toLocaleString();
        });
        return Promise.all(promises);
      };
      console.log(await someFunction());
      const result = await someFunction();
      setDateTime(JSON.stringify(result));//When I save the array directly, it creates an infinite loop for some strange reason
    };
    try{
      updateTimes();
    } catch (e) {
      console.log(e);
    }
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
        renderItem={(item, index) => {
          return (
            <List.Item 
              key={item.blockNumber + "_" + item.args.sender + "_" + item.args.purpose}
              actions={[
                <Address address={item.args[0]} ensProvider={mainnetProvider} fontSize={16} />,
                <div>
                  {JSON.parse(dateTime)[index]}
                </div>,
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
              </div>
            </List.Item>
          );
        }}
      />
    </div>
  );
}