import { HardDrive } from 'lucide-react';

export const DOWNLOAD_URL =
  'https://drive.google.com/drive/folders/10siVhoTd4-5X_bA3s5Ns0AYtGD87D95s?usp=sharing';
export const DONATE_URL = 'https://paystack.shop/pay/pmbuddy';
export const GITHUB_URL = 'https://github.com/kolapoimam/mountly';
export const AUTHOR_URL = 'https://kolapo.ng';

interface LogoMarkProps {
  size?: 'sm' | 'md';
}

export function LogoMark({ size = 'md' }: LogoMarkProps) {
  const box = size === 'sm' ? 'h-8 w-8 rounded-[10px]' : 'h-9 w-9 rounded-[11px]';
  const icon = size === 'sm' ? 'h-4 w-4' : 'h-[18px] w-[18px]';
  return (
    <span
      className={`${box} flex items-center justify-center bg-cobalt text-white shadow-[inset_0_-3px_0_rgba(0,0,0,0.18)]`}
    >
      <HardDrive className={icon} strokeWidth={2.2} aria-hidden="true" />
    </span>
  );
}

export function Wordmark({ size = 'md' }: LogoMarkProps) {
  return (
    <span className="flex items-center gap-2.5">
      <LogoMark size={size} />
      <span
        className={`font-display font-bold tracking-[-0.02em] text-ink ${
          size === 'sm' ? 'text-xl' : 'text-[22px]'
        }`}
      >
        Mountly
      </span>
    </span>
  );
}

export function SectionEyebrow({ index, label, tone }: { index: string; label: string; tone: string }) {
  return (
    <p className={`mb-3.5 font-mono text-[13px] tracking-[0.04em] ${tone}`}>
      {index} / {label}
    </p>
  );
}
