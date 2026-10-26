---
name: nbr-record-clip
description:
  "Record motion as a smooth looping animated WebP in a dark and a light version, or as an mp4 video. Use when a still
  screenshot cannot show the behavior, or when asked to record, film, or animate a terminal or Neovim session, a web page,
  or a native app window, or to make a video walkthrough."
compatibility: Requires ImageMagick. Terminal clips need VHS and ffmpeg, browser clips Node and Playwright, native app clips ffmpeg on macOS (AVFoundation) or Cap's `cap` CLI. Videos need `cap`.
argument-hint: "<terminal | browser | native> [what to show]"
allowed-tools: Read Write Bash
---

# Record a clip

A clip is an animated WebP. Output WebP only: GitHub shows a repo-hosted mp4 as a broken image, and a GIF is limited to
256 colors and centisecond frame timing.

Every clip is a pair, `<topic>-dark.webp` and `<topic>-light.webp`: the same motion recorded once in a dark theme and
once in a light theme. Terminal clips use TX-02 and Black Atom Default Dark and Light; browser and native clips use the page's
or the app's own dark and light theme. The README shows the pair through a `<picture>` that follows the reader's color
scheme, as the `assets` topic in `nbr-repo-conventions` describes. Each lane's reference says how it switches the scheme.

| Lane     | Shows                                | Read                                               |
| -------- | ------------------------------------ | -------------------------------------------------- |
| Terminal | A CLI, TUI, or Neovim session        | [`references/terminal.md`](references/terminal.md) |
| Browser  | A web page, dev server, or Storybook | [`references/browser.md`](references/browser.md)   |
| Native   | A desktop app window, such as Livery | [`references/native.md`](references/native.md)     |

## Workflow

1. Pick the lane and read its reference. Script the motion so each state holds about a second, long enough to read.
2. Keep the script in the repo, so the clip can be recorded again after a UI change: `docs/assets/tapes/<topic>.tape` (or
   the browser lane's script), with shared fixtures such as a demo project or a minimal `init.lua` beside it in
   `docs/assets/tapes/`. Paths in the script are relative to the repo root; only output and data dirs go to the scratchpad.
3. Record each scheme into a fresh directory in the scratchpad; the lane's reference writes `<out>.webp`.
4. Encode lossless first, as below. Flat UI and terminal text compress best that way. When the clip is too large, encode
   again with `-quality 80` in place of `-define webp:lossless=true` and keep the smaller file. Still too large: shorten the
   motion, or keep every second frame and encode with `1x<fps/2>`.
5. Split the clip into frames in the scratchpad and look at four or five across it:

   ```sh
   magick <clip>.webp -coalesce <dir>/f%05d.png
   ```

   The clip is done when, in both files, the sampled frames show only the subject in that file's scheme, every state from
   step 1 appears in order, and the file is at most 2 MB.

## Encode

Every lane ends in this command, with `<fps>` matching the capture:

```sh
magick -delay 1x<fps> -loop 0 '<frames>/f*.png' -define webp:lossless=true -define webp:method=4 <out>.webp
```

`magick` merges identical consecutive frames into one longer frame, so pauses cost almost nothing.

## Video

A walkthrough longer than a loop, or one with narration, is an mp4 recorded with Cap's `cap` CLI (capture as in the native
lane's [Capture with Cap](references/native.md#capture-with-cap), add `--mic <name>` for narration, export without
extracting frames). It plays where a video is attached rather than committed: a GitHub PR, issue, or release body, Slack, or
a link from `cap upload`. A video plays in one scheme, so record it in the scheme the audience mostly uses. VHS stays the
terminal lane; `cap` on a terminal window suits a live session that cannot be scripted.
