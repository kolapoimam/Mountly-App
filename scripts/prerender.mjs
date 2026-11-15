// Writes fully rendered HTML for each route so search engines and AI crawlers
// see the real content and per-page metadata without running JavaScript.
import { readFile, writeFile, rm } from 'node:fs/promises';
import { fileURLToPath, pathToFileURL } from 'node:url';
import path from 'node:path';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const dist = path.join(root, 'dist');
const ssrDir = path.join(root, '.ssr');

const template = await readFile(path.join(dist, 'index.html'), 'utf8');
const { render } = await import(pathToFileURL(path.join(ssrDir, 'entry-server.js')).href);

const SEO_BLOCK = /<!--seo:start-->[\s\S]*?<!--seo:end-->/;
if (!SEO_BLOCK.test(template) || !template.includes('<div id="root"></div>')) {
  throw new Error('prerender: index.html is missing the seo markers or the empty #root');
}

const routes = [
  { url: '/', file: 'index.html' },
  { url: '/privacy', file: 'privacy.html' },
];

for (const { url, file } of routes) {
  const { html, head } = render(url);
  const page = template
    .replace(SEO_BLOCK, `<!--seo:start-->\n    ${head}\n    <!--seo:end-->`)
    .replace('<div id="root"></div>', `<div id="root">${html}</div>`);
  await writeFile(path.join(dist, file), page);
  console.log(`prerendered ${url} -> dist/${file} (${(page.length / 1024).toFixed(1)} kB)`);
}

await rm(ssrDir, { recursive: true, force: true });
