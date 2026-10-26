# HTML

The browser already ships landmarks, disclosure widgets, dialogs, form validation, and a document head. Write the element
first and add a library or script only for what the element cannot do.

## Semantic structure

- A page has one `<main>`, with `<header>`, `<nav>`, `<aside>`, and `<footer>` beside it. Content inside is `<article>` and
  `<section>`. A `<div role="…">` stands in only where no element carries that role.
- One `<h1>` per page; heading levels descend without skipping.
- An action is a `<button type="button">`, a destination is an `<a href>`.
- A date or time is a `<time datetime="…">`.

## Native before a component

- Disclosure is `<details>` and `<summary>`. A modal is `<dialog>` opened with `showModal()`. A non-modal overlay that needs no
  positioning is the `popover` attribute.
- Form fields carry their constraints as attributes (`required`, `type`, `min`, `max`, `pattern`), so the browser validates
  before the schema does. The schema stays the source of truth, see the `validation` topic.
- Presentational state lives in CSS: `:has()`, `:focus-within`, container queries, `prefers-color-scheme`, and
  `prefers-reduced-motion`.
- A widget with behavior the platform lacks, such as a menu, combobox, select, tooltip, or anchored popup, comes from Base UI,
  see `react/component-libraries.md`.

## Document head

A public page reached from search or a shared link renders its metadata on the server, through the route's `head()` in
TanStack Start. An app behind a login needs only its `title`.

```tsx
export const Route = createFileRoute("/posts/$slug")({
  head: ({ loaderData }) => ({
    meta: [
      { title: loaderData.post.title },
      { name: "description", content: loaderData.post.excerpt },
      { property: "og:type", content: "article" },
      { property: "og:title", content: loaderData.post.title },
      { property: "og:description", content: loaderData.post.excerpt },
      { property: "og:url", content: loaderData.post.url },
      { property: "og:image", content: loaderData.post.coverImage },
      { property: "og:image:alt", content: loaderData.post.coverAlt },
      { name: "twitter:card", content: "summary_large_image" },
    ],
    scripts: [
      {
        type: "application/ld+json",
        children: JSON.stringify({
          "@context": "https://schema.org",
          "@type": "Article",
          headline: loaderData.post.title,
          datePublished: loaderData.post.publishedAt,
          author: { "@type": "Person", name: "<author>" },
        }),
      },
    ],
  }),
});
```

- Pick the JSON-LD `@type` from schema.org: `Article`, `Person`, `WebSite`, `SoftwareSourceCode`.
- The `og:image` is an absolute URL to a 1200x630 image.

## Resource hints

- `preconnect` an origin the page needs early, such as a font or API host on another domain. `dns-prefetch` an origin it may
  need.
- `preload` only what the parser cannot discover on its own, typically a self-hosted web font. Every preload competes with the
  rest, so hint the two or three resources the first paint waits on.
- Image priority and lazy loading are in the `assets` topic.

## Sources of Truth

- **MDN HTML elements**: https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements
- **MDN Popover API**: https://developer.mozilla.org/en-US/docs/Web/API/Popover_API
- **TanStack document head**: https://tanstack.com/router/latest/docs/guide/document-head-management
- **Open Graph protocol**: https://ogp.me
- **schema.org types**: https://schema.org/docs/full.html
