let Post = {
  init(socket, element) {
    if (!element) { return }
    socket.connect()
    this.onReady(socket)
  },

  onReady(socket) {
    console.log("on Ready")
    let input = document.querySelector("#textarea")
    let preview = document.querySelector("#preview")
    let previewTab = document.querySelector("#preview-tab")

    let postChannel = socket.channel("post")
    postChannel.on("preview", (resp) => {
      preview.innerHTML = resp["preview"]
    })
    postChannel.join()
      .receive("ok", resp => console.log("joined the post channel", resp))
      .receive("error", reason => console.log("join failed", reason))


    previewTab.addEventListener("click", e => {
      postChannel.push("update", input.value)
    })

  }
}


export default Post
