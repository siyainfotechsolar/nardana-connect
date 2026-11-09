/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          blue: '#123B67',
          dark: '#0D2745',
          green: '#16A36A',
          yellow: '#F3B83F',
          surface: '#F8FAFC',
        }
      }
    },
  },
  plugins: [],
}

