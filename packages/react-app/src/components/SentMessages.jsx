import { List, Button, space } from "antd";
import { useEventListener } from "eth-hooks/events/useEventListener";
import { Address } from ".";

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

export default function SentMessages({ title, contracts, contractName, eventName, localProvider, mainnetProvider, startBlock, buttonFunction }) {
  // 📟 Listen for broadcast events
  const events = useEventListener(contracts, contractName, eventName, localProvider, startBlock).slice().reverse();

  return (
    <div className="messageList" >
      <h2>{title}</h2>
      <List
        pagination={{
          onChange: page => {
            console.log(page); },
          pageSize: 5,
        }}
        itemLayout="vertical"
        dataSource={events}
        renderItem={item => {
          return (
            <List.Item 
              key={item.blockNumber + "_" + item.args.sender + "_" + item.args.purpose}
              actions={[
                <Address address={item.args[1]} ensProvider={mainnetProvider} fontSize={16} />,
              ]}
            >
              <div className="content sent">
                {item.args[2]}
              </div>
            </List.Item>
          );
        }}
      />
    </div>
  );
}