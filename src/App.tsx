import { useState, useEffect } from 'react';
import type { ThemeMode } from './types';
import { Navigation } from './components/Navigation';
import { Hero } from './components/Hero';
import { FeatureGrid } from './components/FeatureGrid';
import { CompatibilitySection } from './components/CompatibilitySection';
import { FAQ } from './components/FAQ';
import { Footer } from './components/Footer';
import { PrivacyPolicyPage } from './components/PrivacyPolicyPage';
import { DownloadModal } from './components/DownloadModal';
import { DonateModal } from './components/DonateModal';

export default function App() {
  const [theme, setTheme] = useState<ThemeMode>('dark');
  const [currentView, setCurrentView] = useState<'home' | 'privacy'>('home');
  const [isDownloadOpen, setIsDownloadOpen] = useState(false);
  const [isDonateOpen, setIsDonateOpen] = useState(false);

  // Sync theme class to document root and body (defaulted to dark mode)
  useEffect(() => {
    const root = document.documentElement;
    if (theme === 'light') {
      root.classList.remove('dark');
      root.classList.add('light');
      document.body.classList.remove('bg-stone-950', 'text-stone-100');
      document.body.classList.add('bg-[#fafaf9]', 'text-stone-900');
    } else {
      root.classList.remove('light');
      root.classList.add('dark');
      document.body.classList.remove('bg-[#fafaf9]', 'text-stone-900');
      document.body.classList.add('bg-stone-950', 'text-stone-100');
    }
  }, [theme]);

  // Support URL path and hash routing (/privacy and #privacy) for Vercel and local SPA
  useEffect(() => {
    const handleRoute = () => {
      const path = window.location.pathname.replace(/\/+$/, '');
      const hash = window.location.hash;
      if (path === '/privacy' || hash === '#privacy') {
        setCurrentView('privacy');
        window.scrollTo({ top: 0, behavior: 'instant' });
      } else {
        setCurrentView('home');
      }
    };

    handleRoute();
    window.addEventListener('popstate', handleRoute);
    window.addEventListener('hashchange', handleRoute);
    return () => {
      window.removeEventListener('popstate', handleRoute);
      window.removeEventListener('hashchange', handleRoute);
    };
  }, []);

  const toggleTheme = () => {
    setTheme((prev) => (prev === 'dark' ? 'light' : 'dark'));
  };

  const handleOpenPrivacy = () => {
    setCurrentView('privacy');
    try {
      window.history.pushState({ page: 'privacy' }, '', '/privacy');
    } catch {
      window.location.hash = '#privacy';
    }
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleBackToHome = () => {
    setCurrentView('home');
    try {
      window.history.pushState({ page: 'home' }, '', '/');
    } catch {
      window.location.hash = '';
    }
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  if (currentView === 'privacy') {
    return (
      <div id="mountly-app-root" className="theme-dark dark min-h-screen bg-stone-950 text-stone-100">
        <PrivacyPolicyPage onBackToHome={handleBackToHome} />
      </div>
    );
  }

  return (
    <div
      id="mountly-app-root"
      className="theme-dark dark min-h-screen bg-stone-950 text-stone-100 transition-colors duration-200"
    >
      {/* Floating Pill Header Navigation */}
      <Navigation
        theme={theme}
        onToggleTheme={toggleTheme}
        onOpenDownload={() => setIsDownloadOpen(true)}
      />

      {/* Main Content: Max 4 Focused Sections */}
      <main className="pt-20 sm:pt-24 md:pt-28">
        {/* Section 1: Hero with Interactive Product Window Preview */}
        <Hero
          onOpenDownload={() => setIsDownloadOpen(true)}
          onOpenDonate={() => setIsDonateOpen(true)}
        />

        {/* Section 2: Features */}
        <FeatureGrid />

        {/* Section 3: Compatibility */}
        <CompatibilitySection />

        {/* Section 4: FAQ & Download */}
        <FAQ
          onOpenDownload={() => setIsDownloadOpen(true)}
          onOpenDonate={() => setIsDonateOpen(true)}
        />
      </main>

      {/* Clean Minimalist Footer */}
      <Footer
        onOpenDownload={() => setIsDownloadOpen(true)}
        onOpenPrivacy={handleOpenPrivacy}
      />

      {/* Action Modals */}
      <DownloadModal
        isOpen={isDownloadOpen}
        onClose={() => setIsDownloadOpen(false)}
      />

      <DonateModal
        isOpen={isDonateOpen}
        onClose={() => setIsDonateOpen(false)}
      />
    </div>
  );
}
