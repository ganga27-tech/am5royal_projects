/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        bg: "#080B12",
        panel: "#0E1420",
        elevated: "#151E2E",
        hover: "#1B2638",
        border: "#263247",
        
        primary: {
          DEFAULT: "#22D3EE",
          hover: "#06B6D4",
          muted: "rgba(34, 211, 238, 0.12)",
        },
        secondary: {
          DEFAULT: "#8B5CF6",
          hover: "#7C3AED",
          muted: "rgba(139, 92, 246, 0.12)",
        },
        info: {
          DEFAULT: "#38BDF8",
          muted: "rgba(56, 189, 248, 0.12)",
        },
        success: {
          DEFAULT: "#34D399",
          muted: "rgba(52, 211, 153, 0.12)",
        },
        warning: {
          DEFAULT: "#FBBF24",
          muted: "rgba(251, 191, 36, 0.12)",
        },
        critical: {
          DEFAULT: "#FB4B5F",
          muted: "rgba(251, 75, 95, 0.12)",
        },
        
        text: {
          primary: "#F1F5F9",
          secondary: "#94A3B8",
          disabled: "#475569",
        },
      },
      fontFamily: {
        sans: ["Inter", "-apple-system", "BlinkMacSystemFont", "Segoe UI", "Roboto", "sans-serif"],
        mono: ["JetBrains Mono", "Fira Code", "SFMono-Regular", "Menlo", "Monaco", "Consolas", "monospace"],
      },
    },
  },
  plugins: [],
};
