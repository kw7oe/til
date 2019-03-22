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

var tx = document.getElementsByTagName('textarea');
for (var i = 0; i < tx.length; i++) {
  tx[i].setAttribute('style', 'height:' + (tx[i].scrollHeight) + 'px;overflow-y:hidden;');
  tx[i].addEventListener("input", OnInput, false);
}

function OnInput() {
  if (this.scrollHeight >= 400) {
    this.style.overflowY = "scroll"
  } else {
    this.style.height = 'auto';
    this.style.height = (this.scrollHeight) + 'px';
  }
}
