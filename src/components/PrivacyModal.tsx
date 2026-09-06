import { X, Lock, Check } from 'lucide-react';

interface PrivacyModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export function PrivacyModal({ isOpen, onClose }: PrivacyModalProps) {
  if (!isOpen) return null;

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="privacy-modal-title"
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 dark:bg-black/80 backdrop-blur-sm animate-in fade-in duration-200"
    >
      <div className="relative w-full max-w-lg rounded-2xl border border-stone-200 dark:border-stone-800 bg-white dark:bg-stone-900 p-6 sm:p-7 shadow-2xl text-stone-900 dark:text-stone-100 space-y-4">
        <button
          type="button"
          onClick={onClose}
          aria-label="Close dialog"
          className="absolute top-4 right-4 p-1.5 rounded-lg text-stone-400 hover:text-stone-700 dark:hover:text-white hover:bg-stone-100 dark:hover:bg-stone-800 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500"
        >
          <X className="h-4 w-4" />
        </button>

        <div className="flex items-center gap-3">
          <div className="h-9 w-9 rounded-xl bg-blue-100 dark:bg-stone-800 border border-blue-200 dark:border-stone-700/60 flex items-center justify-center text-blue-600 dark:text-blue-400">
            <Lock className="h-4 w-4" />
          </div>
          <div>
            <h3 id="privacy-modal-title" className="text-lg font-bold text-stone-900 dark:text-white">
              Privacy & Data Policy
            </h3>
            <p className="text-xs text-stone-500 dark:text-stone-400">Mountly operates 100% locally on your machine.</p>
          </div>
        </div>

        <div className="space-y-3 text-xs text-stone-600 dark:text-stone-300 leading-relaxed pt-2">
          <div className="p-3.5 rounded-xl bg-stone-50 dark:bg-stone-950/70 border border-stone-200 dark:border-stone-800 space-y-2.5">
            <div className="flex items-start gap-2">
              <Check className="h-3.5 w-3.5 text-emerald-600 dark:text-emerald-400 mt-0.5 shrink-0" />
              <span><strong className="text-stone-900 dark:text-white">Zero Telemetry:</strong> Mountly collects no usage metrics, crash logs, or analytics.</span>
            </div>
            <div className="flex items-start gap-2">
              <Check className="h-3.5 w-3.5 text-emerald-600 dark:text-emerald-400 mt-0.5 shrink-0" />
              <span><strong className="text-stone-900 dark:text-white">Local Processing:</strong> Drive discovery and filesystem mounts occur entirely within macOS subsystem APIs. No external network requests are made.</span>
            </div>
            <div className="flex items-start gap-2">
              <Check className="h-3.5 w-3.5 text-emerald-600 dark:text-emerald-400 mt-0.5 shrink-0" />
              <span><strong className="text-stone-900 dark:text-white">Data Integrity:</strong> File contents are never indexed, copied, or uploaded to any remote server or cloud infrastructure.</span>
            </div>
          </div>
        </div>

        <div className="pt-2">
          <button
            type="button"
            onClick={onClose}
            className="w-full py-2.5 rounded-xl bg-stone-100 hover:bg-stone-200 dark:bg-stone-800 dark:hover:bg-stone-700 text-stone-800 dark:text-white font-medium text-xs border border-stone-200 dark:border-stone-700 transition-colors"
          >
            Close
          </button>
        </div>
      </div>
    </div>
  );
}
