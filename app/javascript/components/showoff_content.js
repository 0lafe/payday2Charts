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

            if (this.audio) {
                const audio = new Audio(this.audio)

                audio.currentTime = 0
                audio.volume = 0.1

                audio.play().catch(() => {
                    console.log("Something went wrong with the audio")
                })
            }
        }
    }
}