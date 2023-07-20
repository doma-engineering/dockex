defmodule Dockex.ParserNetwork do
  @moduledoc """
  Parse a single line of `docker network ls`!

  NETWORK ID     NAME         DRIVER    SCOPE
  """

  import NimbleParsec

  space = choice([string(" "), string("\t")])
  word = utf8_string([not: ?\s, not: ?\t, not: ?\n, not: ?\r], min: 1)
  entry = word |> concat(ignore(repeat(space))) |> repeat()
  defparsec(:parse, entry)
end
