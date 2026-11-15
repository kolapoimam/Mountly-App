import { useId, useState } from 'react';
import { Plus } from 'lucide-react';

export interface AccordionEntry {
  q: string;
  a: string;
}

// Each item gets its own colour when open
const TONES = [
  { card: 'bg-tangerine-tint', icon: 'bg-tangerine text-white' },
  { card: 'bg-cobalt-tint', icon: 'bg-cobalt text-white' },
  { card: 'bg-mint-tint', icon: 'bg-mint text-white' },
  { card: 'bg-sun-tint', icon: 'bg-sun text-ink' },
  { card: 'bg-berry-tint', icon: 'bg-berry text-white' },
  { card: 'bg-lilac-tint', icon: 'bg-lilac text-white' },
];

interface AccordionProps {
  items: AccordionEntry[];
  defaultOpen?: number | null;
  size?: 'md' | 'lg';
}

/** Only one item can be open at a time. */
export function Accordion({ items, defaultOpen = 0, size = 'lg' }: AccordionProps) {
  const [openIndex, setOpenIndex] = useState<number | null>(defaultOpen);
  const baseId = useId();

  return (
    <div className="flex flex-col gap-3">
      {items.map((item, idx) => {
        const isOpen = openIndex === idx;
        const tone = TONES[idx % TONES.length];
        const panelId = `${baseId}-panel-${idx}`;
        const buttonId = `${baseId}-button-${idx}`;
        return (
          <div
            key={item.q}
            className={`rounded-[22px] border transition-colors duration-200 ${
              isOpen ? `${tone.card} border-transparent` : 'border-line bg-white hover:border-line-2'
            }`}
          >
            <h3>
              <button
                type="button"
                id={buttonId}
                aria-expanded={isOpen}
                aria-controls={panelId}
                onClick={() => setOpenIndex(isOpen ? null : idx)}
                className="flex w-full cursor-pointer items-center justify-between gap-4 rounded-[22px] px-6 py-5 text-left focus:outline-none focus-visible:ring-2 focus-visible:ring-cobalt"
              >
                <span
                  className={`font-display font-semibold tracking-[-0.01em] text-ink ${
                    size === 'lg' ? 'text-lg sm:text-xl' : 'text-base sm:text-lg'
                  }`}
                >
                  {item.q}
                </span>
                <span
                  className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-xl transition-all duration-300 ${
                    isOpen ? `${tone.icon} rotate-45` : 'bg-cream-2 text-ink'
                  }`}
                  aria-hidden="true"
                >
                  <Plus className="h-[18px] w-[18px]" strokeWidth={2.4} />
                </span>
              </button>
            </h3>
            <div
              id={panelId}
              role="region"
              aria-labelledby={buttonId}
              className={`grid transition-[grid-template-rows] duration-300 ease-out ${
                isOpen ? 'grid-rows-[1fr]' : 'grid-rows-[0fr]'
              }`}
            >
              <div className="overflow-hidden">
                <p className="max-w-[640px] px-6 pb-6 text-base leading-relaxed text-[#4a463f]">{item.a}</p>
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
}
