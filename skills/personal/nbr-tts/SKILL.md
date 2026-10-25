---
name: nbr-tts
description: Turn text into speech with the ElevenLabs API. Use when asked to read something aloud, make an MP3 or voiceover from text, or when another skill needs audio.
argument-hint: "[--voice <name|id>] [--model <id>] [--lang <code>] [--out <path>] <text or file>"
compatibility: Requires an ElevenLabs account, its API key in Proton Pass, pass-cli, curl, the `elevenlabs` CLI, jq, and ffmpeg.
---

# Text to speech

My defaults on top of the official ElevenLabs `text-to-speech` skill. Load it for anything this file leaves open: voice
settings, audio effects, text normalization, output formats, streaming, other models. Its setup step runs
`onboard init`; sign in as section 1 says instead.

Audio comes from the API, called with the key at `pass://Nik/.env/ELEVENLABS_API_TOKEN`. The `elevenlabs` CLI (npm
`@elevenlabs/cli`, installed through mise) reads the account, voices and history. Never generate through the CLI: it signs
in through the browser and is billed at app rates, 1 credit per character, where the API key pays 0.2 on v4 Turbo and 0.4
on v4. Every generated character still counts against the monthly credits, so audio is made only after Nik says yes to
its cost.

## Arguments

All optional; the request may also name them in words ("in David's voice", "German").

| Argument  | Default                                  | Notes                                                    |
| --------- | ---------------------------------------- | -------------------------------------------------------- |
| `--voice` | Sadie, `bD9maNcCuQQS75DGuteM`            | A name resolves through `elevenlabs voices search`       |
| `--model` | `eleven_v4`                              | Others and their trade-offs: the official skill          |
| `--lang`  | detected by the model                    | ISO 639-1, sent as `language_code`                       |
| `--out`   | `<scratchpad>/<slug>.mp3`                | The caller's path wins                                   |

Any other wish (slower, more expressive, a reverb room) maps to a request field the official skill describes.

## 1. Sign-in

Generation needs the API key alone; `pass-cli` resolves it when the command runs (section 4).

The account reads need the CLI login. `elevenlabs auth status` shows it; it signs in through OAuth and keeps the token in
the macOS Keychain. With no active login, ask Nik to run `! elevenlabs auth login`, which opens the browser.

## 2. Text for the ear

The listener hears every character. Reduce the text to sentences: drop Markdown markers, code, file paths, URLs, and
tables, and turn `[[wikilinks]]` into their text. When the caller hands over a text that is already written for
listening, read it as it is.

## 3. Cost

Count the characters and multiply by the model's rate: 0.4 credits per character on `eleven_v4`, 0.2 on
`eleven_v4_turbo`. Read what is left from `elevenlabs user subscription get --format json`: `character_limit` minus
`character_count`, both in credits. Ask: "Audio? <n> characters, ~<credits> credits, <left> left this month." Generate
only on yes.

## 4. Generate

```sh
jq -n --rawfile text <part>.txt '{text: $text, model_id: "<model>"}' > <part>.json
ELEVENLABS_API_TOKEN=pass://Nik/.env/ELEVENLABS_API_TOKEN pass-cli run -- sh -c '
  printf "xi-api-key: %s\n" "$ELEVENLABS_API_TOKEN" |
    curl -sS --fail-with-body -H @- -H "Content-Type: application/json" \
      --data-binary @"$0" -o "$1" "https://api.elevenlabs.io/v1/text-to-speech/$2"
' <part>.json <part>.mp3 <voice>
```

The key reaches curl on stdin, never in its arguments, where `ps` would show it. On a failed request the `.mp3` holds
the API's JSON error instead of audio.

Extra request fields (`language_code`, `voice_settings`, `previous_text`, `next_text`) go into the same `jq` object.
`elevenlabs history list` afterwards shows the credits each generation took.

One request takes at most `max_characters_request_subscribed_user` characters of the model (`elevenlabs models list`).
Split a longer text at paragraph breaks and generate each part in the scratchpad, passing the neighbouring parts as
`previous_text` and `next_text` so the seams sound continuous. Join them in order with
`ffmpeg -f concat -safe 0 -i <list> -c:a libmp3lame -b:a 128k <out>.mp3`; a plain `-c copy` breaks the timestamps.

`afplay <file>.mp3` plays a result.
