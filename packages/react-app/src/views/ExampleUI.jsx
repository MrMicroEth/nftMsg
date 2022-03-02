import { SyncOutlined } from "@ant-design/icons";
import { utils } from "ethers";
import { Button, Card, DatePicker, Divider, Input, Progress, Slider, Spin, Switch } from "antd";
import React, { useState } from "react";
import { Address, Balance, Events, AddressInput, MessageInbox, SentMessages } from "../components";


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
  const [newMessage, setNewMessage] = useState("loading...");
  const [newAddress, setNewAddress] = useState();

  return (
    <div>
      {/*
        ⚙️ Here is an example UI that displays and sets the purpose in your smart contract:
      */}
      <div style={{ border: "1px solid #cccccc", padding: 16, width: 400, margin: "auto", marginTop: 64 }}>
        <h2>jpegMessageMe
        </h2>
        <Divider />
        <div style={{ margin: 8 }}>
          Address:
          <AddressInput
            autoFocus
            ensProvider={mainnetProvider}
            placeholder="Enter address"
            value={newAddress}
            onChange={setNewAddress}
          />
          Message:
          <Input
            onChange={e => {
              setNewMessage(e.target.value);
            }}
          />
          <Button
            style={{ marginTop: 8 }}
            onClick={async () => {
              /* look how you call SentMessage on your contract: */
              /* notice how you pass a call back for tx updates too */
              const result = tx(writeContracts.Messenger.mint(newAddress, newMessage), update => {
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
      </div>

      {/*
        📑 Maybe display a list of events?
          (uncomment the event and emit line in Messenger.sol! )
      */}
     {/* <Events
        contracts={readContracts}
        contractName="Messenger"
        eventName="SentMessage"
        localProvider={localProvider}
        mainnetProvider={mainnetProvider}
        startBlock={1}
      />
     */}
      <MessageInbox
        title = "Received"
        contracts={readContracts}
        contractName="Messenger"
        eventName={readContracts.Messenger? readContracts.Messenger.filters.SentMessage(null, address) : null}
        localProvider={localProvider}
        mainnetProvider={mainnetProvider}
        startBlock={1}
        buttonFunction={setNewAddress}
      />
      <SentMessages
        title = "Sent"
        contracts={readContracts}
        contractName="Messenger"
        eventName={readContracts.Messenger? readContracts.Messenger.filters.SentMessage(address) : null}
        localProvider={localProvider}
        mainnetProvider={mainnetProvider}
        startBlock={1}
        buttonFunction={setNewAddress}
      />

    </div>
  );
}
