import fs from "fs";

export interface PortServer {
  handle_call();
}

const input = fs.createReadStream("", { fd: 3 });
const output = fs.createWriteStream("", { fd: 4 });

export function run() {}
