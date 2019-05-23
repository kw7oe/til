let Post = {
  init(socket, element) {
    if (!element) { return }
    socket.connect()
    this.onReady(socket)
  },

  onReady(socket) {
    console.log("on Ready")
    let input = document.querySelector("#post_content")
    let preview = document.querySelector("#preview")
    let postChannel = socket.channel("post")

    postChannel.on("preview", (resp) => {
      preview.innerHTML = resp["preview"]
      document.querySelectorAll('pre code').forEach((block) => {
        hljs.highlightBlock(block);
      });
    })
    postChannel.join()
      .receive("ok", resp => console.log("joined the post channel", resp))
      .receive("error", reason => console.log("join failed", reason))


    postChannel.push("update", input.value)
    input.addEventListener("keyup", e => {
      postChannel.push("update", input.value)
    })

  }
}


export default Post
