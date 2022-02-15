import { SyncOutlined } from "@ant-design/icons";
import { utils } from "ethers";
import { Button, Card, DatePicker, Divider, Input, Progress, Slider, Spin, Switch } from "antd";
import React, { useState } from "react";
import { Address, Balance, Events, MessageEvents } from "../components";


export default function ExampleUI({
  purpose,
  address,
  mainnetProvider,
  localProvider,
  yourLocalBalance,
  price,
  tx,
  readContracts,
  writeContracts,
}) {
  const [newPurpose, setNewPurpose] = useState("loading...");
  const [newAddress, setNewAddress] = useState();

  return (
    <div>
      {/*
        ⚙️ Here is an example UI that displays and sets the purpose in your smart contract:
      */}
      <div style={{ border: "1px solid #cccccc", padding: 16, width: 400, margin: "auto", marginTop: 64 }}>
        <h2>EthMessenger</h2>
        <Divider />
        <div style={{ margin: 8 }}>
          Address:
          <Input
            onChange={e => {
              setNewAddress(e.target.value);
            }}
          />
          Message:
          <Input
            onChange={e => {
              setNewPurpose(e.target.value);
            }}
          />
          <Button
            style={{ marginTop: 8 }}
            onClick={async () => {
              /* look how you call setPurpose on your contract: */
              /* notice how you pass a call back for tx updates too */
              const result = tx(writeContracts.YourContract.mint(newAddress, newPurpose), update => {
                console.log("📡 Transaction Update:", update);
                if (update && (update.status === "confirmed" || update.status === 1)) {
                  console.log(" 🍾 Transaction " + update.hash + " finished!");
                  console.log(
                    " ⛽️ " +
                      update.gasUsed +
                      "/" +
                      (update.gasLimit || update.gas) +
                      " @ " +
                      parseFloat(update.gasPrice) / 1000000000 +
                      " gwei",
                  );
                }
              });
              console.log("awaiting metamask/web3 confirm result...", result);
              console.log(await result);
            }}
          >
            Send Message!
          </Button>
        </div>
        <h4>Sent Message: {newPurpose} to {newAddress}</h4>
      </div>

      {/*
        📑 Maybe display a list of events?
          (uncomment the event and emit line in YourContract.sol! )
      */}
     {/* <Events
        contracts={readContracts}
        contractName="YourContract"
        eventName="SetPurpose"
        localProvider={localProvider}
        mainnetProvider={mainnetProvider}
        startBlock={1}
      />
     */}
      <MessageEvents
        title = "Messages"
        contracts={readContracts}
        contractName="YourContract"
        eventName={readContracts.YourContract.filters.SetPurpose(null, address)}
        localProvider={localProvider}
        mainnetProvider={mainnetProvider}
        startBlock={1}
        arg={0}
      />
      <MessageEvents
        title = "Sent"
        contracts={readContracts}
        contractName="YourContract"
        eventName={readContracts.YourContract.filters.SetPurpose(address)}
        localProvider={localProvider}
        mainnetProvider={mainnetProvider}
        startBlock={1}
        arg={1}
      />

    </div>
  );
}
