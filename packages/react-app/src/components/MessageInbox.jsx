import { List, Button } from "antd";
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

export default function MessageInbox({ contracts, contractName, eventName, localProvider, mainnetProvider, startBlock, buttonFunction }) {
  // 📟 Listen for broadcast events
  const events = useEventListener(contracts, contractName, eventName, localProvider, startBlock).slice().reverse();

  const [dateTime, setDateTime] = useState();
  const [eventCount, setEventCount] = useState(0);

  useEffect(() => {
    const updateTimes = async () => {
      const updateArray = async myArray => {
        const promises = events.map(async i => {
          const newTime = (await i.getBlock()).timestamp;
          const dateTime = new Date(newTime *1000);
          return dateTime.toLocaleString();
        });
        return Promise.all(promises);
      };
      console.log(await updateArray());
      const result = await updateArray();
      setDateTime(JSON.stringify(result));//When I save the array directly, it creates an infinite loop for some strange reason
    };
    try{
      if (events.length && eventCount < events.length){ //this check prevents endless provider calls 
        updateTimes();
        setEventCount(events.length); 
      }
    } catch (e) {
      console.log(e);
    }
  }, [events, eventCount]);

  return (
    <div className="messageList" >
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
                <Address address={item.args.sender} ensProvider={mainnetProvider} fontSize={16} />,
                <div>
                  {dateTime? JSON.parse(dateTime)[index] : ""}
                </div>,
                <Button
                  onClick={async () => {
                    buttonFunction(item.args.sender);
                  }}
                >
                  Reply
                </Button>,
              ]}
            >
              <div className="content">
                {item.args.value}
              </div>
            </List.Item>
          );
        }}
      />
    </div>
  );
}