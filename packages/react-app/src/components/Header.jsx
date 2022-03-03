import { PageHeader } from "antd";
import React from "react";

// displays a page header

export default function Header() {
  return (
      <PageHeader
        title="✉️jpegMessageMe"
        subTitle="Send Messages as NFTs, On-Chain"
        style={{ cursor: "pointer" }}
      />
  );
}
