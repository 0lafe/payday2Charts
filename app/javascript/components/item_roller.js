export default function itemRoller({
    images,
    winningIndex,
    duration = 10000,
}) {
    return {
        images,
        winningIndex,
        duration,

        rolling: false,
        finished: false,

        init() {
            if (this.rolling) return;

            this.rolling = true;
            this.finished = false;

            this.$nextTick(() => {
                const winner = this.$refs.track.querySelector(
                    `[data-index="${this.winningIndex}"]`
                );

                if (!winner) return;

                const viewportCenter =
                    this.$refs.viewport.clientWidth / 2;

                const edgePadding = winner.offsetWidth * 0.2;

                const winningPosition =
                    edgePadding +
                    Math.random() *
                    (winner.offsetWidth - edgePadding * 2);

                const target =
                    viewportCenter -
                    winner.offsetLeft -
                    winningPosition;

                const animation = this.$refs.track.animate(
                    [
                        {
                            transform: 'translateX(0px)',
                        },
                        {
                            transform: `translateX(${target}px)`,
                        },
                    ],
                    {
                        duration: this.duration,
                        easing: 'cubic-bezier(0.08, 0.6, 0.15, 1)',
                        fill: 'forwards',
                    }
                );

                animation.finished.then(() => {
                    this.rolling = false;
                    this.finished = true;
                });
            });
        },
    };
}