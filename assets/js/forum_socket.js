export default function listenForMessages(channel) {
    function getElements() {
        return {
            user_id: document.getElementById('sender-id'),
            name: document.getElementById('name'),
            msg: document.getElementById('msg'),
            room: document.getElementById('room'),
            send: document.getElementById('send')
        };
    }

    // Get initial elements so updates the listeners on page change
    let elements = getElements();
    
    // Remove any existing event listeners
    if (window.prevMsgListener) {
        elements.msg.removeEventListener('keypress', window.prevMsgListener);
    }
    
    if (window.prevSendListener) {
        elements.send.removeEventListener('click', window.prevSendListener);
    }

    // Store listeners for future channel cleanup
    window.prevMsgListener = msgKeyPressListener;
    window.prevSendListener = sendClickListener;

    channel.on('shout', function(payload) {
      if (elements.room.value == payload.room){
        render_message(payload);}
    });

    function sendMessage() {
        const currentElements = getElements();
        // Send message through forum channel
        channel.push('shout', {        
            name: currentElements.name.value,
            sender_id: currentElements.user_id.value,
            message: currentElements.msg.value,
            inserted_at: new Date(),
            room: currentElements.room.value
        });
        
        // Reset message field
        currentElements.msg.value = '';
    }

    // Prevent empty send
    function msgKeyPressListener(event) {
        if (event.key === 'Enter' && getElements().msg.value.length > 0) {
            sendMessage();
        }
    }
    
    // Prevent empty send
    function sendClickListener(event) {
        if (getElements().msg.value.length > 0) {
            sendMessage();
        }
    }
    
    // Add event listeners
    elements.msg.addEventListener('keypress', msgKeyPressListener);
    elements.send.addEventListener('click', sendClickListener);

    // Render message function stylize w tailwind
    function render_message(payload) {
        const currentElements = getElements();
        let isCurrentUser = payload.sender_id == window.userId;

        if (isCurrentUser == true){console.log("t")}
        
        const div = document.createElement("div");
        div.innerHTML = `
            <div class="flex mb-2 px-2 ${
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
        `;
        
        // append message to chat box
        document.getElementById('chat-box-' + currentElements.room.value).prepend(div);
        document.getElementById('chat-box-' + currentElements.room.value).dispatchEvent(new Event('custom:update'));
    }

    // Date formatter
    function formatTime(datetime) {
        const m = new Date(datetime);
        return ("0" + m.getUTCDate()).slice(-2) + "/"
            + ("0" + (m.getUTCMonth()+1)).slice(-2) + " " +
            ("0" + m.getUTCHours()).slice(-2) + ":"
            + ("0" + m.getUTCMinutes()).slice(-2);
    }
}
