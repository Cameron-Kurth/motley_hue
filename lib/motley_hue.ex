defmodule MotleyHue do
  @moduledoc """
  An Elixir utility for calculating the following color combinations:
  * Complimentary - Two colors that are on opposite sides of the color wheel
  * Analagous - Three colors that are side by side on the color wheel
  * Monochromatic - A spectrum of shades, tones and tints of one base color
  * Triadic - Three colors that are evenly spaced on the color wheel
  * Tetradic - Four colors that are evenly spaced on the color wheel
  """

  @doc """
  Returns the provided color and its two analagous (adjacent) colors along a given direction of the HSV color wheel.
  Adjacency is defined by a 30° offset in hue value and an analogous set must reside within a 90° section of the color wheel.

  ## Examples

      iex> MotleyHue.analagous("FF0000")
      ["FF0000", "FF8000", "FFFF00"]

      iex> MotleyHue.analagous("FF0000", :counter_clockwise)
      ["FF0000", "FF0080", "FF00FF"]

  """
  @spec analagous(binary | map, :clockwise | :counter_clockwise) :: list | {:error, binary}
  def analagous(color, direction \\ :clockwise)

  def analagous(color, direction) when direction in [:clockwise, :counter_clockwise] do
    base = Chameleon.convert(color, Chameleon.HSV)

    case base do
      {:error, err} ->
        {:error, err}

      base ->
        1..2
        |> Enum.map(fn i ->
          hue_offset = i * 30

          hue =
            case direction do
              :clockwise ->
                calculate_degree(base.h + hue_offset)

              :counter_clockwise ->
                calculate_degree(base.h - hue_offset)
            end

          Chameleon.HSV.new(hue, base.s, base.v)
        end)
        |> then(&format_response(color, &1))
    end
  end

  @doc """
  Returns the provided color and its compliment.
  Note that complimentary color can be calculated by either taking the value 180° (i.e., opposite) from the hue value on the HSV color wheel
  or by finding the RGB value that when combined with the provided color will yield white (i.e., rgb(255, 255, 255)).
  The default approach is to use the HSV hue offset, but either can be calculated by passing `:hsv` or `:rgb` as the model argument.

  ## Examples

      iex> MotleyHue.complimentary("FF0000")
      ["FF0000", "00FFFF"]

      iex> MotleyHue.complimentary("008080", :hsv)
      ["008080", "800000"]

      iex> MotleyHue.complimentary("008080", :rgb)
      ["008080", "FF7F7F"]

  """
  @spec complimentary(binary | map, :hsv | :rgb) :: list | {:error, binary}
  def complimentary(color, model \\ :hsv)

  def complimentary(color, :hsv) do
    even(color, 2)
  end

  def complimentary(color, :rgb) do
    base = Chameleon.convert(color, Chameleon.RGB)

    case base do
      {:error, err} ->
        {:error, err}

      base ->
        compliment = Chameleon.RGB.new(255 - base.r, 255 - base.g, 255 - base.b)

        format_response(color, [compliment])
    end
  end

  @doc """
  Returns the requested count of colors, including the provided color, distributed along the color wheel.
  Ideal for use as color palette where adjacent colors need to be easily differentiated with one another (e.g., categorical or other non-quantitative data).

  ## Examples

      iex> MotleyHue.contrast("FF0000", 7)
      ["FF0000", "FFFF00", "00FF00", "00FFFF", "0000FF", "FF00FF", "FF8000"]

      iex> MotleyHue.contrast("FF0000", 13)
      ["FF0000", "FFFF00", "00FF00", "00FFFF", "0000FF", "FF00FF", "FF8000", "80FF00", "00FF80", "0080FF", "8000FF", "FF0080", "FF4000"]

  """
  @spec contrast(binary | map, integer) :: list | {:error, binary}
  def contrast(_color, count) when count < 2,
    do: {:error, "Count must be a positive integer greater than or equal to 2"}

  def contrast(color, count) when count <= 6, do: even(color, count)

  def contrast(color, count) when is_integer(count) do
    base = Chameleon.convert(color, Chameleon.HSV)

    case base do
      {:error, err} ->
        {:error, err}

      base ->
        1..(count - 1)
        |> Enum.map(fn i ->
          div = div(i, 6)

          degree_offset = round(360 / 6)
          base_offset = i * degree_offset
          rotation_offset = -360 * div + safe_divide(degree_offset, 2 * div)
          hue_offset = round(base_offset + rotation_offset)
          hue = calculate_degree(base.h + hue_offset)
          Chameleon.HSV.new(hue, base.s, base.v)
        end)
        |> then(&format_response(color, &1))
    end
  end

  @doc """
  Returns the requested count of colors, including the provided color, evenly spaced along the color wheel.

  ## Examples

      iex> MotleyHue.even("FF0000", 5)
      ["FF0000", "CCFF00", "00FF66", "0066FF", "CC00FF"]

  """
  @spec even(binary | map, integer) :: list | {:error, binary}
  def even(_color, count) when count < 2,
    do: {:error, "Count must be a positive integer greater than or equal to 2"}

  def even(color, count) when is_integer(count) do
    base = Chameleon.convert(color, Chameleon.HSV)

    case base do
      {:error, err} ->
        {:error, err}

      base ->
        degree_offset = round(360 / count)

        1..(count - 1)
        |> Enum.map(fn i ->
          hue_offset = i * degree_offset
          hue = calculate_degree(base.h + hue_offset)
          Chameleon.HSV.new(hue, base.s, base.v)
        end)
        |> then(&format_response(color, &1))
    end
  end

  @doc """
  Returns a gradient of the size of the provided count bookended by the two provided colors.

  ## Examples

      iex> MotleyHue.gradient("FF0000", "008080", 5)
      ["FF0000", "DF00A7", "6000BF", "00289F", "008080"]

  """
  @spec gradient(binary | map, binary | map, integer) :: list | {:error, binary}
  def gradient(_color1, _color2, count) when count < 3,
    do: {:error, "Count must be a positive integer greater than or equal to 3"}

  def gradient(color1, color2, count) when is_integer(count) do
    base1 = Chameleon.convert(color1, Chameleon.HSV)
    base2 = Chameleon.convert(color2, Chameleon.HSV)

    case {base1, base2} do
      {{:error, err}, _} ->
        {:error, err}

      {_, {:error, err}} ->
        {:error, err}

      {base1, base2} ->
        hue_diff = base1.h - base2.h
        saturation_diff = base1.s - base2.s
        value_diff = base1.v - base2.v

        hue_degree_offset = hue_diff |> safe_divide(count - 1)
        saturation_percent_offset = saturation_diff |> safe_divide(count - 1)
        value_percent_offset = value_diff |> safe_divide(count - 1)

        1..(count - 2)
        |> Enum.map(fn i ->
          hue_offset = i * hue_degree_offset
          hue = calculate_degree(base1.h + hue_offset)

          saturation_offset = i * saturation_percent_offset
          saturation = base1.s - saturation_offset

          value_offset = i * value_percent_offset
          value = base1.v - value_offset

          Chameleon.HSV.new(hue, saturation, value)
        end)
        |> then(&format_response(color1, color2, &1))
    end
  end

  @doc """
  Returns the provided color and its monochromatic color spectrum towards black.
  The number of results is configurable with each color equally spaced from the previous value.

  ## Examples

      iex> MotleyHue.monochromatic("FF0000")
      ["FF0000", "AB0000", "570000"]

      iex> MotleyHue.monochromatic("FF0000", 5)
      ["FF0000", "CC0000", "990000", "660000", "330000"]

  """
  @spec monochromatic(binary | map, integer) :: list | {:error, binary}
  def monochromatic(color, count \\ 3)

  def monochromatic(_color, count) when count < 2,
    do: {:error, "Count must be a positive integer greater than or equal to 2"}

  def monochromatic(color, count) when is_integer(count) do
    base = Chameleon.convert(color, Chameleon.HSV)

    case base do
      {:error, err} ->
        {:error, err}

      base ->
        step = div(100, count)

        Range.new(0, 100, step)
        |> Enum.slice(1..(count - 1))
        |> Enum.map(fn value_offset ->
          value = round(base.v - value_offset)
          Chameleon.HSV.new(base.h, base.s, value)
        end)
        |> then(&format_response(color, &1))
    end
  end

  @doc """
  Returns the provided color and its three tetradic colors, which are the colors 90°, 180°, and 270° offset from the given color's hue value on the HSV color wheel.

  ## Examples

      iex> MotleyHue.tetradic("FF0000")
      ["FF0000", "80FF00", "00FFFF", "8000FF"]

  """
  @spec tetradic(binary | map) :: list | {:error, binary}
  def tetradic(color) do
    even(color, 4)
  end

  @doc """
  Returns the provided color and its two triadic colors, which are the colors 120° and 240° offset from the given color's hue value on the HSV color wheel.

  ## Examples

      iex> MotleyHue.triadic("FF0000")
      ["FF0000", "00FF00", "0000FF"]

  """
  @spec triadic(binary | map) :: list | {:error, binary}
  def triadic(color) do
    even(color, 3)
  end

  defp calculate_degree(degree) when degree >= 0, do: degree |> round() |> rem(360)
  defp calculate_degree(degree), do: degree |> round() |> then(&(360 + rem(&1, 360)))

  defp format_response(color, matches) when is_struct(color) do
    [color]
    |> Kernel.++(matches)
    |> Enum.map(&Chameleon.convert(&1, color.__struct__))
  end

  defp format_response(color, matches) when is_binary(color) do
    case Chameleon.Util.derive_input_struct(color) do
      {:ok, %Chameleon.Hex{} = derived_color} ->
        case color do
          "#" <> _ -> derived_color |> format_response(matches) |> Enum.map(&"##{&1.hex}")
          _ -> derived_color |> format_response(matches) |> Enum.map(& &1.hex)
        end

      {:ok, derived_color} ->
        format_response(derived_color, matches)

      {:error, err} ->
        {:error, err}
    end
  end

  defp format_response(color1, color2, matches) when is_struct(color1) do
    [color1]
    |> Kernel.++(matches)
    |> Kernel.++([color2])
    |> Enum.map(&Chameleon.convert(&1, color1.__struct__))
  end

  defp format_response(color1, color2, matches) when is_binary(color2) do
    case Chameleon.Util.derive_input_struct(color2) do
      {:ok, %Chameleon.Hex{} = derived_color2} ->
        format_response(color1, derived_color2, matches)

      {:ok, derived_color2} ->
        format_response(color1, derived_color2, matches)

      {:error, err} ->
        {:error, err}
    end
  end

  defp format_response(color1, color2, matches) when is_binary(color1) do
    case Chameleon.Util.derive_input_struct(color1) do
      {:ok, %Chameleon.Hex{} = derived_color1} ->
        case color1 do
          "#" <> _ ->
            format_response(derived_color1, color2, matches) |> Enum.map(&"##{&1.hex}")

          _ ->
            format_response(derived_color1, color2, matches) |> Enum.map(& &1.hex)
        end

      {:ok, derived_color1} ->
        format_response(derived_color1, color2, matches)

      {:error, err} ->
        {:error, err}
    end
  end

  defp safe_divide(_, 0), do: 0
  defp safe_divide(num, dem), do: num / dem
end
