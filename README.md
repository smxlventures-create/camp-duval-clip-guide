# Camp Duval Clip Guide

This is how we make Camp Duval social clips and ads: vertical 1080x1920 with big poster-style captions, a red callout bar, and the "Available on CampDuval.com" end card. Everything here runs on your own computer with free tools.

## 1. Install the tools (one time)
- **ffmpeg** (does all the video work)
  - Mac: `brew install ffmpeg` (install Homebrew from brew.sh first)
  - Windows: `winget install ffmpeg`, or use WSL and follow the Linux steps
  - Linux: `sudo apt install ffmpeg`
- **Python 3** and two libraries (used to draw captions and the end card): `pip3 install pillow numpy`
- A video player that can step frame by frame (VLC or QuickTime) for picking timecodes.
- Check it all works: `ffmpeg -version` and `python3 -c "import PIL, numpy"`.

Make the scripts runnable once: `chmod +x scripts/*.sh scripts/*.py`

## 2. Camp Duval rules (please read)
- **End card** reads only **"Available on CampDuval.com"** with the iTunes/Apple and Amazon logos. Don't add "Apple and Amazon" as text.
- **Caption tagline:** "The Scariest Funny Movie this year!"
- **Never** use the "AIN'T NOBODY DYING TODAY" tagline.
- **No knife or cleaver art** in any graphics we add.
- **No fake reviews**, quotes, or star ratings. Only use real press quotes you can source.
- **No commercial music in ads.** Platforms can mute the track or reject the ad. Use the film's own audio.
- **Reuse existing footage** (the film, trailers, premiere and interview clips). We don't make new content for these.

## 3. Find and trim a moment
1. Watch the source and note the **in and out times** (e.g. `00:00:02.0` to `00:00:14.0`). 15 to 30 seconds works best for ads.
2. Add about a third of a second at each end so the clip doesn't start or stop mid-motion.
3. Always cut from the **original file**, not from something you already exported.

```bash
scripts/trim.sh source.mp4 2 14 01-trim.mp4
```

## 4. Make it vertical (1080x1920, 30fps)
Phone footage is often 720x1280. This step scales it up to 1080x1920 at 30fps (that's what we did for the recent VOD ads). Wide footage gets cropped to 9:16.

```bash
scripts/vertical.sh 01-trim.mp4 02-vertical.mp4            # center crop
scripts/vertical.sh 01-trim.mp4 02-vertical.mp4 crop 0.3   # crop nearer the left
scripts/vertical.sh 01-trim.mp4 02-vertical.mp4 pad        # keep whole frame, black bars
```
Don't scale up more than about 2x the source size or it goes soft. Keep faces out of the top and bottom ~250px, where the app's buttons and captions sit.

## 5. Captions: big centered distressed cream text with a red callout bar
The look: tall bold condensed letters (Oswald Bold) in cream `#F7EEDC` with a roughed-up/distressed texture, centered in the lower third, with a solid red `#E22C1E` bar above it in Archivo Black (for example "OUT NOW"). The fonts are in `assets/fonts/`.

```bash
# '|' starts a new line. --y sets how far down the bar/caption starts (default 1300)
python3 scripts/make_caption.py caption.png "THE SCARIEST FUNNY|MOVIE THIS YEAR!" --bar "OUT NOW"
# burn it in for the whole clip, or only from second 1 to 11:
scripts/burn_caption.sh 02-vertical.mp4 caption.png 03-captioned.mp4 1 11
```
Check whether the source already has captions burned in. If it does, move yours (`--y`) or choose a different moment so the two don't overlap.

## 6. Add the end card
`assets/endcard_available_on_campduval.png` is the clean card (Available on CampDuval.com + iTunes and Amazon logos). You can rebuild it with `python3 scripts/make_endcard.py assets/endcard_available_on_campduval.png`.

```bash
scripts/add_endcard.sh 03-captioned.mp4 assets/endcard_available_on_campduval.png 04-endcard.mp4 3
```
This adds the card for 3 seconds with silence underneath, so the audio doesn't cut off with a pop.

`assets/surround_endcard.png` is the version we used for the recent premiere post. It also has an "OUT NOW" bar, the film logo, and the tagline. For ads, use the clean card unless we say otherwise.

## 7. Export
```bash
scripts/export.sh 04-endcard.mp4 2026-11-01-campduval-scene-name
```
This writes:
| File | Size | Use |
|---|---|---|
| `...-1080x1920.mp4` | 9:16 | Reels, TikTok, Shorts, Stories, vertical ads |
| `...-1080x1350.mp4` | 4:5 center crop | Instagram/Facebook feed |

Settings: H.264 (CRF 18, yuv420p, 30fps), AAC 192k 48kHz, loudness normalized to -14 LUFS / -1.5 dB true peak, "faststart" so it plays straight away online. Length limits: Reels 90s, Shorts 180s, TikTok 10 min.
Name files so they sort: date-source-what-size, all lowercase with hyphens, no spaces. Check the 4:5 crop doesn't cut off the caption. If it does, set the caption a bit higher (`--y 1150`) or make a separate 4:5 caption.

## 8. QC checklist (do this before posting)
```bash
scripts/qc.sh 2026-11-01-campduval-scene-name-1080x1920.mp4
```
It prints the specs and loudness and saves stills from the start, middle, end, and last frame. Then check:
- [ ] 1080x1920, 30fps, h264 + aac
- [ ] Loudness about -14 LUFS (within 1), peak no higher than -1 dB
- [ ] Watch it all the way through **on a phone**. Captions are readable and nothing important sits under the app's buttons
- [ ] Spelling: "The Scariest Funny Movie this year!" and "CampDuval.com"
- [ ] End card shows only "Available on CampDuval.com" + iTunes/Apple + Amazon logos
- [ ] No "AIN'T NOBODY DYING TODAY", no knife/cleaver graphics, no made-up reviews
- [ ] No commercial music
- [ ] Listen to the last 2 seconds and every cut for pops or audio that ends too early
- [ ] Step through the last frames: no black flash or stray frame before or after the card
- [ ] It plays in a browser and on a phone straight away

## Full example
```bash
scripts/trim.sh source.mp4 2 14 01.mp4
scripts/vertical.sh 01.mp4 02.mp4
python3 scripts/make_caption.py cap.png "THE SCARIEST FUNNY|MOVIE THIS YEAR!" --bar "OUT NOW"
scripts/burn_caption.sh 02.mp4 cap.png 03.mp4 1 11
scripts/add_endcard.sh 03.mp4 assets/endcard_available_on_campduval.png 04.mp4 3
scripts/export.sh 04.mp4 campduval-clip
scripts/qc.sh campduval-clip-1080x1920.mp4
```

## Licenses
The fonts (Oswald, Archivo Black) are from Google Fonts under the SIL Open Font License. The iTunes/Apple and Amazon logos are their owners' trademarks. Only use them to show where the film is available.
