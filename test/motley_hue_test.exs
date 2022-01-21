defmodule MotleyHueTest do
  use ExUnit.Case
  doctest MotleyHue

  test "analagous" do
    hsv = Chameleon.HSV.new(0, 100, 100)
    hsv_plus_30 = %{hsv | h: 30}
    hsv_plus_60 = %{hsv | h: 60}
    assert MotleyHue.analagous(hsv) == [hsv, hsv_plus_30, hsv_plus_60]
    assert MotleyHue.analagous(hsv, :clockwise) == [hsv, hsv_plus_30, hsv_plus_60]

    hsv_minus_30 = %{hsv | h: 330}
    hsv_minus_60 = %{hsv | h: 300}
    assert MotleyHue.analagous(hsv, :counter_clockwise) == [hsv, hsv_minus_30, hsv_minus_60]
  end

  test "complimentary" do
    hsv = Chameleon.HSV.new(0, 100, 100)
    hsv_plus_180 = %{hsv | h: 180}
    assert MotleyHue.complimentary(hsv) == [hsv, hsv_plus_180]
    assert MotleyHue.complimentary(hsv, :hsv) == [hsv, hsv_plus_180]
    assert MotleyHue.complimentary(hsv, :rgb) == [hsv, hsv_plus_180]

    rgb = Chameleon.RGB.new(0, 128, 128)
    assert MotleyHue.complimentary(rgb, :hsv) == [rgb, %Chameleon.RGB{r: 128, g: 0, b: 0}]
    assert MotleyHue.complimentary(rgb, :rgb) == [rgb, %Chameleon.RGB{r: 255, g: 127, b: 127}]
  end

  test "monochromatic" do
    hsv = Chameleon.HSV.new(0, 100, 100)
    monochromatic_combination = MotleyHue.monochromatic(hsv, 4)

    assert monochromatic_combination |> Enum.map(& &1.h) == [0, 0, 0, 0, 0]
    assert monochromatic_combination |> Enum.map(& &1.s) == [100, 100, 100, 100, 100]
    assert monochromatic_combination |> Enum.map(& &1.v) == [100, 75, 50, 25, 0]
  end

  test "tetradic" do
    hsv = Chameleon.HSV.new(0, 100, 100)
    tetradic_combination = MotleyHue.tetradic(hsv)

    assert tetradic_combination |> Enum.map(& &1.h) == [0, 90, 180, 270]
    assert tetradic_combination |> Enum.map(& &1.s) == [100, 100, 100, 100]
    assert tetradic_combination |> Enum.map(& &1.v) == [100, 100, 100, 100]
  end

  test "triadic" do
    hsv = Chameleon.HSV.new(0, 100, 100)
    triadic_combination = MotleyHue.triadic(hsv)

    assert triadic_combination |> Enum.map(& &1.h) == [0, 120, 240]
    assert triadic_combination |> Enum.map(& &1.s) == [100, 100, 100]
    assert triadic_combination |> Enum.map(& &1.v) == [100, 100, 100]
  end
end
