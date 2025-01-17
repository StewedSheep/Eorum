import socket from"./user_socket.js"

let Hooks = {};


Hooks.Chat = {
    mounted() {
        let channel_forum = socket.channel("forum:general", {})
        channel_forum.join()
            .receive("ok", resp => { console.log("Joined chat successfully", resp) })
            .receive("error", resp => { console.log("Unable to join chat", resp) })
        this.listenForMessages(channel_forum)
    },

    destroyed() {
        socket.disconnect()
    },

  listenForMessages(channel) {
      const ul = document.getElementById('chat-box');    // list of messages.
      const user_id = document.getElementById('sender-id');// id of message sender
      const name = document.getElementById('name');      // name of message sender
      const msg = document.getElementById('msg');        // message input field
      const send = document.getElementById('send');      // send button
      // ul.scrollTop = ul.scrollHeight;


      channel.on('shout', function (payload) {
          render_message(payload)
        });
        
        
        // Send the message to the server on "shout" channel
        function sendMessage() {
        
          channel.push('shout', {        
            name: name.value, // get value of "name" of person sending the message.
            sender_id: user_id.value,
            message: msg.value,          // get message text (value) from msg input field.
            inserted_at: new Date()      // date + time of when the message was sent
          });
        
          msg.value = '';                // reset the message input field for next message.
        }
        
        // Render the message with Tailwind styles
        function render_message(payload) {

          let isCurrentUser = payload.sender_id == window.userId;
          // console.log(window.userId, payload, isCurrentUser)
          const div = document.createElement("div"); // create new list item DOM element
      
          div.innerHTML = `
          <div class="flex mb-2 ${
                    isCurrentUser ? 'justify-end' : 'justify-start'
                }">

                  <div class="flex flex-col max-w-96 rounded-lg p-3 gap-1 ${
                    isCurrentUser ? 'bg-purple-700 text-white' : 'bg-white text-gray-700'
                }">
                
                  <div class="font-semibold">${isCurrentUser ? '' : payload.name}</div>
                    <p>${payload.message}</p>
                    <div class="text-xs ${
                      isCurrentUser ? 'text-gray-300 text-right' : 'text-gray-500'
                  }">
                      <div class="flex justify-between text-sm pt-1">
                      ${formatTime(payload.inserted_at)}
                    </div>
                    </div>
                  </div>
                </div>
          `

          // Append to list of messages
          ul.prepend(div);
          // trigger event for custom scroll logic in hooks
          ul.dispatchEvent(new Event('custom:update'));
        }
        
        // Listen for the [Enter] keypress event to send a message:
        msg.addEventListener('keypress', function (event) {
          if (event.key === `Enter` && msg.value.length > 0) { // don't sent empty msg.
            sendMessage()
          }
        });
        
        // On "Send" button press
        send.addEventListener('click', function (event) {
          if (msg.value.length > 0) { // don't sent empty msg.
            sendMessage()
          }
        });
        
        // Date formatting
        function formatTime(datetime) {
          const m = new Date(datetime);
          return ("0" + (m.getUTCMonth()+1)).slice(-2) + "/" 
            + ("0" + m.getUTCDate()).slice(-2) + " " +
            ("0" + m.getUTCHours()).slice(-2) + ":"
            + ("0" + m.getUTCMinutes()).slice(-2);
      }
    }
};

Hooks.Scroll = {
    // Mounted position is at the bottom
  mounted() {
    const el = document.getElementById('chat-box');

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