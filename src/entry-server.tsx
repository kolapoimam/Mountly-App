import { StrictMode } from 'react';
import { renderToString } from 'react-dom/server';
import App from './App';
import { buildHead } from './seo';

/** Build-time render of one route: the page markup plus its <head> tags. */
export function render(url: string) {
  const html = renderToString(
    <StrictMode>
      <App initialPath={url} />
    </StrictMode>
  );
  return { html, head: buildHead(url) };
}
