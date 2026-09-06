import { X, Heart, ExternalLink } from 'lucide-react';

interface DonateModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export function DonateModal({ isOpen, onClose }: DonateModalProps) {
  if (!isOpen) return null;

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="donate-modal-title"
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 dark:bg-black/80 backdrop-blur-sm animate-in fade-in duration-200"
    >
      <div className="relative w-full max-w-md rounded-2xl border border-stone-200 dark:border-stone-800 bg-white dark:bg-stone-900 p-6 sm:p-7 shadow-2xl text-stone-900 dark:text-stone-100">
        <button
          type="button"
          onClick={onClose}
          aria-label="Close dialog"
          className="absolute top-4 right-4 p-1.5 rounded-lg text-stone-400 hover:text-stone-700 dark:hover:text-white hover:bg-stone-100 dark:hover:bg-stone-800 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500"
        >
          <X className="h-4 w-4" />
        </button>

        <div className="space-y-4">
          <div className="h-10 w-10 rounded-xl bg-blue-100 dark:bg-stone-800 border border-blue-200 dark:border-stone-700/60 flex items-center justify-center text-blue-600 dark:text-blue-400">
            <Heart className="h-5 w-5" />
          </div>

          <div>
            <h3 id="donate-modal-title" className="text-xl font-bold text-stone-900 dark:text-white">
              Support Mountly
            </h3>
            <p className="text-sm text-stone-600 dark:text-stone-300 leading-relaxed mt-2">
              Mountly is an independent project. If it saves you time or helps you work with your drives, you can support its continued development.
            </p>
          </div>

          <div className="pt-2">
            <a
              href="https://paystack.shop/pay/pmbuddy"
              target="_blank"
              rel="noopener noreferrer"
              id="donate-modal-external-link"
              className="w-full py-3 px-4 rounded-xl bg-blue-600 hover:bg-blue-500 text-white font-semibold text-sm flex items-center justify-center gap-2 shadow-md shadow-blue-900/20 hover:shadow-blue-800/30 transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-400"
            >
              <span>Continue to Donation</span>
              <ExternalLink className="h-4 w-4" />
            </a>
          </div>

          <p className="text-[11px] text-stone-500 text-center">
            Maintained by Kolapo Imam · kolapo.ng
          </p>
        </div>
      </div>
    </div>
  );
}
