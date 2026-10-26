# Assets

- Import application images from `src/assets/` so the bundler fingerprints them. Files that document metadata or a manifest
  consume use public URLs, with a build step that serves them there.
- Encode photographs as AVIF and WebP at 800 and 1600px wide. A source narrower than a width skips it, and `srcSet`
  lists only the widths that exist:

  ```sh
  for w in 800 1600; do
    magick source.png -resize "${w}x>" -quality 55 src/assets/name-$w.avif
    magick source.png -resize "${w}x>" -quality 80 -define webp:method=6 src/assets/name-$w.webp
  done
  ```

- Render a photograph through `<picture>`: an AVIF `<source>`, then a WebP `<source>`, each with `srcSet` and `sizes`, then
  an `<img>` fallback. The browser takes the first format it supports at the width that fits.

  ```tsx
  <picture>
    <source
      type="image/avif"
      srcSet={`${name800Avif} 800w, ${name1600Avif} 1600w`}
      sizes="(max-width: 40rem) 100vw, 40rem"
    />
    <source
      type="image/webp"
      srcSet={`${name800Webp} 800w, ${name1600Webp} 1600w`}
      sizes="(max-width: 40rem) 100vw, 40rem"
    />
    <img src={name800Webp} width={800} height={400} alt="…" />
  </picture>
  ```

- Every `<img>` in the app carries `width` and `height` in the source's aspect ratio, so the browser reserves its space before it loads.
- An image below the fold gets `loading="lazy"` and `decoding="async"`. The one image that is the page's largest paint gets
  `fetchpriority="high"` and loads eagerly.
- Use PNG when the image needs alpha or exact pixels.
- Motion in docs and release notes is an animated WebP recorded with the `nbr-record-clip` skill. Its tape or capture
  script and fixtures live in `docs/assets/tapes/`, so every clip can be recorded again.
- In-app icons, logos, and line art are inline SVG components, so they inherit `currentColor` and follow the theme.

## Themed docs images

Banners, screenshots, and clips in a README, the docs, and release notes come as a pair, `<name>-dark.<ext>` and
`<name>-light.<ext>`, and follow the reader's color scheme. The light file is the fallback:

```html
<picture>
  <source
    media="(prefers-color-scheme: dark)"
    srcset="docs/assets/banner-dark.svg"
  />
  <img alt="<project>: <tagline>" src="docs/assets/banner-light.svg" />
</picture>
```

Both files show the same content in the project's dark and light theme. Change one, record or export the other in the same
commit.

These rules apply to assets added or touched. Existing files keep their format.

## Sources of Truth

- **MDN responsive images**: https://developer.mozilla.org/en-US/docs/Web/HTML/Guides/Responsive_images
- **MDN `<img>`** (`loading`, `decoding`, `fetchpriority`): https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/img
