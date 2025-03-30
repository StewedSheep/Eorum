import socket from"./user_socket.js"
import listenForMessages from"./forum_socket.js"

let Hooks = {};


Hooks.Chat = {
    mounted() {
        this.channelForum = socket.channel("forum", {room: this.el.dataset.room, user_id: this.el.dataset.user_id});
        this.channelForum.join()
            .receive("ok", resp => { 
                console.log("Joined "+ room +" successfully", resp);
                listenForMessages(this.channelForum);
            })
            .receive("error", resp => { console.log("Unable to join "+ room, resp) });
    },

    updated() {
      if (this.channelForum) {
            this.channelForum.leave()
                .receive("ok", () => { console.log("Left "+ room +" channel"); })
                .receive("error", resp => { console.log("Unable to leave "+ room, resp); });
        }

      this.channelForum = socket.channel("forum", {room: this.el.dataset.room, user_id: this.el.dataset.user_id});
      this.channelForum.join()
          .receive("ok", resp => { console.log("Joined " + room + " successfully", resp);
            listenForMessages(this.channelForum);
           })
          .receive("error", resp => { console.log("Unable to join "+ room, resp) })
      
    },

    destroyed() {
      socket.channel("forum", {}).leave()
          .receive("ok", () => { console.log("Left  "+ room +"  channel"); })
          .receive("error", (response) => { console.log("Unable to leave "+ room +" channel", response); });
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