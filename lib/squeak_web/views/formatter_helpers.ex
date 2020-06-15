defmodule SqueakWeb.FormatterHelpers do
  use Timex
  import Phoenix.HTML

  def date_format_iso(date) do
    date_format(date, "{ISO:Extended:Z}")
  end

  def date_format(date, format_string \\ "{D} {Mshort} {YYYY}") do
    date
    |> Timex.format!(format_string)
  end

  def unmarkdownize_unsafe(mdown, lines \\ nil) do
    if is_nil(lines) do
      mdown
    else
      mdown
      |> String.split(["\n", "\r", "\r\n"])
      |> Enum.slice(0, lines)
    end
    |> Earmark.as_html!(gfm: true, breaks: false)
  end

  def unmarkdownize(mdown, lines \\ nil) do
    unmarkdownize_unsafe(mdown, lines)
    |> raw
  end

  def is_image(media) do
    String.starts_with?(media.mime, "image/")
  end
end
