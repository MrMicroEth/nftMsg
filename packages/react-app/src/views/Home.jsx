import React from "react";
import { Button } from "antd";
import { Link } from "react-router-dom";
//import { useContractReader } from "eth-hooks";

/**
 * web3 props can be passed from '../App.jsx' into your local view component for use
 * @param {*} yourLocalBalance balance on current network
 * @param {*} readContracts contracts from current chain already pre-loaded using ethers contract module. More here https://docs.ethers.io/v5/api/contract/contract/
 * @returns react component
 */
function Home() {
  // you can also use hooks locally in your component of choice
  // in this case, let's keep track of 'purpose' variable from our contract
  // If the receipient already has a pre-existing jpegMe message, it will be updated with your new message and sender address (and will save you gas money!) otherwise your NFT message is minted to their wallet.
  const SVG = "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzNTAiIGhlaWdodD0iMzUwIj4gIDxzdHlsZT4gIC50ZXh0IHsgZm9udC1mYW1pbHk6ICJTb3VyY2UgQ29kZSBQcm8iLG1vbm9zcGFjZTsgZm9udC1zaXplOiAxNHB4OyB0ZXh0LXdyYXA6MjAwcHg7IH0gLnNlbmRlciB7Zm9udC1zaXplOiAyMHB4OyBmb250LXdlaWdodDpib2xkfSAubXNnVGV4dHtmaWxsOiB3aGl0ZTsgfSAucmVwbHkge3N0cm9rZS13aWR0aDoxO3N0cm9rZTpyZ2IoMCwxNjgsMjU1KTsgZmlsbDp3aGl0ZX0gLmZpbGwge2ZpbGw6dXJsKCNncmFkMSl9IDwvc3R5bGU+ICA8cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSJ3aGl0ZSIgLz4gICAgPGRlZnM+ICAgICA8bGluZWFyR3JhZGllbnQgaWQ9ImdyYWQxIiB4MT0iMCUiIHkxPSIwJSIgeDI9IjEwMCUiIHkyPSIwJSI+ICAgICAgIDxzdG9wIG9mZnNldD0iMCUiIHN0eWxlPSJzdG9wLWNvbG9yOnJnYig1OCwgMjA4LCA5MSApIiAvPiAgICAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0eWxlPSJzdG9wLWNvbG9yOnJnYigwLDE2OCwyNTUpIiAvPiAgICAgPC9saW5lYXJHcmFkaWVudD4gICA8L2RlZnM+ICA8cmVjdCBjbGFzcz0iZmlsbCIgd2lkdGg9IjMyMCIgaGVpZ2h0PSIyMDAiIHg9IjE1IiB5PSIxNSIgcng9IjEwIiByeT0iMTAiIC8+PHRleHQgeD0iMjciIHk9IjQwIiBjbGFzcz0ibXNnVGV4dCB0ZXh0Ij5TZW5kIGEgTkZUIG1lc3NhZ2UgdG8gYW55IHdhbGxldDwvdGV4dD48dGV4dCB4PSIyNyIgeT0iNjAiIGNsYXNzPSJtc2dUZXh0IHRleHQiPmNvbXBsZXRlbHkgb24gY2hhaW4hPC90ZXh0Pjx0ZXh0IHg9IjI3IiB5PSI4MCIgY2xhc3M9Im1zZ1RleHQgdGV4dCI+PC90ZXh0Pjx0ZXh0IHg9IjI3IiB5PSIxMDAiIGNsYXNzPSJtc2dUZXh0IHRleHQiPjwvdGV4dD48dGV4dCB4PSIyNyIgeT0iMTIwIiBjbGFzcz0ibXNnVGV4dCB0ZXh0Ij48L3RleHQ+PHBvbHlnb24gcG9pbnRzPSIzMjAsMjE1IDMwMCwyMTUgMjk3LDIzMCIgc3R5bGU9ImZpbGw6cmdiKDAsMTY4LDI1NSkiIC8+IDx0ZXh0IGNsYXNzPSJ0ZXh0IHNlbmRlciBmaWxsIiB4PSIzMjAiIHk9IjI1MCIgIHRleHQtYW5jaG9yPSJlbmQiID5TZW5kZXIuZXRoPC90ZXh0PiA8YSBocmVmPSJodHRwczovL3d3dy5qcGVnTWVzc2FnZS5tZSIgdGFyZ2V0PSJfYmxhbmsiPiA8cmVjdCBjbGFzcz0icmVwbHkiIHdpZHRoPSIzMjAiIGhlaWdodD0iMzAiIHg9IjE1IiB5PSIzMDAiIHJ4PSI1IiByeT0iNSIgLz4gPHRleHQgY2xhc3M9InRleHQiIGZpbGw9InJnYigwLDE2OCwyNTUpIiB4PSIzMCIgeT0iMzIwIiBmb250LXdlaWdodD0iYm9sZCIgZm9udC1zdHlsZT0iaXRhbGljIiA+UmVwbHkgb25saW5lIEAganBlZ01lLmNvbTwvdGV4dD4gPHRleHQgY2xhc3M9InRleHQgc2VuZGVyIiBmaWxsPSJyZ2IoMCwxNjgsMjU1KSIgeD0iMzI1IiB5PSIzMjEiIHRleHQtYW5jaG9yPSJlbmQiID4+PC90ZXh0PjwvYT48L3N2Zz4=";

  return (
    <div id="container">
      <div className="topDiv" >
        <div className="imageDiv" >
          <Link to="/app">
            <img id="preview" src={SVG}  alt="NFT Message" />
          </Link>
        </div>
        <div className="info" >
          <Link to="/app">
          <h2 className="title" >Send NFT Messages</h2>
          </Link>
          Need to get in contact with a wallet owner? Send a NFT message that will show up in their wallet. NFTs are stored 100% on chain. 
        </div>
        <div className="info" >
          <Link to="/app">
          <h2 className="title" >Browse Your Messages</h2>
          </Link>
          View messages that you have sent and recieved. Easily reply to messages from other users.
        </div>
        <div className="info" >
          <Link to="/app">
          <h2 className="title" >It Pays to be Early</h2>
          </Link>
          Early users may be eligible for future Airdrops! Share JpegMe with your friends and share the love ❤️
          <Button type="button" href = "/app">
            Try it Now >
          </Button>
        </div>
      </div>
    </div>
  );
}

export default Home;