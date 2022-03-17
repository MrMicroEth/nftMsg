import { SyncOutlined } from "@ant-design/icons";
import { utils } from "ethers";
import { Button, Card, DatePicker, Divider, Input, Progress, Slider, Spin, Switch } from "antd";
import React, { useEffect, useState } from "react";
import { Address, Balance, Events, AddressInput, MessageInbox, SentMessages } from "../components";
import TextArea from "antd/lib/input/TextArea";


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
  const [newMessage, setNewMessage] = useState("Message Preview");
  const [newAddress, setNewAddress] = useState();
  const [SVG, setSVG] = useState("");
  const [show, setShow] = useState(true);

  
  useEffect(() => {
    const updateSVG = async () => {
    let newSVG = "";
      try {
        newSVG = await readContracts.MessengerImage.buildImage(0, newMessage, address);
        setShow(true);
      } catch (e) {
        console.log(e);
        setSVG("");
        setShow(false);
      }
    setSVG("data:image/svg+xml;base64," + newSVG);
    //console.log(newSVG);
    //setShow(false);
    };
    //updateSVG(); //uncomment this to use this function
  }, [newAddress, newMessage, readContracts]);


  return (
    <div id="container">
      {/*
        ⚙️ Here is an example UI that displays and sets the purpose in your smart contract:
      */}
      <div className = "topDiv" >
        <div id = "inputDiv">
          <div id="inputBox">
          <AddressInput
            autoFocus
            ensProvider={mainnetProvider}
            placeholder="To:"
            value={newAddress}
            onChange={setNewAddress}
          />
          <TextArea
            rows={2}
            maxLength = {175}
            className = "msgInput"
            placeholder="Message"
            onChange={e => {
              setNewMessage(e.target.value);
            }}
          />
          </div>
          <Button
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
            <h2>Send</h2>
          </Button>
        </div>
        {/* This shows a preview of the image manifested from the contract
        <div className = "imageDiv" >
          <img id="preview" src={SVG} style={{ display: show ? "block" : "none" }} alt="NFT Message" />
        </div>
          */}
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
        localProvider={localProvider}
        eventName={readContracts.Messenger? readContracts.Messenger.filters.SentMessage(address) : null}
        mainnetProvider={mainnetProvider}
        startBlock={1}
        buttonFunction={setNewAddress}
      />

    </div>
  );
}
