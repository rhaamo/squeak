defmodule SqueakWeb.BlogView do
  use SqueakWeb, :view
  use Timex

  def date_format_iso(date) do
    date_format(date, "{ISO:Extended:Z}")
  end

  def date_format(date, format_string \\ "{D} {Mshort} {YYYY}") do
    date
    |> Timex.format!(format_string)
  end

  def unmarkdownize(mdown) do
    Earmark.as_html!(mdown, gfm: true, breaks: false)
    |> raw
  end
end
