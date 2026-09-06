import { HardDrive } from 'lucide-react';

interface FooterProps {
  onOpenDownload?: () => void;
  onOpenPrivacy: () => void;
}

export function Footer({
  onOpenPrivacy,
}: FooterProps) {
  const downloadUrl = 'https://drive.google.com/drive/folders/10siVhoTd4-5X_bA3s5Ns0AYtGD87D95s?usp=sharing';

  return (
    <footer id="site-footer" className="border-t border-stone-800/80 bg-stone-950 text-stone-400 py-12">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8 space-y-6">
        {/* Top: Brand and Links without divider line */}
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
          {/* Brand */}
          <div className="space-y-1.5">
            <div className="flex items-center gap-2">
              <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-stone-900 border border-stone-800 text-blue-400">
                <HardDrive className="h-3.5 w-3.5" aria-hidden="true" />
              </div>
              <span className="font-bold text-white tracking-tight text-base">
                Mountly
              </span>
            </div>
            <p className="text-xs text-stone-400">
              External drives, made accessible.
            </p>
          </div>

          {/* Nav links */}
          <nav className="flex flex-wrap items-center gap-6 text-xs font-medium text-stone-400">
            <a
              href={downloadUrl}
              target="_blank"
              rel="noopener noreferrer"
              id="footer-download-btn"
              className="hover:text-stone-200 transition-colors"
            >
              Download
            </a>
            <a
              href="https://github.com/kolapoimam/mountly"
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-stone-200 transition-colors"
            >
              GitHub
            </a>
            <button
              type="button"
              id="footer-privacy-btn"
              onClick={onOpenPrivacy}
              className="hover:text-stone-200 transition-colors cursor-pointer"
            >
              Privacy Policy
            </button>
          </nav>
        </div>

        {/* Connected footer attribution with NO divider line */}
        <div className="flex flex-wrap items-center gap-x-3 gap-y-1 text-xs text-stone-500">
          <span>
            Built by{' '}
            <a
              href="https://kolapo.ng"
              target="_blank"
              rel="noopener noreferrer"
              className="font-medium text-stone-300 hover:text-white underline underline-offset-4 decoration-stone-700 hover:decoration-blue-400 transition-colors"
            >
              Kolapo Imam
            </a>
          </span>
          <span className="text-stone-700">·</span>
          <span>© 2026 Mountly. Independent macOS Utility.</span>
        </div>
      </div>
    </footer>
  );
}
