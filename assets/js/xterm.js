import { Terminal } from "@xterm/xterm";
import { Socket } from "phoenix";

import "@xterm/xterm/css/xterm.css";

const terminal = new Terminal();
terminal.open(document.getElementById("terminal"));

const socket = new Socket("/socket", { params: { userToken: "secret" } });
socket.connect();
const channel = socket.channel("iex:session", {});

channel
  .join()
  .receive("ok", () => console.log("Connected to IEx session"))
  .receive("error", () => console.error("Failed to connect"));

terminal.onData((data) => {
  channel.push("input", { data });
});

channel.on("output", (payload) => {
  terminal.write(payload.data);
});
