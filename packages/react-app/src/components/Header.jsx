import { PageHeader } from "antd";
import React from "react";

// displays a page header

export default function Header() {
  return (
      <PageHeader
        title="📨️ jpegMe"
        subTitle="send NFT messages on-chain"
        style={{ cursor: "pointer" }}
      />
  );
}
