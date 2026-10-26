# Terminal lane

[VHS](https://github.com/charmbracelet/vhs) types a tape into a headless terminal and renders every frame 20 ms apart,
however slow the machine. Write raw frames: VHS's own gif, mp4, and webm outputs cap at 25 fps.

## Tape

```text
Output frames/
Set Shell zsh
Set FontSize 22
Set Width 1200
Set Height 600
Set Framerate 50
Set TypingSpeed 60ms

Hide
Type "cd ~/code/my-plugin.nvim && clear"
Enter
Show

Type "nvim README.md"
Enter
Sleep 1s
```

- `Hide` and `Show` keep setup out of the clip.
- A Neovim session loads the person's own config. To show one plugin alone, run `nvim --clean -u <init.lua>`.

Run it from a fresh scratchpad directory, with the repo passed in as an env var so the tape holds no machine paths:

```sh
cd <scratch> && REPO=<repo> vhs "$REPO/docs/assets/tapes/<topic>.tape"
```

Inside the tape, refer to `$REPO/docs/assets/tapes/demo` and `$REPO/docs/assets/tapes/init.lua`, and set
`XDG_DATA_HOME=$PWD/xdg`.

## Theme and font

Every clip uses the same font and themes, so all clips match: the font is TX-02 (Berkeley Mono, installed as `TX-02`),
the themes are Black Atom Default Dark and Light, kept as VHS theme JSON in [`themes/`](../themes/). The tape sets neither.
Each run prepends them, plus `CLIP_SCHEME` (`dark` or `light`) for the project's own fixtures to read, and records into its
own directory.

VHS falls back to another font without a warning, so stop first when TX-02 is missing. The check needs fontconfig
(`brew install fontconfig` on macOS) and the hyphen escaped:

```sh
[ "$(fc-match -f '%{family}' 'TX\-02')" = TX-02 ] || echo "TX-02 is not installed"

for scheme in dark light; do
  mkdir <scratch>/$scheme && cd <scratch>/$scheme
  {
    printf 'Set Theme %s\n' "$(tr -d '\n' < <skill-dir>/themes/black-atom-default-$scheme.json)"
    printf 'Set FontFamily "TX-02"\nEnv CLIP_SCHEME "%s"\n' $scheme
    cat "$REPO/docs/assets/tapes/<topic>.tape"
  } > run.tape
  REPO=<repo> vhs run.tape
done
```

The theme JSON comes from the Black Atom Ghostty adapter. Regenerate it from a Black Atom checkout when those themes change:

```sh
<skill-dir>/scripts/ghostty-to-vhs-theme.sh \
  <black-atom>/adapters/ghostty/themes/default/black-atom-default-dark.conf "Black Atom Default Dark" \
  > <skill-dir>/themes/black-atom-default-dark.json
```

## Compose

`frames/` holds two layers per frame, `frame-text-NNNNN.png` and `frame-cursor-NNNNN.png`, without padding. Overlay them and
pad with the terminal background, then encode as in [`SKILL.md`](../SKILL.md#encode) with `<fps>` 50 and `<frames>`
`composed`:

```sh
bg=$(magick frames/frame-text-00001.png -format '%[hex:p{0,0}]' info:)
mkdir composed
ffmpeg -loglevel error -framerate 50 -i frames/frame-text-%05d.png -framerate 50 -i frames/frame-cursor-%05d.png \
  -filter_complex "[0][1]overlay,pad=iw+80:ih+80:40:40:color=0x$bg" composed/f%05d.png
```
