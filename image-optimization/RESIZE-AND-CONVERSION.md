## Image Conversion

First we use `convert` or magick` to resize and crop the image to the size we need

```sh

convert pexels-chloekalaartist-1043473.jpg \
  -resize 500x500^ \
  -gravity center \
  -crop 400x400+0-100 \
  -quality 90 \
  temp-output.jpg
WARNING: The convert command is deprecated in IMv7, use "magick" instead of "convert" or "magick convert"
```

Then we convert the image to webP

```sh
cwebp -q 85 temp-output.jpg -o avatar-4.webp
Saving file 'avatar-4.webp'
File:      temp-output.jpg
Dimension: 400 x 400
Output:    27150 bytes Y-U-V-All-PSNR 42.44 45.81 45.19   43.24 dB
           (1.36 bpp)
block count:  intra4:        581  (92.96%)
              intra16:        44  (7.04%)
              skipped:         0  (0.00%)
bytes used:  header:            193  (0.7%)
             mode-partition:   3107  (11.4%)
 Residuals bytes  |segment 1|segment 2|segment 3|segment 4|  total
    macroblocks:  |       3%|      16%|      48%|      32%|     625
      quantizer:  |      20 |      17 |      14 |      11 |
   filter level:  |       7 |       4 |       2 |       0 |
stat -f%z avatar-4.webp  2>/dev/null | awk '{printf "%.1fKB\n", $1/1024}'
26.5KB
```