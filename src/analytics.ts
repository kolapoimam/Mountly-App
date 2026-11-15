// Site analytics for Mountly.
//
// Google Tag Manager (GTM-T4Q54G4N) loads from index.html and already sends
// GA4 page views (including /privacy navigation), scroll, outbound clicks and
// file downloads through enhanced measurement.
//
// This module adds named events on top of that by pushing to the dataLayer.
// Every event uses the same flat parameter set so one GA4 Event tag in GTM can
// forward all of them (see analytics/gtm-mountly-events.json).
//
// It listens at the document level, so no component needs tracking code.

import { onCLS, onFCP, onINP, onLCP, onTTFB } from 'web-vitals';

type Params = Partial<{
  ui_section: string;
  ui_element: string;
  link_text: string;
  link_url: string;
  link_domain: string;
  item_name: string;
  item_state: string;
  action: string;
  percent: number;
  value: number;
  metric_rating: string;
  page_type: string;
}>;

export const TRACKED_EVENTS = [
  'download_click',
  'donate_click',
  'github_click',
  'author_click',
  'nav_click',
  'outbound_link_click',
  'button_click',
  'menu_toggle',
  'faq_toggle',
  'preview_interaction',
  'section_view',
  'scroll_depth',
  'text_copy',
  'web_vitals',
  'js_error',
] as const;

type EventName = (typeof TRACKED_EVENTS)[number];

declare global {
  interface Window {
    dataLayer: unknown[];
  }
}

const clean = (s: string | null | undefined, max = 100) =>
  (s ?? '').replace(/\s+/g, ' ').trim().slice(0, max);

function pageType() {
  return window.location.pathname.replace(/\/+$/, '') === '/privacy' ? 'privacy' : 'home';
}

export function track(event: EventName, params: Params = {}) {
  if (typeof window === 'undefined') return;
  window.dataLayer = window.dataLayer || [];
  // Clear the previous event's parameters so they never leak into this one
  const reset: Record<string, undefined> = {
    ui_section: undefined, ui_element: undefined, link_text: undefined, link_url: undefined,
    link_domain: undefined, item_name: undefined, item_state: undefined, action: undefined,
    percent: undefined, value: undefined, metric_rating: undefined,
  };
  window.dataLayer.push({ ...reset, event, page_type: pageType(), ...params });
}

/** Which part of the page an element sits in, e.g. "hero", "faq", "footer". */
function sectionOf(el: Element): string {
  if (el.closest('#product-preview-window')) return 'app_preview';
  if (el.closest('#mobile-nav-panel')) return 'mobile_menu';
  if (el.closest('header')) return pageType() === 'privacy' ? 'privacy_header' : 'header';
  if (el.closest('footer')) return 'footer';
  const host = el.closest('section, main, aside');
  if (!host) return pageType();
  const id = host.id || host.closest('section[id]')?.id;
  if (id === 'top') return 'hero';
  if (id) return id;
  return pageType() === 'privacy' ? 'privacy_body' : 'body';
}

function labelOf(el: Element) {
  return clean(el.getAttribute('aria-label') || (el as HTMLElement).innerText || el.textContent);
}

function onClick(e: MouseEvent) {
  const target = e.target as Element | null;
  if (!target) return;

  const link = target.closest('a[href]') as HTMLAnchorElement | null;
  if (link) {
    const url = new URL(link.href, window.location.href);
    const params: Params = {
      ui_section: sectionOf(link),
      ui_element: link.id || undefined,
      link_text: labelOf(link),
      link_url: url.href.slice(0, 300),
      link_domain: url.hostname,
    };
    const external = url.origin !== window.location.origin;
    if (url.hostname === 'drive.google.com') return track('download_click', params);
    if (url.hostname.endsWith('paystack.shop')) return track('donate_click', params);
    if (url.hostname === 'github.com') return track('github_click', params);
    if (url.hostname === 'kolapo.ng') return track('author_click', params);
    if (external) return track('outbound_link_click', params);
    return track('nav_click', { ...params, item_name: url.hash || url.pathname });
  }

  const button = target.closest('button') as HTMLButtonElement | null;
  if (!button || button.disabled) return;
  const section = sectionOf(button);
  const label = labelOf(button);

  // React updates state after this handler, so read the result on the next tick
  window.setTimeout(() => {
    if (button.id === 'mobile-menu-toggle') {
      return track('menu_toggle', {
        ui_section: 'header',
        item_state: button.getAttribute('aria-expanded') === 'true' ? 'open' : 'closed',
      });
    }

    if (button.hasAttribute('aria-controls') && button.closest('#faq, main')) {
      const question = clean(button.textContent, 150);
      return track('faq_toggle', {
        ui_section: section === 'privacy_body' ? 'privacy_faq' : section,
        item_name: question,
        item_state: button.getAttribute('aria-expanded') === 'true' ? 'open' : 'closed',
      });
    }

    if (section === 'app_preview') {
      const drive = clean(
        document.querySelector('#product-preview-window h3')?.textContent ?? '',
        60
      );
      let action = 'other';
      if (button.hasAttribute('aria-pressed')) action = 'select_drive';
      else if (button.id === 'preview-toggle-eject') action = /mount/i.test(label) && !/eject/i.test(label) ? 'mount' : 'eject';
      else if (button.id === 'preview-open-finder') action = 'open_in_finder';
      else if (/rescan/i.test(label)) action = 'rescan';
      return track('preview_interaction', {
        ui_section: section,
        ui_element: button.id || undefined,
        action,
        item_name: drive,
        link_text: label,
      });
    }

    track('button_click', { ui_section: section, ui_element: button.id || undefined, link_text: label });
  }, 0);
}

// Each landing section once per page view, when at least 40% is on screen
let sectionObserver: IntersectionObserver | null = null;
function observeSections() {
  sectionObserver?.disconnect();
  if (!('IntersectionObserver' in window)) return;
  const seen = new Set<string>();
  sectionObserver = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        const id = (entry.target as HTMLElement).id;
        if (!entry.isIntersecting || seen.has(id)) continue;
        seen.add(id);
        track('section_view', { ui_section: id === 'top' ? 'hero' : id });
      }
    },
    { threshold: 0.4 }
  );
  document.querySelectorAll('section[id]').forEach((s) => sectionObserver!.observe(s));
}

// 25, 50, 75 and 100% scroll depth, once each per page view
let scrollMarks = new Set<number>();
function onScroll() {
  const doc = document.documentElement;
  const max = doc.scrollHeight - window.innerHeight;
  if (max <= 0) return;
  const pct = (window.scrollY / max) * 100;
  for (const mark of [25, 50, 75, 100]) {
    if (pct >= mark - 1 && !scrollMarks.has(mark)) {
      scrollMarks.add(mark);
      track('scroll_depth', { percent: mark });
    }
  }
}

function onCopy() {
  const selection = window.getSelection();
  const text = clean(selection?.toString(), 100);
  if (!text || !selection?.anchorNode) return;
  const el = selection.anchorNode.nodeType === 1 ? (selection.anchorNode as Element) : selection.anchorNode.parentElement;
  track('text_copy', { ui_section: el ? sectionOf(el) : pageType(), item_name: text, value: text.length });
}

function onError(e: ErrorEvent) {
  track('js_error', {
    item_name: clean(e.message, 150),
    link_url: clean(`${e.filename}:${e.lineno}`, 200),
  });
}

function onRejection(e: PromiseRejectionEvent) {
  track('js_error', { item_name: clean(String(e.reason), 150), action: 'unhandled_rejection' });
}

/** Called on first load and whenever the app switches between home and privacy. */
let lastPath = '';
function onRouteChange() {
  // Jumping to an anchor like #faq is not a new page
  if (window.location.pathname === lastPath) return;
  lastPath = window.location.pathname;
  scrollMarks = new Set();
  // Wait for React to render the new page before looking for sections
  window.setTimeout(observeSections, 50);
}

let started = false;
export function initAnalytics() {
  if (started || typeof window === 'undefined') return;
  started = true;

  document.addEventListener('click', onClick, { capture: true, passive: true });
  document.addEventListener('copy', onCopy);
  window.addEventListener('scroll', onScroll, { passive: true });
  window.addEventListener('error', onError);
  window.addEventListener('unhandledrejection', onRejection);

  // Detect in-app navigation (pushState) and back/forward
  const push = history.pushState.bind(history);
  history.pushState = (...args: Parameters<History['pushState']>) => {
    push(...args);
    onRouteChange();
  };
  window.addEventListener('popstate', onRouteChange);
  onRouteChange();

  const vital = ({ name, value, rating }: { name: string; value: number; rating: string }) =>
    track('web_vitals', {
      item_name: name,
      value: Math.round(name === 'CLS' ? value * 1000 : value),
      metric_rating: rating,
    });
  onLCP(vital);
  onCLS(vital);
  onINP(vital);
  onFCP(vital);
  onTTFB(vital);
}
