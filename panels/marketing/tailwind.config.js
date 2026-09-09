/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        cream: {
          50: '#FDFBF7',
          100: '#FAF6EF',
          200: '#F5EFEB',
          300: '#EFE7DA',
          400: '#E5D8C1',
          500: '#D5C29F',
          600: '#BAA279',
          700: '#9B825B',
          800: '#75603F',
          900: '#4F3F28',
          DEFAULT: '#FAF7F2',
        },
        gold: {
          50: '#FCF9EE',
          100: '#F7F0D4',
          200: '#EFE1A9',
          300: '#E4CD78',
          400: '#DAB84E',
          500: '#C59A27', // Royal Antique Gold
          600: '#AB811A',
          700: '#8A6412',
          800: '#69490C',
          900: '#4D3407',
          DEFAULT: '#C59A27',
        },
        charcoal: {
          50: '#F8F7F6',
          100: '#EDEBE9',
          200: '#DCD7D2',
          300: '#BDB4AB',
          400: '#8E8276',
          500: '#685D51',
          600: '#4D443B',
          700: '#383029',
          800: '#26201B',
          900: '#171310',
          DEFAULT: '#1E1B18',
        },
        royal: {
          50: '#EFF6FF',
          100: '#DBEAFE',
          200: '#BFDBFE',
          300: '#93C5FD',
          400: '#60A5FA',
          500: '#3B82F6',
          600: '#2563EB',
          700: '#1D4ED8',
          800: '#1E40AF',
          900: '#0F4C81',
          950: '#092347',
          DEFAULT: '#0F4C81',
        },
        accent: {
          purple: '#7C3AED',
          cyan: '#0891B2',
          emerald: '#059669',
          rose: '#E11D48',
          amber: '#D97706',
          indigo: '#4F46E5',
        }
      },
      fontFamily: {
        outfit: ['Outfit', 'sans-serif'],
        sans: ['Plus Jakarta Sans', 'Inter', '-apple-system', 'sans-serif'],
        serif: ['Cinzel', 'Playfair Display', 'serif'],
        mono: ['JetBrains Mono', 'Fira Code', 'monospace'],
      },
      boxShadow: {
        'cream-sm': '0 2px 8px -2px rgba(138, 100, 18, 0.06), 0 1px 4px -1px rgba(0, 0, 0, 0.04)',
        'cream-md': '0 8px 24px -4px rgba(138, 100, 18, 0.08), 0 2px 8px -2px rgba(0, 0, 0, 0.04)',
        'cream-lg': '0 16px 36px -6px rgba(138, 100, 18, 0.12), 0 4px 12px -2px rgba(0, 0, 0, 0.06)',
        'cream-xl': '0 24px 50px -10px rgba(138, 100, 18, 0.16), 0 8px 20px -4px rgba(0, 0, 0, 0.08)',
        'gold-glow': '0 0 25px -5px rgba(197, 154, 39, 0.35)',
      }
    },
  },
  plugins: [],
}
