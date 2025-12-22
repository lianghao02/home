/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./*.{html,js}"],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', 'Noto Sans TC', 'sans-serif'],
      },
      colors: {
        bg: '#0f172a',
        text: '#f8fafc',
        'card-bg': 'rgba(30, 41, 59, 0.7)',
        accent: '#38bdf8',
        'accent-hover': '#0ea5e9',
      },
      animation: {
        fadeInDown: 'fadeInDown 0.8s ease-out',
        fadeInUp: 'fadeInUp 0.8s ease-out 0.2s backwards',
      },
      keyframes: {
        fadeInDown: {
          '0%': { opacity: '0', transform: 'translateY(-20px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        fadeInUp: {
          '0%': { opacity: '0', transform: 'translateY(20px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        }
      }
    }
  },
  plugins: [],
}
