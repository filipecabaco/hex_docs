defmodule HexDocs.MixProject do
  use Mix.Project

  def project do
    [
      app: :hex_docs,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        baked_hex_doc: [
          steps: [:assemble, &Bakeware.assemble/1],
          strip_beams: Mix.env() == :prod,
          overwrite: true
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :wx],
      mod: {HexDocs.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bakeware, "~> 0.2.4", runtime: false}
    ]
  end

  def release do
    [
      hex_doc: [
        bakeware: [
          compression_level: 1,
          start_command: "start"
        ]
      ]
    ]
  end
end
