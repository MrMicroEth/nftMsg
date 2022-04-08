import React from "react";
import { Link } from "react-router-dom";
import { useContractReader } from "eth-hooks";
import { ethers } from "ethers";

/**
 * web3 props can be passed from '../App.jsx' into your local view component for use
 * @param {*} yourLocalBalance balance on current network
 * @param {*} readContracts contracts from current chain already pre-loaded using ethers contract module. More here https://docs.ethers.io/v5/api/contract/contract/
 * @returns react component
 */
function Home({ yourLocalBalance, readContracts }) {
  // you can also use hooks locally in your component of choice
  // in this case, let's keep track of 'purpose' variable from our contract
// If the receipient already has a pre-existing jpegMe message, it will be updated with your new message and sender address (and will save you gas money!) otherwise your NFT message is minted to their wallet.
  const purpose = useContractReader(readContracts, "YourContract", "purpose");
  const SVG = "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzNTAiIGhlaWdodD0iMzUwIj4gIDxzdHlsZT4gIC50ZXh0IHsgZm9udC1mYW1pbHk6ICJTb3VyY2UgQ29kZSBQcm8iLG1vbm9zcGFjZTsgZm9udC1zaXplOiAxNHB4OyB0ZXh0LXdyYXA6MjAwcHg7IH0gLnNlbmRlciB7Zm9udC1zaXplOiAyMHB4OyBmb250LXdlaWdodDpib2xkfSAubXNnVGV4dHtmaWxsOiB3aGl0ZTsgfSAucmVwbHkge3N0cm9rZS13aWR0aDoxO3N0cm9rZTpyZ2IoMCwxNjgsMjU1KTsgZmlsbDp3aGl0ZX0gLmZpbGwge2ZpbGw6dXJsKCNncmFkMSl9IDwvc3R5bGU+ICA8cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSJ3aGl0ZSIgLz4gICAgPGRlZnM+ICAgICA8bGluZWFyR3JhZGllbnQgaWQ9ImdyYWQxIiB4MT0iMCUiIHkxPSIwJSIgeDI9IjEwMCUiIHkyPSIwJSI+ICAgICAgIDxzdG9wIG9mZnNldD0iMCUiIHN0eWxlPSJzdG9wLWNvbG9yOnJnYig1OCwgMjA4LCA5MSApIiAvPiAgICAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0eWxlPSJzdG9wLWNvbG9yOnJnYigwLDE2OCwyNTUpIiAvPiAgICAgPC9saW5lYXJHcmFkaWVudD4gICA8L2RlZnM+ICA8cmVjdCBjbGFzcz0iZmlsbCIgd2lkdGg9IjMyMCIgaGVpZ2h0PSIyMDAiIHg9IjE1IiB5PSIxNSIgcng9IjEwIiByeT0iMTAiIC8+PHRleHQgeD0iMjciIHk9IjQwIiBjbGFzcz0ibXNnVGV4dCB0ZXh0Ij5TZW5kIGEgbWVzc2FnZSB0byBhbnkgd2FsbGV0IGFzIGFuPC90ZXh0Pjx0ZXh0IHg9IjI3IiB5PSI2MCIgY2xhc3M9Im1zZ1RleHQgdGV4dCI+TkZUIG9uLWNoYWluISA8L3RleHQ+PHRleHQgeD0iMjciIHk9IjgwIiBjbGFzcz0ibXNnVGV4dCB0ZXh0Ij48L3RleHQ+PHRleHQgeD0iMjciIHk9IjEwMCIgY2xhc3M9Im1zZ1RleHQgdGV4dCI+PC90ZXh0Pjx0ZXh0IHg9IjI3IiB5PSIxMjAiIGNsYXNzPSJtc2dUZXh0IHRleHQiPjwvdGV4dD48cG9seWdvbiBwb2ludHM9IjMyMCwyMTUgMzAwLDIxNSAyOTcsMjMwIiBzdHlsZT0iZmlsbDpyZ2IoMCwxNjgsMjU1KSIgLz4gPHRleHQgY2xhc3M9InRleHQgc2VuZGVyIGZpbGwiIHg9IjMyMCIgeT0iMjUwIiAgdGV4dC1hbmNob3I9ImVuZCIgPjB4YTdkLi4uNGQyOTwvdGV4dD4gPGEgaHJlZj0iaHR0cHM6Ly93d3cuanBlZ01lc3NhZ2UubWUiIHRhcmdldD0iX2JsYW5rIj4gPHJlY3QgY2xhc3M9InJlcGx5IiB3aWR0aD0iMzIwIiBoZWlnaHQ9IjMwIiB4PSIxNSIgeT0iMzAwIiByeD0iNSIgcnk9IjUiIC8+IDx0ZXh0IGNsYXNzPSJ0ZXh0IiBmaWxsPSJyZ2IoMCwxNjgsMjU1KSIgeD0iMzAiIHk9IjMyMCIgZm9udC13ZWlnaHQ9ImJvbGQiIGZvbnQtc3R5bGU9Iml0YWxpYyIgPlJlcGx5IG9ubGluZSBAIGpwZWdNZS54eXo8L3RleHQ+IDx0ZXh0IGNsYXNzPSJ0ZXh0IHNlbmRlciIgZmlsbD0icmdiKDAsMTY4LDI1NSkiIHg9IjMyNSIgeT0iMzIxIiB0ZXh0LWFuY2hvcj0iZW5kIiA+PjwvdGV4dD48L2E+PC9zdmc+";

  return (
    <div id="container">
      <div className = "topDiv" >
        <div className = "imageDiv" >
          <Link to="/app">
            <img id="preview" src={SVG}  alt="NFT Message" />
          </Link>
        </div>
        <div class="info" >
          <Link to="/app">
          <h2 class = "title" >Send NFT Messages</h2>
          </Link>
          Need to send a message to a wallet owner? Send them a message as a NFT Image! Messages are stored 100% on-chain. 
        </div>
        <div class="info" >
          <Link to="/app">
          <h2 class = "title" >Browse Your Messages</h2>
          </Link>
          View messages that you have sent and recieved. Easily reply to messages from other users.
        </div>
        <div class="info" >
          <Link to="/app">
          <h2 class = "title" >Mint a Genesis Theme</h2>
          </Link>
          The first 1000 wallets to RECEIVE a message will get a limited edition Genesis theme and lower fees.
          <Link to="/app"><h2 class = "link">Try it Now ></h2></Link> 
        </div>
      </div>
    </div>
  );
}

export default Home;
