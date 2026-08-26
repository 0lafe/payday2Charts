export default function showoffContent({ audio, timeout = 5000 }) {    
    return {
        audio,
        timeout,
        show: false,

        init() {
            this.show = true

            window.setTimeout(() => {
                this.show = false
            }, this.timeout)
        }
    }
}