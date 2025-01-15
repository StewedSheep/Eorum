let Hooks = {};

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