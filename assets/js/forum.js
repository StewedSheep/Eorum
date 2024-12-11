let Forum = {
    init(socket) {
        let channel_forum = socket.channel("forum:general", {})
        channel_forum.join()
            .receive("ok", resp => { console.log("Joined chat successfully", resp) })
            .receive("error", resp => { console.log("Unable to join chat", resp) })
        this.listenForMessages(channel_forum)
    },

listenForMessages(channel_forum) {
    document.getElementById("chat-form").addEventListener("submit", function(e) {
        e.preventDefault()

        let message = document.getElementById("user-msg").value
        let userId = document.getElementById('user-id').value
        let userName = document.getElementById('user-name').value
        

        channel_forum.push('shout', {sender_id: userId, name: userName, message: message})

        document.getElementById("user-msg").value = ""
    })

    channel_forum.on('shout', (payload) => {
        let chatBox = document.querySelector("#chat-box");
    
        // Destructure payload into usable variables
        const { sender_id, name, message, timestamp } = payload;
    
        // Determine message alignment based on the sender
        let isCurrentUser = true;
    
        // Create the message block dynamically
        const msgBlock = document.createElement('div');
    
        // Dynamically add the message content
        msgBlock.innerHTML = `

            <div class="flex ${
                isCurrentUser ? 'justify-end' : 'justify-start'
            } mb-4">
              <div class="flex flex-col">

                <div class="flex justify-between text-sm pt-2">
                  <span class="font-medium text-gray-600">${name}</span>
                  <span class="text-gray-500">${timestamp || 'Just now'}</span>
                </div>
                <div class="flex max-w-96 ${
                    isCurrentUser ? 'bg-purple-700 text-white' : 'bg-white text-gray-700'
                } rounded-lg p-3 gap-3">
                  <p>
                  ${message}
                  </p>
                </div>
              </div>
            </div>
        `;
    
        // Append the message block to the chat box and scroll to bottom
        chatBox.appendChild(msgBlock);
        chatBox.scrollTop = chatBox.scrollHeight;
    })
}
}

export default Forum