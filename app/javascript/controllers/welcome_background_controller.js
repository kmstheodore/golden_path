import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.canvas = this.element
        this.ctx = this.canvas.getContext('2d')
        this.width = window.innerWidth
        this.height = window.innerHeight
        this.particles = []
        this.time = 0

        // Configuration - FINAL BEST VERSION (NO SHADOWS)
        this.config = {
            // Particle count remains optimized for mobile performance
            particleCount: 1125,

            // Size settings (4.25 base / 7.5 variable)
            baseSpeed: 1.0,
            variableSpeed: 0.8,
            baseSize: 2.25,
            variableSize: 4.5,

            oscillationScale: 10,
            oscillationSpeed: 0.04,
            pathWaveAmplitude: 100,
            pathWaveFrequency: 0.005,
            pathWaveSpeed: 0.001,

            // Base colors (bronze/copper/spice)
            colors: [
                '150, 100, 50', // Uniform Base Antique Gold
                '140, 95, 45',  // Slight variation (Darker)
                '160, 105, 55', // Slight variation (Lighter)
                '130, 90, 40'   // Deepest Base
            ]
        }

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
        // Path width remains wide (18.75% of width) for mobile visibility
        const spread = Math.min(this.width * 0.1875, 225)

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
        const baseAlpha = 0.9;
        let currentAlpha = baseAlpha

        // Dimming logic (for depth)
        if (Math.random() > 0.95) {
            currentAlpha *= 0.7;
        }

        this.ctx.fillStyle = `rgba(${p.rgb}, ${currentAlpha})`;

        // --- 5. Draw as a Circle for Smoother Light Source ---
        this.ctx.beginPath();
        this.ctx.arc(p.x, p.y, p.size / 2, 0, Math.PI * 2, false);
        this.ctx.fill();

        // Shadow reset removed
    }

    animate() {
        this.time += this.config.pathWaveSpeed
        
        // Full clear of the canvas background every frame
        this.ctx.clearRect(0, 0, this.width, this.height)

        // Composite mode removed as it only works well with shadows/trails
        // this.ctx.globalCompositeOperation = 'lighter';

        this.particles.forEach(p => {
            this.updateParticle(p)
            this.drawParticle(p)
        })

        // Reset composite mode removed

        this.animationFrame = requestAnimationFrame(this.animate)
    }
}