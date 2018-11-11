import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {}})

export default socket
