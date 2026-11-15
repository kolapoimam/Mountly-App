import { useEffect, useState } from 'react';
import { Navigation } from './components/Navigation';
import { Hero } from './components/Hero';
import { FeatureGrid } from './components/FeatureGrid';
import { CompatibilitySection } from './components/CompatibilitySection';
import { FAQ } from './components/FAQ';
import { DownloadSection } from './components/DownloadSection';
import { Footer } from './components/Footer';
import { PrivacyPolicyPage } from './components/PrivacyPolicyPage';

type View = 'home' | 'privacy';

function viewFromLocation(): View {
  const path = window.location.pathname.replace(/\/+$/, '');
  return path === '/privacy' || window.location.hash === '#privacy' ? 'privacy' : 'home';
}

export default function App() {
  const [view, setView] = useState<View>(viewFromLocation);

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
    document.title =
      view === 'privacy' ? 'Privacy Policy · Mountly' : 'Mountly — External drives, made accessible.';
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
