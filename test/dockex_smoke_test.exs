defmodule UptightTest do
  @moduledoc """
  Tests for tight stuff.
  """
  use ExUnit.Case

  test "dockex works" do
    networks = Dockex.networks().data

    assert networks |> hd() == %Uptight.Text{text: "NETWORK ID     NAME      DRIVER    SCOPE"},
           "Smokin"
  end
end
