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

        // Configuration - OBSIDIAN PALETTE
        this.config = {
            // UPDATED: Increased particle count to 6000 for wider, denser path
            particleCount: 6000,
            baseSpeed: 0.4,       // Slower drift
            variableSpeed: 0.4,
            baseSize: 0.6,
            variableSize: 1.2,
            oscillationScale: 10,
            oscillationSpeed: 0.015,
            pathWaveAmplitude: 100,
            pathWaveFrequency: 0.005,
            pathWaveSpeed: 0.0005,
            // Base colors (bronze/copper/spice)
            colors: [
                '255, 215, 0',  // Gold
                '180, 110, 60', // Bronze
                '139, 69, 19',  // Deep Copper
                '92, 64, 51'    // Dark Brown/Spice
            ],
            pulseIntervalMin: 5000,
            pulseIntervalMax: 10000,
            pulseDuration: 3000,
            // Target sparkling color
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

    // --- HELPER FUNCTION FOR SMOOTH COLOR TRANSITION ---
    lerpColor(color1, color2, weight) {
        const c1 = color1.split(',').map(n => parseInt(n.trim()));
        const c2 = color2.split(',').map(n => parseInt(n.trim()));
        const r = Math.round(c1[0] + (c2[0] - c1[0]) * weight);
        const g = Math.round(c1[1] + (c2[1] - c1[1]) * weight);
        const b = Math.round(c1[2] + (c2[2] - c1[2]) * weight);
        return `${r}, ${g}, ${b}`;
    }
    // --------------------------------------------------------

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
        // UPDATED: Increased spread to 15% of width (was 7.5%) and max pixels to 180 (was 120)
        const spread = Math.min(this.width * 0.15, 180)

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
        let currentAlpha = baseAlpha;
        let currentRgb = p.rgb;
        let pulseIntensity = 0.0;
        const glowRadius = p.size * 20;

        if (this.isPulsing) {
            // --- 1. Calculate Smooth Pulse Intensity (EASE IN/OUT) ---
            const now = Date.now();
            const progress = (now - (this.pulseEndTime - this.config.pulseDuration)) / this.config.pulseDuration;
            pulseIntensity = Math.sin(progress * Math.PI);

            // --- 2. Phase Color Transition (Bronze/Spice to Gold) ---
            currentRgb = this.lerpColor(p.rgb, this.config.pulseColor, pulseIntensity);

            // --- 3. Set Glow: Stronger during pulse ---
            this.ctx.shadowBlur = glowRadius * (1 + pulseIntensity * 1.5);
            this.ctx.shadowColor = `rgba(${currentRgb}, 1)`;

            const sparkleOscillation = Math.abs(Math.sin(this.time * 10 * p.glitterSpeed + p.glitterPhase)) * 0.8;
            currentAlpha = baseAlpha + (sparkleOscillation * pulseIntensity * 0.15);
        } else {
            // --- 4. Subtle Ambient Glow: Always On ---
            this.ctx.shadowBlur = glowRadius * 0.5;
            this.ctx.shadowColor = `rgba(${currentRgb}, 0.5)`;
            currentAlpha = baseAlpha;
        }

        // Dimming logic (for depth)
        if (currentRgb != this.config.pulseColor && Math.random() > 0.95) {
            currentAlpha *= 0.7;
        }

        this.ctx.fillStyle = `rgba(${currentRgb}, ${currentAlpha})`;

        // --- 5. Draw as a Circle for Smoother Light Source ---
        this.ctx.beginPath();
        this.ctx.arc(p.x, p.y, p.size / 2, 0, Math.PI * 2, false);
        this.ctx.fill();

        // Reset shadow after drawing
        this.ctx.shadowBlur = 0;
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