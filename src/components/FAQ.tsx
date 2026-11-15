import { Accordion } from './Accordion';
import type { AccordionEntry } from './Accordion';
import { SectionEyebrow } from './Brand';

export const FAQS: AccordionEntry[] = [
  {
    q: 'What is Mountly?',
    a: 'Mountly is a native macOS utility designed to detect, mount, and manage supported external drives and filesystems with seamless Finder integration.',
  },
  {
    q: 'Does Mountly support NTFS write access?',
    a: 'Yes. Mountly enables supported read and write operations on NTFS drives without requiring terminal commands or kernel extension hacks.',
  },
  {
    q: 'Do I need to format or erase my drive?',
    a: 'No. Mountly is built so you never have to erase or reformat an existing drive simply because you plugged it into a Mac.',
  },
  {
    q: 'What types of drives are supported?',
    a: 'Mountly works with any external enclosure — USB-C, USB-A, external SSDs, mechanical hard drives, and flash cards regardless of brand.',
  },
  {
    q: 'Does Mountly modify or collect my files?',
    a: 'No. Mountly runs entirely offline on your Mac, collects zero telemetry, and performs operations strictly requested by you.',
  },
];

export function FAQ() {
  return (
    <section id="faq" className="px-5 pb-12 pt-24 sm:px-6 md:pt-28">
      <div className="mx-auto flex max-w-6xl flex-col gap-12 lg:flex-row">
        <div className="lg:w-[38%] lg:shrink-0">
          <SectionEyebrow index="03" label="FAQ" tone="text-mint-ink" />
          <h2 className="font-display text-[clamp(36px,4.6vw,60px)] font-extrabold leading-[1.02] tracking-[-0.035em]">
            Frequently Asked Questions
          </h2>
          <p className="mt-5 max-w-[360px] text-[17px] leading-relaxed text-muted">
            Answers to common questions about drive compatibility, safety, and filesystems.
          </p>
        </div>
        <div className="min-w-0 flex-1">
          <Accordion items={FAQS} defaultOpen={0} />
        </div>
      </div>
    </section>
  );
}
