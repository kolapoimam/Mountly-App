import { useState } from 'react';
import { Download, Menu, X } from 'lucide-react';
import { DOWNLOAD_URL, Wordmark } from './Brand';

const LINKS = [
  { href: '#features', label: 'Features' },
  { href: '#compatibility', label: 'Compatibility' },
  { href: '#faq', label: 'FAQ' },
];

export function Navigation() {
  const [open, setOpen] = useState(false);

  return (
    <header
      id="main-navigation"
      className="sticky top-0 z-50 border-b border-line/80 bg-cream/85 backdrop-blur-xl"
    >
      <div className="mx-auto flex h-[76px] max-w-6xl items-center justify-between gap-4 px-5 sm:px-6">
        <a
          href="#top"
          id="nav-brand-link"
          aria-label="Mountly home"
          className="rounded-xl focus:outline-none focus-visible:ring-2 focus-visible:ring-cobalt focus-visible:ring-offset-4 focus-visible:ring-offset-cream"
        >
          <Wordmark />
        </a>

        {/* Links grouped inside one pill */}
        <nav
          aria-label="Main"
          className="absolute left-1/2 hidden -translate-x-1/2 items-center gap-1 rounded-full border border-line bg-white p-1.5 shadow-[0_1px_0_rgba(27,26,23,0.04),0_8px_24px_-12px_rgba(27,26,23,0.18)] md:flex"
        >
          {LINKS.map((link) => (
            <a
              key={link.href}
              href={link.href}
              id={`nav-link-${link.label.toLowerCase()}`}
              className="rounded-full px-4 py-2 text-[15px] font-medium text-[#3f3b34] hover:bg-cream-2 hover:text-ink focus:outline-none focus-visible:ring-2 focus-visible:ring-cobalt"
            >
              {link.label}
            </a>
          ))}
        </nav>

        <div className="flex items-center gap-2">
          <a
            id="nav-download-button"
            href={DOWNLOAD_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex min-h-11 items-center gap-2 rounded-full bg-ink px-5 text-[15px] font-semibold text-white hover:bg-black focus:outline-none focus-visible:ring-2 focus-visible:ring-cobalt focus-visible:ring-offset-2 focus-visible:ring-offset-cream"
          >
            <Download className="h-4 w-4" strokeWidth={2.2} aria-hidden="true" />
            <span>Download</span>
          </a>

          <button
            type="button"
            id="mobile-menu-toggle"
            onClick={() => setOpen((v) => !v)}
            aria-expanded={open}
            aria-controls="mobile-nav-panel"
            aria-label={open ? 'Close menu' : 'Open menu'}
            className="flex h-11 w-11 items-center justify-center rounded-full border border-line bg-white text-ink hover:bg-cream-2 md:hidden"
          >
            {open ? <X className="h-4 w-4" /> : <Menu className="h-4 w-4" />}
          </button>
        </div>
      </div>

      {open && (
        <div id="mobile-nav-panel" className="fade-in px-5 pb-4 md:hidden">
          <nav
            aria-label="Mobile"
            className="flex flex-col gap-1 rounded-3xl border border-line bg-white p-2 shadow-[0_12px_32px_-16px_rgba(27,26,23,0.25)]"
          >
            {LINKS.map((link) => (
              <a
                key={link.href}
                href={link.href}
                onClick={() => setOpen(false)}
                className="rounded-2xl px-4 py-3 text-base font-medium text-ink hover:bg-cream-2"
              >
                {link.label}
              </a>
            ))}
          </nav>
        </div>
      )}
    </header>
  );
}
