// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.sass"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"
import "jquery"
import "popper.js"
import "bootstrap"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
import socket from "./socket"
import Post from "./post"

Post.init(socket, document.getElementById("preview"))


function onInput() {
  this.style.height = 'auto';
  this.style.height = (this.scrollHeight) + 'px';
}

var tx = document.getElementById('post_content');
if (tx) {
  tx.setAttribute('style', 'height:' + (tx.scrollHeight) + 'px;overflow-y:hidden;');
  if (tx.scrollHeight >= 400) {
    tx.style.overflowY = "scroll"
  }
  tx.addEventListener("input", onInput, false);
}
