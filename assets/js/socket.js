import { Socket } from "phoenix";
import { LOADIPHLPAPI } from "dns";

let socket = new Socket("/socket", {params: {token: window.userToken}});
let channel = socket.channel("room:lobby", {})
let base64AudioData;

const getPath = () => {
  return window.location.pathname;
}

const base64ToArrayBuffer = data => {
  let binaryString = window.atob(data);
  let len = binaryString.length;
  let bytes = new Uint8Array(len);

  for (let i = 0; i < len; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }

  return bytes.buffer;
}

const playSong = () => {
  let audioCtx = new (window.AudioContext || window.webkitAudioContext)();
  let source = audioCtx.createBufferSource();

  audioCtx.decodeAudioData(base64ToArrayBuffer(base64AudioData), buffer => {
    source.buffer = buffer;
    source.connect(audioCtx.destination);
    source.start(0);
  })
}

if (getPath() == "/song") {
  socket.connect();

  // Now that you are connected, you can join channels with a topic:
  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })

    console.log(window.songID)

  channel.push("song", {body: window.songID})
}

channel.on("song", payload => {
  base64AudioData = payload.chunk;

  playSong();
})

export default socket
