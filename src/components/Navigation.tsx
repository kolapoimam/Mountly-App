import { useState } from 'react';
import { HardDrive, Download, Menu, X } from 'lucide-react';
import type { ThemeMode } from '../types';

interface NavigationProps {
  theme?: ThemeMode;
  onToggleTheme?: () => void;
  onOpenDownload: () => void;
  onOpenDonate?: () => void;
}

export function Navigation({
  theme = 'dark',
  onOpenDownload,
}: NavigationProps) {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <div className="fixed top-4 sm:top-5 left-0 right-0 z-50 flex justify-center px-4 pointer-events-none">
      <div className="relative w-full max-w-3xl pointer-events-auto">
        <header
          id="main-navigation"
          className={`flex items-center justify-between gap-3 sm:gap-6 px-3.5 sm:px-5 py-2 sm:py-2.5 rounded-full border backdrop-blur-2xl transition-all duration-200 shadow-xl ${
            theme === 'light'
              ? 'bg-white/85 border-stone-200/90 shadow-stone-900/5 ring-1 ring-black/[0.04] text-stone-800'
              : 'bg-stone-900/80 border-stone-700/60 shadow-black/40 ring-1 ring-white/10 text-stone-200'
          }`}
        >
          {/* Brand */}
          <a
            href="#"
            id="nav-brand-link"
            className="flex items-center gap-2 group focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 rounded-full py-0.5 pr-2"
          >
            <div
              className={`flex h-7 w-7 sm:h-8 sm:w-8 items-center justify-center rounded-full border transition-all ${
                theme === 'light'
                  ? 'bg-blue-50 border-blue-200/80 text-blue-600 group-hover:bg-blue-100'
                  : 'bg-blue-950/60 border-blue-800/60 text-blue-400 group-hover:border-blue-500/50'
              }`}
            >
              <HardDrive className="h-3.5 w-3.5 sm:h-4 sm:w-4" aria-hidden="true" />
            </div>
            <span
              className={`font-bold text-sm sm:text-base tracking-tight transition-colors ${
                theme === 'light' ? 'text-stone-900' : 'text-white'
              }`}
            >
              Mountly
            </span>
          </a>

          {/* Desktop Links - Only Features, Compatibility, FAQ */}
          <nav className="hidden md:flex items-center gap-1 text-xs font-medium">
            <a
              href="#features"
              id="nav-link-features"
              className={`px-3.5 py-1.5 rounded-full transition-all ${
                theme === 'light'
                  ? 'text-stone-600 hover:text-stone-950 hover:bg-stone-100'
                  : 'text-stone-300 hover:text-white hover:bg-stone-800/80'
              }`}
            >
              Features
            </a>
            <a
              href="#compatibility"
              id="nav-link-compatibility"
              className={`px-3.5 py-1.5 rounded-full transition-all ${
                theme === 'light'
                  ? 'text-stone-600 hover:text-stone-950 hover:bg-stone-100'
                  : 'text-stone-300 hover:text-white hover:bg-stone-800/80'
              }`}
            >
              Compatibility
            </a>
            <a
              href="#faq"
              id="nav-link-faq"
              className={`px-3.5 py-1.5 rounded-full transition-all ${
                theme === 'light'
                  ? 'text-stone-600 hover:text-stone-950 hover:bg-stone-100'
                  : 'text-stone-300 hover:text-white hover:bg-stone-800/80'
              }`}
            >
              FAQ
            </a>
          </nav>

          {/* Right Actions */}
          <div className="flex items-center gap-2">
            <a
              id="nav-download-button"
              href="https://drive.google.com/drive/folders/10siVhoTd4-5X_bA3s5Ns0AYtGD87D95s?usp=sharing"
              target="_blank"
              rel="noopener noreferrer"
              aria-label="Download Mountly"
              title="Download Mountly"
              className="inline-flex items-center justify-center gap-1.5 h-7 sm:h-8 px-2.5 sm:px-4 rounded-full text-xs font-semibold bg-blue-600 hover:bg-blue-500 text-white shadow-sm transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-400 active:scale-[0.98]"
            >
              <Download className="h-3.5 w-3.5" aria-hidden="true" />
              <span className="hidden sm:inline">Download</span>
            </a>

            {/* Mobile menu toggle */}
            <button
              type="button"
              id="mobile-menu-toggle"
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              aria-expanded={mobileMenuOpen}
              aria-label="Toggle navigation menu"
              className={`md:hidden flex h-7 w-7 sm:h-8 sm:w-8 items-center justify-center rounded-full border transition-colors ${
                theme === 'light'
                  ? 'border-stone-200 bg-stone-100 text-stone-700 hover:bg-stone-200'
                  : 'border-stone-700 bg-stone-800 text-stone-200 hover:bg-stone-700'
              }`}
            >
              {mobileMenuOpen ? <X className="h-3.5 w-3.5" /> : <Menu className="h-3.5 w-3.5" />}
            </button>
          </div>
        </header>

        {/* Mobile Drawer (Floating Glass Card) */}
        {mobileMenuOpen && (
          <div
            id="mobile-nav-panel"
            className={`md:hidden mt-2 p-4 rounded-2xl border backdrop-blur-2xl shadow-2xl space-y-3 transition-all animate-in fade-in slide-in-from-top-2 duration-150 ${
              theme === 'light'
                ? 'bg-white/95 border-stone-200/90 text-stone-800 shadow-stone-900/10'
                : 'bg-stone-900/95 border-stone-700/80 text-stone-200 shadow-black/50'
            }`}
          >
            <nav className="flex flex-col space-y-1 text-sm font-medium">
              <a
                href="#features"
                onClick={() => setMobileMenuOpen(false)}
                className={`px-3 py-2 rounded-lg transition-colors ${
                  theme === 'light' ? 'hover:bg-stone-100 text-stone-800' : 'hover:bg-stone-800 text-stone-200'
                }`}
              >
                Features
              </a>
              <a
                href="#compatibility"
                onClick={() => setMobileMenuOpen(false)}
                className={`px-3 py-2 rounded-lg transition-colors ${
                  theme === 'light' ? 'hover:bg-stone-100 text-stone-800' : 'hover:bg-stone-800 text-stone-200'
                }`}
              >
                Compatibility
              </a>
              <a
                href="#faq"
                onClick={() => setMobileMenuOpen(false)}
                className={`px-3 py-2 rounded-lg transition-colors ${
                  theme === 'light' ? 'hover:bg-stone-100 text-stone-800' : 'hover:bg-stone-800 text-stone-200'
                }`}
              >
                FAQ
              </a>
            </nav>
            <div className="pt-2 border-t border-stone-200 dark:border-stone-800">
              <a
                href="https://drive.google.com/drive/folders/10siVhoTd4-5X_bA3s5Ns0AYtGD87D95s?usp=sharing"
                target="_blank"
                rel="noopener noreferrer"
                onClick={() => setMobileMenuOpen(false)}
                className="w-full py-2.5 px-4 text-xs font-semibold rounded-xl bg-blue-600 hover:bg-blue-500 text-white flex items-center justify-center gap-2 shadow-sm transition-all"
              >
                <Download className="h-3.5 w-3.5" />
                <span>Download Mountly</span>
              </a>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
