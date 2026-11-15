import { ArrowUpDown, Folder, ShieldCheck, Usb } from 'lucide-react';
import type { LucideIcon } from 'lucide-react';
import { SectionEyebrow } from './Brand';

interface Feature {
  title: string;
  description: string;
  icon: LucideIcon;
  card: string;
  tile: string;
  body: string;
}

const FEATURES: Feature[] = [
  {
    title: 'NTFS Read & Write',
    description:
      'Enable full read and write access on NTFS formatted external drives without terminal commands or reformatting.',
    icon: ArrowUpDown,
    card: 'bg-tangerine-tint',
    tile: 'bg-tangerine text-white',
    body: 'text-[#4a3a30]',
  },
  {
    title: 'Finder Integration',
    description:
      'Discovered volumes appear right in macOS Finder so you can browse, copy, and organize files naturally.',
    icon: Folder,
    card: 'bg-cobalt-tint',
    tile: 'bg-cobalt text-white',
    body: 'text-[#2f3650]',
  },
  {
    title: 'Safe Volume Operations',
    description:
      'Protected mounting routines and safe eject ensure existing partition journals remain undamaged.',
    icon: ShieldCheck,
    card: 'bg-mint-tint',
    tile: 'bg-mint text-white',
    body: 'text-[#2c4438]',
  },
  {
    title: 'Universal Hardware Support',
    description:
      'Compatible with any external enclosure — USB-C, USB-A, portable SSDs, mechanical HDDs, and flash media.',
    icon: Usb,
    card: 'bg-sun-tint',
    tile: 'bg-sun text-ink',
    body: 'text-[#4a4128]',
  },
];

export function FeatureGrid() {
  return (
    <section id="features" className="px-5 pb-16 pt-28 sm:px-6 md:pt-32">
      <div className="mx-auto max-w-6xl">
        <div className="mb-12 flex flex-wrap items-end justify-between gap-6">
          <div className="max-w-[640px]">
            <SectionEyebrow index="01" label="FEATURES" tone="text-tangerine-ink" />
            <h2 className="font-display text-[clamp(36px,4.6vw,60px)] font-extrabold leading-[1.02] tracking-[-0.035em]">
              Everything you need. Nothing you don't.
            </h2>
          </div>
          <p className="max-w-[380px] text-[17px] leading-relaxed text-muted">
            A lightweight, focused utility designed to make external filesystems seamless on Mac.
          </p>
        </div>

        <div className="grid grid-cols-1 gap-5 md:grid-cols-2">
          {FEATURES.map(({ title, description, icon: Icon, card, tile, body }) => (
            <article
              key={title}
              className={`group flex min-h-[260px] flex-col gap-[18px] rounded-[28px] p-8 sm:p-9 ${card}`}
            >
              <span
                className={`flex h-14 w-14 items-center justify-center rounded-2xl shadow-[inset_0_-4px_0_rgba(0,0,0,0.14)] transition-transform duration-300 group-hover:-rotate-6 ${tile}`}
              >
                <Icon className="h-6 w-6" strokeWidth={2.2} aria-hidden="true" />
              </span>
              <h3 className="mt-auto font-display text-[26px] font-bold tracking-[-0.02em]">{title}</h3>
              <p className={`text-base leading-relaxed ${body}`}>{description}</p>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
