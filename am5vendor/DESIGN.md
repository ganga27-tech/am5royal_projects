# Design System: AM5 Royal Vendor App

This design system defines the semantic guidelines, colors, typography, component styles, and layout principles for the AM5 Royal Vendor application. It is optimized for premium UI styling and clean frontend development.

## 1. Visual Theme & Atmosphere

The interface is built to evoke a clinical yet warm, premium atmosphere — akin to a luxury service concierge. It balances high administrative reliability with royal brand heritage. 
* **Density:** Balanced and readable (5/10), avoiding clutter while keeping critical details accessible.
* **Variance:** Structured alignment with clean, asymmetrical white space.
* **Tone:** Trustworthy, professional, and refined.

---

## 2. Color Palette & Roles

To maintain high visual quality, the application strictly adheres to the official AM5 Royal brand palette, banning generic neon glows or saturated AI purple accents.

* **Primary Royal Blue** (`#0C3D98`) — Brand identity, primary CTAs, active selections, and core visual anchors.
* **Sky Blue** (`#2E8BF0`) — Interactive highlights, secondary links, and info badges.
* **Crown Gold Accent** (`#D4A33A`) — Premium elements, verification statuses, and secondary CTAs.
* **Deep Navy Text** (`#16315D`) — High-contrast primary headers, body copy, and titles.
* **Muted Slate** (`#6C84A5`) — Secondary descriptions, captions, and inactive metadata.
* **Canvas White** (`#F7FBFF`) — Light mode background surface.
* **Dark Slate Canvas** (`#0B1220`) — Dark mode background surface.
* **Whisper Border** (`#D8E6F5`) — Clean, thin borders for containers and cards.

---

## 3. Typography Rules

* **Display/Headlines:** Track-tight (`letterSpacing: -0.4` to `-0.5`), bold hierarchy using weights (`FontWeight.w800` or `FontWeight.bold`). Size must reflect hierarchy without screaming.
* **Body:** Relaxed line height, max 65 characters per line to ensure high readability. Font size `14px`–`16px`.
* **Primary Font Stacks:** Open Sans for user-friendly UI readability, paired with distinct weights for labels and descriptors.

---

## 4. Component Stylings

* **Cards:**
  * Generously rounded corners (`28px`–`32px`).
  * Thin, precise `1.5px` borders tinted with the component's semantic color.
  * Soft, diffused drop shadows (`blurRadius: 12`, `offset: Offset(0, 4)`) that match the card's background hue to avoid muddy gray shadows.
* **Buttons:**
  * Flat, solid color fills matching `AppColors.primary` or `AppColors.accent`.
  * Rounded edges matching input styles (`16px`).
* **Modal Bottom Sheets:**
  * Thick, high-contrast, rounded drag handles (`44x5px`) using neutral tones (`Colors.black26` / `Colors.white24`).
  * Soft blur backdrop filter (`sigmaX: 16.0, sigmaY: 16.0`) for a glassmorphism feel.
* **Inputs/Forms:**
  * Label above input, clean validation errors below.
  * Border thickness `1px` (default) scaling to `2px` (active focus).

---

## 5. Layout & Responsive Principles

* **No Overlapping:** Every element occupies its own strict spatial boundary. Floating or absolute-positioned text overlaps are prohibited.
* **Responsive Collapse:** Mobile layouts must cascade to a single-column layout below `768px`.
* **Touch Targets:** Tap targets for cards, list items, and buttons must be a minimum of `48px` to guarantee user-friendly navigation.

---

## 6. Motion & Interaction

* **Spring Physics:** Weighty and natural feedback transitions (`stiffness: 100, damping: 20`) for interactive selections.
* **Splash Feedback:** Fluid splash responses on card tap to immediately register user intent.

---

## 7. Anti-Patterns (Banned AI Clichés)

* **No generic emojis** in headers or system text.
* **No pure black** (`#000000`) for text or shadows — always use `AppColors.textPrimary` or charcoal tones.
* **No oversaturated neons or violet glows** — keep accents clean and brand-specific.
* **No generic placeholder text** or empty card grids.
