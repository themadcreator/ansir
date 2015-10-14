
# ANSIR

Generate UTF-8 Art from PNG using ANSI color codes.

Similar to oldschool ANSI art, we use UTF-8 block characters and standard terminal color escape sequences.

Supports both the basic and extended ANSI color escape sequences. Note: Full 24-bit RGB escape sequences currently not supported.

### Installation

    npm install -g ansir

### Generate artwork

    ansir sample/in.png

### Proportionally rescale the png file on the fly

    ansir --scale 0.1 sample/in.png > sample/out.ans

### Sample

#### Input

![input](sample/in.png?raw=true)

#### Output (10% scale)

![output](sample/out.png?raw=true)

### Usage

```
  Usage: ansir <png>

  Generate UTF-8 Art from PNG using ANSI color codes.

  Options:

    -h, --help                 output usage information
    -s, --scale <float>        Proportionally rescale image
    -w, --width <pixels>       Target output width (in characters)
    -h, --height <pixels>      Target output height (in lines)
    --colors <basic|extended>
          The ANSI colorspace. Use "basic" for the most compatible 8-color
          palette. The default is "extended" for the 256-color palette supported by
          most major terminals that have any color at all.
    --background <light|dark>
          Applies only to "shaded" mode. Specifies whether the target terminal
          will have a light or dark background. This determines color matching for
          shaded UTF-8 block characters. Default is "dark", which means we
          interpret a shaded block character as darker than a solid one.
    --alpha-cutoff <float>
          The minimum alpha value of a pixel that should be converted to a
          ansi color utf-8 block character. Valid values are 0.0-1.0. Default is 0.95.
    --alpha-bleed <integer>
          Applies only to "sub" mode. Adjusts how strongly we fix anti-aliased
          transparency fuzz.
    --mode <block|shaded|sub>
          The rendering mode. Default is "block". The options are:

          "block" - Use the ANSI background escape sequence to create seamless blocks.

          "shaded" - Use the ANSI foreground escape sequence on unicode block character.
            ░ LIGHT SHADE
            ▒ MEDIUM SHADE
            ▓ DARK SHADE
            █ FULL BLOCK

          "sub" - Use the ANSI foreground escape sequence on unicode quadrant
                  block characters. NOTE: These characters can cause slowness when
                  used with some common terminal fonts such as Consolas.
            ▘ QUADRANT UPPER LEFT
            ▝ QUADRANT UPPER RIGHT
            ▖ QUADRANT LOWER LEFT
            ▗ QUADRANT LOWER RIGHT
            ▚ QUADRANT UPPER LEFT AND LOWER RIGHT
            ▞ QUADRANT UPPER RIGHT AND LOWER LEFT
            █ FULL BLOCK
```

### Resources

https://en.wikipedia.org/wiki/ANSI_art

http://ascii-table.com/ansi-escape-sequences.php
