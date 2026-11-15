# Mountly website analytics

Google Tag Manager `GTM-T4Q54G4N` loads on every page and sends to GA4 `G-5KK4VQLT6X`.

## What GA4 gets automatically (enhanced measurement in the container)

Page views (including moving between Home and Privacy), 90% scroll, outbound clicks, file downloads, form and video events.

## Custom events (src/analytics.ts)

All events go to the `dataLayer` with the same parameters, so one GA4 Event tag forwards them all.

| Event | When it fires | Useful parameters |
| --- | --- | --- |
| `download_click` | Any Download Mountly link (nav, hero, CTA, footer, privacy page) | `ui_section`, `link_url` |
| `donate_click` | Any Donate link | `ui_section` |
| `github_click` | GitHub links | `ui_section`, `link_url` |
| `author_click` | kolapo.ng links | `ui_section` |
| `nav_click` | Menu links, Privacy Policy, Back to Home | `ui_section`, `link_text`, `item_name` |
| `outbound_link_click` | Any other external link | `link_url`, `link_domain` |
| `menu_toggle` | Mobile menu opened or closed | `item_state` |
| `faq_toggle` | FAQ question opened or closed (home and privacy) | `item_name` (question), `item_state`, `ui_section` |
| `preview_interaction` | App preview: select drive, eject, mount, open in Finder, rescan | `action`, `item_name` (drive) |
| `button_click` | Any other button | `ui_section`, `link_text` |
| `section_view` | Hero, Features, Compatibility, FAQ, Download seen on screen | `ui_section` |
| `scroll_depth` | 25, 50, 75, 100% of the page | `percent` |
| `text_copy` | Visitor copies text | `item_name` (text), `ui_section` |
| `web_vitals` | LCP, CLS, INP, FCP, TTFB | `item_name` (metric), `value` (ms, CLS × 1000), `metric_rating` |
| `js_error` | Uncaught JavaScript errors | `item_name` (message) |

Every event also carries `page_type` (`home` or `privacy`).

## One-time GTM setup

The page already sends these events. GA4 records them once GTM has a tag that forwards them.

1. In Tag Manager open the container, then Admin › Import Container.
2. Choose `gtm-mountly-events.json`, pick your workspace, and choose **Merge** with **Rename conflicting tags, triggers and variables**.
3. Check the preview, then Submit › Publish.

This adds one GA4 Event tag (`{{Event}}` as the name, sent to `G-5KK4VQLT6X`), one Custom Event trigger matching the events above, and 12 Data Layer Variables.

## In GA4

- Admin › Events: mark `download_click` and `donate_click` as key events.
- Admin › Custom definitions: add event-scoped dimensions for `ui_section`, `item_name`, `item_state`, `action`, `metric_rating`, `page_type`, and a metric for `percent`, so they show in reports.
