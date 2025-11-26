import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.canvas = this.element
        this.ctx = this.canvas.getContext('2d')
        this.width = window.innerWidth
        this.height = window.innerHeight
        this.particles = []
        this.time = 0
        this.isPulsing = false
        this.pulseEndTime = 0

        // Configuration - OBSIDIAN PALETTE (Animation/Pulse settings unchanged from previous step)
        this.config = {
            particleCount: 1200,
            baseSpeed: 1.0,
            variableSpeed: 0.8,
            baseSize: 0.6,
            variableSize: 1.2,
            oscillationScale: 10,
            oscillationSpeed: 0.04,
            pathWaveAmplitude: 100,
            pathWaveFrequency: 0.005,
            pathWaveSpeed: 0.001,
            // PALETTE: Gold, Sand, Bronze, Spice Orange
            colors: [
                '255, 215, 0',  // Gold
                '238, 214, 175',// Sand
                '205, 127, 50', // Bronze
                '210, 105, 30'  // Chocolate/Spice
            ],
            pulseIntervalMin: 5000,
            pulseIntervalMax: 10000,
            pulseDuration: 3000,
            // PULSE COLOR: Rich Gold
            pulseColor: '255, 165, 0'
        }

        this.nextPulseTime = Date.now() + this.getRandomRange(this.config.pulseIntervalMin, this.config.pulseIntervalMax)

        // Bind methods
        this.animate = this.animate.bind(this)
        this.resize = this.resize.bind(this)

        // Start
        window.addEventListener('resize', this.resize)
        this.resize()
        this.initParticles()
        this.animate()
    }

    disconnect() {
        window.removeEventListener('resize', this.resize)
        cancelAnimationFrame(this.animationFrame)
    }

    resize() {
        this.width = window.innerWidth
        this.height = window.innerHeight
        this.canvas.width = this.width
        this.canvas.height = this.height
        this.initParticles()
    }

    getRandomRange(min, max) {
        return Math.random() * (max - min) + min
    }

    initParticles() {
        this.particles = []
        for (let i = 0; i < this.config.particleCount; i++) {
            this.particles.push(this.createParticle(true))
        }
    }

    createParticle(initiallyOnScreen = false) {
        const spread = Math.min(this.width * 0.05, 80)

        return {
            x: 0,
            y: initiallyOnScreen ? Math.random() * this.height : this.height + 20,
            offsetFromCenter: (Math.random() - 0.5) * spread,
            size: this.config.baseSize + Math.random() * this.config.variableSize,
            speed: this.config.baseSpeed + Math.random() * this.config.variableSpeed,
            angle: Math.random() * Math.PI * 2,
            velocityAngle: Math.random() * this.config.oscillationSpeed,
            individualAmplitude: Math.random() * this.config.oscillationScale,
            rgb: this.config.colors[Math.floor(Math.random() * this.config.colors.length)],
            glitterPhase: Math.random() * Math.PI * 2,
            glitterSpeed: 30 + Math.random() * 50
        }
    }

    updateParticle(p) {
        p.y -= p.speed

        const globalPathOffset = Math.sin(p.y * this.config.pathWaveFrequency + this.time) * this.config.pathWaveAmplitude

        p.angle += p.velocityAngle
        const localOscillation = Math.sin(p.angle) * p.individualAmplitude

        p.x = (this.width / 2) + globalPathOffset + p.offsetFromCenter + localOscillation

        if (p.y < -20) {
            Object.assign(p, this.createParticle(false))
        }
    }

    drawParticle(p) {
        let currentAlpha = 0.6 // Base alpha from the CSS change before
        let currentRgb = p.rgb
        let pulseIntensity = 0.0

        if (this.isPulsing) {
            // --- 1. Calculate Smooth Pulse Intensity (EASE IN/OUT) ---
            const now = Date.now()
            const progress = (now - (this.pulseEndTime - this.config.pulseDuration)) / this.config.pulseDuration
            // Sine curve for smooth ease-in (0 -> 1) and ease-out (1 -> 0)
            pulseIntensity = Math.sin(progress * Math.PI)

            // --- 2. Apply Pulse Color and Scale Alpha ---
            currentRgb = this.config.pulseColor

            // Internal glitter oscillation (always runs when pulsing)
            const sparkleOscillation = Math.abs(Math.sin(this.time * 10 * p.glitterSpeed + p.glitterPhase)) * 0.8;

            // Final Alpha: Base alpha + glitter scaled by the pulseIntensity curve (eased in/out)
            currentAlpha = 0.6 + (sparkleOscillation * pulseIntensity * 0.4);
        }

        // For particles not in the pulse color, randomly make them a little darker to add depth
        if (currentRgb != this.config.pulseColor && Math.random() > 0.95) {
            currentAlpha *= 0.5
        }

        this.ctx.fillStyle = `rgba(${currentRgb}, ${currentAlpha})`;
        this.ctx.fillRect(p.x, p.y, p.size, p.size);
    }

    animate() {
        this.time += this.config.pathWaveSpeed
        const now = Date.now()

        if (!this.isPulsing) {
            if (now >= this.nextPulseTime) {
                this.isPulsing = true
                this.pulseEndTime = now + this.config.pulseDuration
            }
        } else {
            if (now >= this.pulseEndTime) {
                this.isPulsing = false
                this.nextPulseTime = now + this.getRandomRange(this.config.pulseIntervalMin, this.config.pulseIntervalMax)
            }
        }

        this.ctx.clearRect(0, 0, this.width, this.height)

        this.particles.forEach(p => {
            this.updateParticle(p)
            this.drawParticle(p)
        })

        this.animationFrame = requestAnimationFrame(this.animate)
    }
}