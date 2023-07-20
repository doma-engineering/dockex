defmodule Dockex.Network do
  @moduledoc """
  Algebraic data type to store information about docker networks.

  NETWORK ID     NAME         DRIVER    SCOPE
  """
  import Algae
  import Witchcraft.Functor

  alias Uptight.Text, as: T
  alias Uptight.Base, as: B

  # TODO: lol, actually enumerate the drivers as atoms
  defdata do
    id :: T.t() \\ T.new!("")
    name :: T.t() \\ T.new!("")
    driver :: T.t() \\ T.new!("bridge")
    scope :: T.t() \\ T.new!("local")
  end

  @spec from_text!(T.t()) :: __MODULE__.t()
  def from_text!(x) do
    {:ok, args, _, _, _, _} = x |> T.un() |> Dockex.ParserNetwork.parse()
    apply(__MODULE__, :new, args |> map(&T.new!/1))
  end

  @spec ls! :: list(__MODULE__.t())
  def ls!() do
    Dockex.networks().data |> tl() |> Enum.map(&from_text!/1)
  end

  @spec by_pk!(B.Urlsafe.t()) :: __MODULE__.t() | nil
  def by_pk!(pk), do: by_pk(pk, ls!())

  @spec by_pk(B.Urlsafe.t(), list(__MODULE__.t())) :: __MODULE__.t() | nil
  def by_pk(pk, nets \\ []) do
    approximate = pk.encoded |> T.new!() |> Dockex.normalise_net_id() |> T.un()
    [prefix | _] = approximate |> String.split("_", parts: 2)

    Enum.reduce_while(nets, nil, fn x, _acc ->
      if String.starts_with?(x.name |> T.un(), prefix) do
        {:halt, x}
      else
        {:cont, nil}
      end
    end)
  end
end
