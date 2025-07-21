// web/script.js
import { marked } from "https://cdn.jsdelivr.net/npm/marked/lib/marked.esm.js";

document.addEventListener('DOMContentLoaded', () => {
  const links = document.querySelectorAll('aside a');
  const main = document.querySelector('main');

  links.forEach(link => {
    link.addEventListener('click', async (e) => {
      e.preventDefault();
      const url = e.target.getAttribute('href'); // e.g. ../md_notes/cnet/cnet-ip.md

      // Get base path of the md file, e.g. ../md_notes/cnet/
      const basePath = url.substring(0, url.lastIndexOf('/') + 1);

      try {
        const response = await fetch(url);
        if (!response.ok) throw new Error(`Failed to load ${url}`);

        let mdText = await response.text();

        // Rewrite relative image paths in Markdown so they load from correct folder
        mdText = mdText.replace(/!\[(.*?)\]\((?!https?:\/\/)(.*?)\)/g, (match, alt, src) => {
          // If src is already absolute (starts with /), leave it
          if (src.startsWith('/')) return match;
          // Otherwise, prepend basePath
          return `![${alt}](${basePath}${src})`;
        });

        const html = marked.parse(mdText);
        main.innerHTML = html;
      } catch (err) {
        main.innerHTML = `<p style="color:red;">Error loading Markdown: ${err.message}</p>`;
      }
    });
  });
});
