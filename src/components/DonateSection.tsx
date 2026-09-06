import { Heart } from 'lucide-react';

interface DonateSectionProps {
  onOpenDonate: () => void;
}

export function DonateSection({ onOpenDonate }: DonateSectionProps) {
  return (
    <section id="donate" className="py-16 md:py-20 border-t border-stone-200 dark:border-stone-800/80 bg-stone-100/40 dark:bg-stone-950">
      <div className="mx-auto max-w-3xl px-4 sm:px-6 lg:px-8">
        <div className="rounded-2xl border border-stone-200 dark:border-stone-800 bg-white dark:bg-stone-900/40 p-6 sm:p-8 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-6 shadow-sm dark:shadow-none">
          <div className="space-y-2">
            <div className="flex items-center gap-2">
              <div className="h-8 w-8 rounded-xl bg-blue-100 dark:bg-stone-800 border border-blue-200 dark:border-stone-700/60 flex items-center justify-center text-blue-600 dark:text-blue-400">
                <Heart className="h-4 w-4" aria-hidden="true" />
              </div>
              <h3 className="text-xl font-bold text-stone-900 dark:text-white tracking-tight">
                Support Mountly
              </h3>
            </div>
            <p className="text-sm text-stone-600 dark:text-stone-300 leading-relaxed max-w-xl">
              Mountly is an independent project. If it saves you time or helps you work with your drives, you can support its continued development.
            </p>
          </div>

          <button
            type="button"
            id="support-mountly-donate-btn"
            onClick={onOpenDonate}
            className="shrink-0 inline-flex items-center gap-2 px-5 py-2.5 rounded-full border border-stone-300 dark:border-stone-700 bg-stone-900 dark:bg-stone-800 hover:bg-stone-800 dark:hover:bg-stone-700 text-white text-xs font-semibold shadow-sm transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 active:scale-[0.98]"
          >
            <Heart className="h-3.5 w-3.5 text-blue-400" />
            <span>Donate</span>
          </button>
        </div>
      </div>
    </section>
  );
}
