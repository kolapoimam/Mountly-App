// Single source of truth for page metadata and structured data.
// Used at build time (scripts/prerender.mjs) to write each page's <head>,
// and at runtime by App.tsx to keep document.title in sync.

import { FAQS } from './components/FAQ';
import { PRIVACY_FAQS } from './components/PrivacyPolicyPage';
import { AUTHOR_URL, DOWNLOAD_URL } from './components/Brand';

export const SITE_URL = 'https://mountlyapp.vercel.app';
export const SITE_NAME = 'Mountly';
const OG_IMAGE = `${SITE_URL}/og-image.png`;
const OG_ALT =
  'Mountly for Mac: free NTFS read and write for external drives, with NTFS, exFAT, APFS, FAT32, HFS+ and EXT4 support.';
const UPDATED = '2026-11-15';

const KEYWORDS = [
  'Mountly',
  'NTFS for Mac',
  'free NTFS for Mac',
  'NTFS write Mac',
  'write to NTFS drive on Mac',
  'NTFS read write macOS',
  'mount NTFS drive Mac',
  'NTFS macOS Sequoia',
  'NTFS macOS Sonoma',
  'NTFS macOS Ventura',
  'NTFS Apple Silicon',
  'NTFS M1 M2 M3 M4',
  'Paragon NTFS alternative',
  'Tuxera NTFS alternative',
  'free Paragon NTFS alternative',
  'external drive read only Mac',
  'external hard drive not writable Mac',
  'Windows drive on Mac',
  'mount external drive macOS',
  'exFAT Mac',
  'EXT4 on Mac',
  'read Linux drive on Mac',
  'HFS+ APFS FAT32',
  'macOS disk utility',
  'open source macOS utility',
  'no kernel extension NTFS',
  'Kolapo Imam',
].join(', ');

export type Route = '/' | '/privacy';

export interface PageMeta {
  path: Route;
  title: string;
  description: string;
  ogTitle: string;
}

export const PAGES: Record<Route, PageMeta> = {
  '/': {
    path: '/',
    title: 'Mountly — Free NTFS for Mac: Read & Write External Drives',
    description:
      'Free, open-source macOS app to read and write NTFS drives on Mac. Mount NTFS, exFAT, APFS, FAT32, HFS+ and EXT4 without kernel extensions or reformatting.',
    ogTitle: 'Mountly — External drives, made accessible.',
  },
  '/privacy': {
    path: '/privacy',
    title: 'Privacy Policy · Mountly — Zero-Telemetry macOS Drive Utility',
    description:
      'The Mountly app runs 100% offline. No telemetry, no analytics, no file scanning. Read how the free macOS NTFS utility handles your drives and data.',
    ogTitle: 'Mountly Privacy Policy — 100% offline, zero telemetry',
  },
};

export function routeFor(pathname: string): Route {
  return pathname.replace(/\/+$/, '') === '/privacy' ? '/privacy' : '/';
}

const esc = (s: string) =>
  s.replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

const person = {
  '@type': 'Person',
  '@id': `${SITE_URL}/#author`,
  name: 'Kolapo Imam',
  url: AUTHOR_URL,
  sameAs: [AUTHOR_URL, 'https://github.com/kolapoimam'],
  jobTitle: 'Product Manager and Software Builder',
};

const website = {
  '@type': 'WebSite',
  '@id': `${SITE_URL}/#website`,
  url: `${SITE_URL}/`,
  name: SITE_NAME,
  alternateName: ['Mountly for Mac', 'Mountly NTFS'],
  description: 'External drives, made accessible. A free macOS utility for mounting NTFS and other external filesystems.',
  inLanguage: 'en',
  publisher: { '@id': `${SITE_URL}/#author` },
};

const software = {
  '@type': 'SoftwareApplication',
  '@id': `${SITE_URL}/#software`,
  name: SITE_NAME,
  alternateName: ['Mountly for Mac', 'Mountly NTFS for Mac'],
  url: `${SITE_URL}/`,
  description:
    "Mountly is a free, open-source native macOS utility that detects, mounts and manages external drives, adding full NTFS read and write support plus EXT4 read support, while respecting the filesystems macOS already handles natively (exFAT, APFS, FAT32, HFS+).",
  applicationCategory: 'UtilitiesApplication',
  applicationSubCategory: 'Disk management',
  operatingSystem: 'macOS 13 Ventura or later (Sonoma, Sequoia)',
  softwareRequirements: 'macOS 13.0 or later',
  processorRequirements: 'Apple Silicon (M1, M2, M3, M4) or Intel 64-bit (Universal Binary)',
  isAccessibleForFree: true,
  offers: {
    '@type': 'Offer',
    price: '0',
    priceCurrency: 'USD',
    availability: 'https://schema.org/InStock',
    url: DOWNLOAD_URL,
  },
  downloadUrl: DOWNLOAD_URL,
  installUrl: DOWNLOAD_URL,
  image: OG_IMAGE,
  screenshot: OG_IMAGE,
  featureList: [
    'NTFS read and write on macOS without terminal commands or reformatting',
    'No kernel extension required',
    'Finder integration for mounted volumes',
    'Safe mounting and safe eject that keep partition journals intact',
    'EXT4 (Linux) read-only support',
    'Works alongside native exFAT, APFS, FAT32 and HFS+ support',
    'Any external enclosure: USB-C, USB-A, portable SSDs, mechanical HDDs and flash media',
    'Universal Binary for Apple Silicon and Intel Macs',
    'Runs 100% offline with zero telemetry',
  ],
  keywords: KEYWORDS,
  inLanguage: 'en',
  author: { '@id': `${SITE_URL}/#author` },
  publisher: { '@id': `${SITE_URL}/#author` },
};

function faqPage(id: string, items: { q: string; a: string }[]) {
  return {
    '@type': 'FAQPage',
    '@id': id,
    mainEntity: items.map((f) => ({
      '@type': 'Question',
      name: f.q,
      acceptedAnswer: { '@type': 'Answer', text: f.a },
    })),
  };
}

function structuredData(route: Route) {
  const meta = PAGES[route];
  const url = `${SITE_URL}${route === '/' ? '/' : route}`;
  const webpage = {
    '@type': route === '/' ? 'WebPage' : ['WebPage', 'AboutPage'],
    '@id': `${url}#webpage`,
    url,
    name: meta.title,
    description: meta.description,
    isPartOf: { '@id': `${SITE_URL}/#website` },
    about: { '@id': `${SITE_URL}/#software` },
    primaryImageOfPage: { '@type': 'ImageObject', url: OG_IMAGE, width: 1200, height: 630 },
    inLanguage: 'en',
    dateModified: UPDATED,
    breadcrumb: { '@id': `${url}#breadcrumb` },
  };
  const crumbs = [{ name: 'Mountly', item: `${SITE_URL}/` }];
  if (route === '/privacy') crumbs.push({ name: 'Privacy Policy', item: url });
  const breadcrumb = {
    '@type': 'BreadcrumbList',
    '@id': `${url}#breadcrumb`,
    itemListElement: crumbs.map((c, i) => ({ '@type': 'ListItem', position: i + 1, ...c })),
  };
  const graph: object[] = [website, person, software, webpage, breadcrumb];
  graph.push(
    route === '/' ? faqPage(`${url}#faq`, FAQS) : faqPage(`${url}#privacy-faq`, PRIVACY_FAQS)
  );
  // Escape "<" so the JSON can never close the script tag early
  return JSON.stringify({ '@context': 'https://schema.org', '@graph': graph }).replace(/</g, '\\u003c');
}

/** Everything that differs per page inside <head>. */
export function buildHead(pathname: string): string {
  const route = routeFor(pathname);
  const meta = PAGES[route];
  const url = `${SITE_URL}${route === '/' ? '/' : route}`;
  return [
    `<title>${esc(meta.title)}</title>`,
    `<meta name="description" content="${esc(meta.description)}" />`,
    `<meta name="keywords" content="${esc(KEYWORDS)}" />`,
    `<meta name="author" content="Kolapo Imam" />`,
    `<meta name="robots" content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1" />`,
    `<link rel="canonical" href="${url}" />`,
    `<link rel="alternate" hreflang="en" href="${url}" />`,
    `<link rel="alternate" hreflang="x-default" href="${url}" />`,
    `<meta property="og:type" content="website" />`,
    `<meta property="og:site_name" content="${SITE_NAME}" />`,
    `<meta property="og:locale" content="en_US" />`,
    `<meta property="og:url" content="${url}" />`,
    `<meta property="og:title" content="${esc(meta.ogTitle)}" />`,
    `<meta property="og:description" content="${esc(meta.description)}" />`,
    `<meta property="og:image" content="${OG_IMAGE}" />`,
    `<meta property="og:image:secure_url" content="${OG_IMAGE}" />`,
    `<meta property="og:image:type" content="image/png" />`,
    `<meta property="og:image:width" content="1200" />`,
    `<meta property="og:image:height" content="630" />`,
    `<meta property="og:image:alt" content="${esc(OG_ALT)}" />`,
    `<meta property="og:updated_time" content="${UPDATED}T00:00:00Z" />`,
    `<meta name="twitter:card" content="summary_large_image" />`,
    `<meta name="twitter:site" content="@kolapoimam" />`,
    `<meta name="twitter:creator" content="@kolapoimam" />`,
    `<meta name="twitter:title" content="${esc(meta.ogTitle)}" />`,
    `<meta name="twitter:description" content="${esc(meta.description)}" />`,
    `<meta name="twitter:image" content="${OG_IMAGE}" />`,
    `<meta name="twitter:image:alt" content="${esc(OG_ALT)}" />`,
    `<script type="application/ld+json">${structuredData(route)}</script>`,
  ].join('\n    ');
}

