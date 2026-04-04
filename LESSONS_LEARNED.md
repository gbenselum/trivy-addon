# Blueprint for Success: Cockpit Plugin Development
**Lessons Learned from the Trivy Security Dashboard Project**

This document details the architectural and technical "Best Takes" that transformed a fragile Cockpit addon into a stable, professional-grade security suite. Feed this into your AI coding assistant to jumpstart any new Cockpit project.

## 1. The Absolute Path Rule (Critical)
**Problem**: Cockpit's system bridge (`cockpit.spawn` and `cockpit.file`) does not always execute from the addon's installation directory. Relative paths (`./`) are unreliable and will cause "No such file" errors.
**The Fix**: ALWAYS perform a one-time absolute-path discovery at launch.
- Use a robust `find` or `realpath` script to identify the addon's root.
- Use these discovered absolute paths for all subsequent file reads, script executions, and directory listings.

## 2. Transition from Iframes to Native JSON
**Problem**: Iframes introduce scrollbar issues, styling-mismatches, and complex cross-origin security hurdles.
**The Fix**: Natively parse JSON data within `index.js` and render it using PatternFly 5 components.
- **Why**: Faster performance, perfect dark-mode integration, and native responsiveness.
- **How**: Use `pf-v5-c-card` and `pf-v5-l-gallery` grids to match the standard Cockpit "Overview" look.

## 3. CSP-Resilient Architecture
**Problem**: Cockpit's strict Security Policy often blocks inline styles and scripts.
**The Fix**: Use external `.js` and `.css` files rather than inlining everything into `index.html`.
- Ensure standard MIME types are served.
- Link to base Cockpit assets (`../base1/cockpit.js`) first.

## 4. Self-Contained Portability
**Problem**: Storing data in global folders (like `/var/lib/cockpit`) introduces "Unexpected Internal Error" crashes and permission conflicts.
**The Fix**: Store all addon-specific data (reports, logs, temporary files) in a local `reports/` directory within the addon's own folder.
- **Benefit**: Zero-permission setup, easy cleanup, and portability across different user accounts.

## 5. The "Oops!" Stability Shield
**Problem**: Concurrent initialization or rapid-fire bridge requests can overwhelm the Cockpit protocol, triggering the "Ooops!" error.
**The Fix**: Implement an initialization guard.
- Only run the setup logic (`discoverPaths`, `init UI`) once.
- Use `cockpit.transport.wait(init)` to ensure the bridge is ready before communicating.
- Wrap all rendering code in `try-catch` blocks to prevent silent JavaScript crashes from freezing the bridge.

## 6. Functional Minimalism
**Best Practice**: Use standard native browser elements (like `<select>` dropdowns for history) instead of complex custom modals or sidebars.
- **Why**: "Less code possible" results in higher stability and faster load times.
- **Look**: Native Cockpit modules value data readability and grid-based overview layouts over decorative sidebars.

---
**Status**: v2-RC Stable
**Architecture**: Native PatternFly 5 Dashboard
**Stability Rating**: High
