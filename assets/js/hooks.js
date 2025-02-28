import socket from"./user_socket.js"
import listenForMessages from"./forum_socket.js"

let Hooks = {};


Hooks.Chat = {
    mounted() {
        this.channelForum = socket.channel("forum", {room: this.el.dataset.room});
        this.channelForum.join()
            .receive("ok", resp => { 
                console.log("Joined chat successfully", resp);
                listenForMessages(this.channelForum);
            })
            .receive("error", resp => { console.log("Unable to join chat", resp) });
    },

    updated() {
      if (this.channelForum) {
            this.channelForum.leave()
                .receive("ok", () => { console.log("Left previous channel"); })
                .receive("error", resp => { console.log("Unable to leave previous channel", resp); });
        }

      this.channelForum = socket.channel("forum", {room: this.el.dataset.room});
      this.channelForum.join()
          .receive("ok", resp => { console.log("Joined new chat successfully", resp);
            listenForMessages(this.channelForum);
           })
          .receive("error", resp => { console.log("Unable to join chat", resp) })
      
    },

    destroyed() {
      socket.channel("forum", {}).leave()
          .receive("ok", () => { console.log("Left the forum channel"); })
          .receive("error", (response) => { console.log("Unable to leave forum channel", response); });
    }
};

Hooks.Scroll = {
    // Mounted position is at the bottom
  mounted() {
    const el = document.getElementById('chat-box-' + this.el.dataset.room);

    // Listen for the custom event
    el.addEventListener('scroll', () => {
        if (-(el.scrollTop) + el.clientHeight >= el.scrollHeight) {
          this.pushEvent('scrolled-to-top', {});
        }
      });

    el.addEventListener('custom:update', () => {
        const pixelsBelowBottom = el.scrollHeight - el.clientHeight - el.scrollTop;
    //   Only scroll to the bottom if we are within 30% of the bottom
    if (pixelsBelowBottom < el.clientHeight * 0.3) {
        el.scrollTop = el.scrollHeight;
            }
        }
    )}
};


export default Hooks