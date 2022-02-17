# Mötley Hüe ![](./assets/color-wheel.png)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Hex version badge](https://img.shields.io/hexpm/v/motley_hue.svg)](https://hex.pm/packages/motley_hue)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/motley_hue/)

Mötley Hüe is a small library built on top of [Chameleon](https://hexdocs.pm/chameleon/readme.html) for calculating color combinations.
All color conversion is delegated to Chameleon while Mötley Hüe simply handles the math to determine the following combinations for a given color:
* Complimentary - Two colors that are on opposite sides of the color wheel
* Analagous - Three colors that are side by side on the color wheel
* Monochromatic - A spectrum of shades, tones and tints of one base color
* Triadic - Three colors that are evenly spaced on the color wheel
* Tetradic - Four colors that are evenly spaced on the color wheel
* Even - An arbitrary number of colors that are evenly spaced on the color wheel
* Contrast - An arbitrary number of colors that are distributed around the color wheel for maximum sequential differentiation
* Gradient - A color gradient of arbitrary size

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `motley_hue` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:motley_hue, "~> 0.2"}
  ]
end
```

## Use

While Mötley Hüe is compatible with any struct used in Chameleon, the simplest interface is through hexadecimal color codes.
All results include the given color for ease of use as a ready-to-go color palette.

```elixir
iex> MotleyHue.complimentary("FF0000")
["FF0000", "00FFFF"]

iex> MotleyHue.analagous("FF0000")
["FF0000", "FF8000", "FFFF00"]

iex> MotleyHue.monochromatic("FF0000")
["FF0000", "AB0000", "570000"]

iex> MotleyHue.triadic("FF0000")
["FF0000", "00FF00", "0000FF"]

iex> MotleyHue.tetradic("FF0000")
["FF0000", "80FF00", "00FFFF", "8000FF"]

iex> MotleyHue.even("FF0000", 5)
["FF0000", "CCFF00", "00FF66", "0066FF", "CC00FF"]

iex> MotleyHue.contrast("FF0000", 7)
["FF0000", "FFFF00", "00FF00", "00FFFF", "0000FF", "FF00FF", "FF8000"]

iex> MotleyHue.gradient("FF0000", "008080", 5)
["FF0000", "DF00A7", "6000BF", "00289F", "008080"]
```

If you're using Chameleon directly, then Mötley Hüe will return your color combinations with the same struct definition it was given.

```elixir
iex> Chameleon.RGB.new(255, 0, 0) |> MotleyHue.complimentary()
[%Chameleon.RGB{b: 0, g: 0, r: 255}, %Chameleon.RGB{b: 255, g: 255, r: 0}]
```
