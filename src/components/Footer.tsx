import { AUTHOR_URL, DOWNLOAD_URL, GITHUB_URL, Wordmark } from './Brand';

interface FooterProps {
  onOpenPrivacy: () => void;
}

export function Footer({ onOpenPrivacy }: FooterProps) {
  return (
    <footer id="site-footer" className="px-5 pb-12 sm:px-6">
      <div className="mx-auto flex max-w-6xl flex-col items-center justify-between gap-8 border-t border-line pt-10 text-center md:flex-row md:items-start md:text-left">
        <div className="flex flex-col items-center md:items-start">
          <Wordmark size="sm" />
          <p className="mt-2.5 text-sm text-muted">External drives, made accessible.</p>
        </div>
        <nav aria-label="Footer" className="flex flex-wrap items-center justify-center gap-7 text-sm">
          <a
            id="footer-download-btn"
            href={DOWNLOAD_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="text-muted hover:text-ink"
          >
            Download
          </a>
          <a href={GITHUB_URL} target="_blank" rel="noopener noreferrer" className="text-muted hover:text-ink">
            GitHub
          </a>
          <a
            id="footer-privacy-btn"
            href="/privacy"
            onClick={(e) => {
              e.preventDefault();
              onOpenPrivacy();
            }}
            className="text-muted hover:text-ink"
          >
            Privacy Policy
          </a>
        </nav>
      </div>
      <div className="mx-auto mt-7 flex max-w-6xl flex-wrap items-center justify-center gap-x-3 gap-y-1 text-[13px] text-subtle md:justify-between">
        <span>
          Built by{' '}
          <a
            href={AUTHOR_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="font-semibold text-ink underline decoration-line-2 underline-offset-[3px] hover:decoration-cobalt"
          >
            Kolapo Imam
          </a>
        </span>
        <span>© 2026 Mountly. Independent macOS Utility.</span>
      </div>
    </footer>
  );
}
