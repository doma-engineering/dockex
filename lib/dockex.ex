defmodule Dockex do
  @moduledoc """
  Infrastrucutre as code for working with docker.

  Args for httpie:

   - :verbose
   - :network (docker network in which to execute)
   - :method (GET / POST supported)
  """

  alias Uptight.Text, as: T
  alias Uptight.Result

  alias Ubuntu
  alias Ubuntu.Command, as: Cmd
  alias Ubuntu.Path, as: P

  import Witchcraft.Functor

  @spec httpie_get(URI.t(), keyword()) :: map | T.t()
  def httpie_get(u, opts) do
    Ubuntu.new(httpie_cmd(u, opts), :no_read, 4000)
    |> Ubuntu.run!()
    |> process_httpie_resp(opts)
  end

  @spec httpie_post(URI.t(), any(), keyword()) :: map | T.t()
  def httpie_post(u, payload_term, opts) do
    cmd = httpie_cmd(u, Keyword.merge(opts, method: "POST"))

    Ubuntu.new(cmd, :no_read, 4000)
    |> Ubuntu.run!(payload_term |> Jason.encode!() |> T.new!())
    |> process_httpie_resp(opts)
  end

  @spec httpie_cmd(URI.t(), keyword()) :: Cmd.t()
  def httpie_cmd(u, opts) do
    Cmd.new!(
      docker(),
      (["run", "-t", "--rm"] ++
         network_maybe(opts) ++
         ["alpine/httpie"] ++
         timeout(opts) ++
         verbosity(opts) ++
         method(opts) ++
         [u |> URI.to_string()])
      |> map(&T.new!/1)
    )
  end

  defp method(opts) do
    (Keyword.has_key?(opts, :method) && [Keyword.get(opts, :method)]) || ["GET"]
  end

  defp timeout(opts) do
    [
      "--timeout",
      Float.to_string(Keyword.get(opts, :timeout, 0.1))
    ]
  end

  defp network_maybe(opts) do
    (Keyword.has_key?(opts, :network) && ["--network", Keyword.get(opts, :network).id.text]) || []
  end

  defp verbosity(opts) do
    (Keyword.has_key?(opts, :verbose) && ["--verbose"]) || ["--pretty=none", "-b"]
  end

  defp process_httpie_resp(resp, opts) do
    raw_resp =
      resp.data
      |> Enum.reduce("", fn x, acc -> acc <> "\n" <> x.text end)
      |> String.trim()

    if Keyword.has_key?(opts, :verbose) do
      IO.puts(raw_resp)
      raw_resp |> T.new!()
    else
      # IO.inspect(raw_resp)
      raw_resp |> Jason.decode!()
    end
  end

  @spec networks() :: Ubuntu.ResponseRun.t()
  def networks() do
    Ubuntu.new(
      Cmd.new!(docker(), ["network", "prune", "--force"] |> map(&T.new!/1)),
      :no_read,
      200
    )
    |> Ubuntu.run!()

    Ubuntu.new(networks_cmd(), :no_read, 200) |> Ubuntu.run!()
  end

  @spec networks_cmd() :: Cmd.t()
  def networks_cmd() do
    Cmd.new!(docker(), ["network", "ls"] |> map(&T.new!/1))
  end

  @spec docker() :: P.t()
  def docker() do
    P.whereis("docker" |> T.new!()) |> Result.from_ok()
  end

  @doc """
  We don't know if this fn complies with docker implementation, it's just evidence and guessing
  """
  @spec normalise_net_id(T.t()) :: T.t()
  def normalise_net_id(x) do
    underscorable = underscorable_chars()

    x
    |> T.un()
    |> String.downcase()
    |> String.split("", trim: true)
    |> Enum.reduce(fn c, acc ->
      if c in underscorable do
        acc <> "_"
      else
        acc <> c
      end
    end)
    |> T.new!()
  end

  defp underscorable_chars() do
    "=/ " |> String.split("", trim: true)
  end
end
