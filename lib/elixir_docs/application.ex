defmodule HexDocs.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {HexDocs.View, []}
    ]

    opts = [strategy: :one_for_one, name: HexDocs.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
