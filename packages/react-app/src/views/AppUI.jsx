import { Button, Switch } from "antd";
import React, { useEffect, useState } from "react";
import { AddressInput, MessageInbox, SentMessages } from "../components";
import TextArea from "antd/lib/input/TextArea";
import ReactTooltip from "react-tooltip";

export default function AppUI({
  address,
  mainnetProvider,
  localProvider,
  tx,
  readContracts,
  writeContracts,
}) {
  const [newMessage, setNewMessage] = useState("Message Preview");
  const [newAddress, setNewAddress] = useState();
  const [SVG, setSVG] = useState("");
  const [show, setShow] = useState(true);
  const [mintWithNFT, setMintWtihNFT] = useState(true);
  const usePreview = false; //set this to true to update and show the SVG graphic live from the contract

  //this hook creates a live image preview of what the NFT message will look like. Could be used for production or debugging
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
    if(usePreview) updateSVG(); //uncomment this to use this function
  }, [address, usePreview, newAddress, newMessage, readContracts]);

  return (
    <div id="container">
      {/*
        ⚙️ Here is an example UI that displays and sets the purpose in your smart contract:
      */}
      <div className ="topDiv" >
        <div id="inputDiv">
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
              maxLength={175}
              className="msgInput"
              placeholder="Message"
              onChange={e => {
                setNewMessage(e.target.value);
              }}
            />
          </div>
          <ReactTooltip place="left" multiline />
          <span className="mintWithNFT" data-tip="Send with NFT enabled is more visible, but also more exspensive.<br> Send with NFT disabled will emit an Eth event, visible on this site and Etherscan">
            NFT
            <Switch checked={mintWithNFT} onChange= {isChecked => {
              setMintWtihNFT(isChecked);
              console.log(isChecked);
            }}
          />
          </span>
          <Button
            onClick={async () => {
              /* look how you call SentMessage on your contract: */
              /* notice how you pass a call back for tx updates too */
              const mintSwitch = mintWithNFT? writeContracts.Messenger.mint : writeContracts.Messenger.mintEvent;
              const result = tx(mintSwitch(newAddress, newMessage), update => {
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
            Send
          </Button>
        </div>
        <div className="imageDiv" style={{ display: usePreview && show ? "block" : "none" }}>
          <img id="preview" src={SVG}  alt="NFT Message" />
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
      <h2 className= "title">Received</h2>
      <MessageInbox
        contracts={readContracts}
        contractName="Messenger"
        eventName={readContracts.Messenger? readContracts.Messenger.filters.SentMessage(null, address) : null}
        localProvider={localProvider}
        mainnetProvider={mainnetProvider}
        startBlock={1}
        buttonFunction={setNewAddress}
      />
      <h2 className= "title">Sent</h2>
      <SentMessages
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
