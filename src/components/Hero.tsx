import { Download, Heart } from 'lucide-react';
import { ProductPreview } from './ProductPreview';

interface HeroProps {
  onOpenDownload: () => void;
  onOpenDonate: () => void;
}

export function Hero({ onOpenDownload, onOpenDonate }: HeroProps) {
  return (
    <section id="hero" className="relative pb-16 md:pb-24 overflow-hidden">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        {/* Centered / clean Hero Copy */}
        <div className="text-center max-w-3xl mx-auto space-y-6">
          {/* Headline */}
          <h1 className="text-4xl sm:text-5xl md:text-6xl font-extrabold tracking-tight text-stone-900 dark:text-white">
            External drives, made accessible.
          </h1>

          {/* Supporting copy */}
          <p className="text-lg sm:text-xl text-stone-600 dark:text-stone-300 leading-relaxed font-normal max-w-2xl mx-auto">
            Mountly gives your Mac a simpler way to work with external filesystems that macOS doesn't fully support out of the box.
          </p>

          {/* CTAs */}
          <div className="pt-2 flex flex-col sm:flex-row items-center justify-center gap-3">
            <a
              id="hero-download-button"
              href="https://drive.google.com/drive/folders/10siVhoTd4-5X_bA3s5Ns0AYtGD87D95s?usp=sharing"
              target="_blank"
              rel="noopener noreferrer"
              className="w-full sm:w-auto inline-flex items-center justify-center gap-2.5 px-6 py-3.5 rounded-full bg-blue-600 hover:bg-blue-500 text-white font-semibold text-sm shadow-md shadow-blue-900/20 hover:shadow-blue-800/30 transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-400 active:scale-[0.98]"
            >
              <Download className="h-4 w-4" aria-hidden="true" />
              <span>Download Mountly</span>
            </a>

            <button
              type="button"
              id="hero-donate-button"
              onClick={onOpenDonate}
              className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-5 py-3.5 rounded-full border border-stone-300 dark:border-stone-800 hover:border-stone-400 dark:hover:border-stone-700 bg-white dark:bg-stone-900/70 hover:bg-stone-100 dark:hover:bg-stone-800 text-stone-800 dark:text-stone-300 hover:text-stone-950 dark:hover:text-white font-medium text-sm transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 shadow-xs"
            >
              <Heart className="h-4 w-4 text-blue-500 dark:text-blue-400" aria-hidden="true" />
              <span>Donate</span>
            </button>
          </div>
        </div>

        {/* Hero Visual: ProductPreview */}
        <div className="mt-12 md:mt-16">
          <ProductPreview />
        </div>
      </div>
    </section>
  );
}
