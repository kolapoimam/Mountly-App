import { useEffect, useState } from 'react';
import { Navigation } from './components/Navigation';
import { Hero } from './components/Hero';
import { FeatureGrid } from './components/FeatureGrid';
import { CompatibilitySection } from './components/CompatibilitySection';
import { FAQ } from './components/FAQ';
import { DownloadSection } from './components/DownloadSection';
import { Footer } from './components/Footer';
import { PrivacyPolicyPage } from './components/PrivacyPolicyPage';
import { PAGES } from './seo';

type View = 'home' | 'privacy';

function viewFor(pathname: string, hash = ''): View {
  const path = pathname.replace(/\/+$/, '');
  return path === '/privacy' || hash === '#privacy' ? 'privacy' : 'home';
}

function viewFromLocation(): View {
  return viewFor(window.location.pathname, window.location.hash);
}

interface AppProps {
  /** Set only when pre-rendering at build time, where there is no window. */
  initialPath?: string;
}

export default function App({ initialPath }: AppProps) {
  const [view, setView] = useState<View>(() =>
    initialPath !== undefined ? viewFor(initialPath) : viewFromLocation()
  );

  // Support /privacy and #privacy (Vercel rewrites every path to index.html)
  useEffect(() => {
    const handleRoute = () => {
      const next = viewFromLocation();
      setView(next);
      if (next === 'privacy') window.scrollTo({ top: 0, behavior: 'instant' });
    };
    window.addEventListener('popstate', handleRoute);
    window.addEventListener('hashchange', handleRoute);
    return () => {
      window.removeEventListener('popstate', handleRoute);
      window.removeEventListener('hashchange', handleRoute);
    };
  }, []);

  useEffect(() => {
    document.title = PAGES[view === 'privacy' ? '/privacy' : '/'].title;
  }, [view]);

  const navigate = (next: View) => {
    setView(next);
    try {
      window.history.pushState({ page: next }, '', next === 'privacy' ? '/privacy' : '/');
    } catch {
      window.location.hash = next === 'privacy' ? '#privacy' : '';
    }
    window.scrollTo({ top: 0, behavior: 'instant' });
  };

  if (view === 'privacy') {
    return (
      <div id="mountly-app-root">
        <PrivacyPolicyPage onBackToHome={() => navigate('home')} />
      </div>
    );
  }

  return (
    <div id="mountly-app-root" className="min-h-screen overflow-x-clip bg-cream text-ink">
      <Navigation />
      <main>
        <Hero />
        <FeatureGrid />
        <CompatibilitySection />
        <FAQ />
        <DownloadSection />
      </main>
      <Footer onOpenPrivacy={() => navigate('privacy')} />
    </div>
  );
}
