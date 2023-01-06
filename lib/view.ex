defmodule HexDocs.View do
  use GenServer, restart: :transient
  require Logger
  @title "Hex Docs"
  @size {1200, 800}

  defstruct [:webview, :frame, :terminal, bindings: []]

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    ctx = :wx.new()

    frame = :wxFrame.new(ctx, -1, @title, size: @size)

    # Set views
    webview = :wxWebView.new(frame, -1, url: 'https://hexdocs.pm/')

    # https://hokein.github.io/wxWidgets/textctrl_8h.html#af988f6550f22c211df70544355aed667
    terminal = :wxTextCtrl.new(frame, -1, style: 0x0020)

    # Set event handlers
    :wxFrame.connect(frame, :size)
    :wxFrame.connect(frame, :close_window)
    :wxTextCtrl.connect(terminal, :char)

    # Show window
    :wxFrame.center(frame)
    :wxFrame.show(frame)

    {:ok, %__MODULE__{webview: webview, terminal: terminal, frame: frame}}
  end

  def handle_info({:wx, _, frame, _, {:wxClose, :close_window}}, state) do
    :wxFrame.destroy(frame)
    :wx.destroy()
    :init.stop()
    {:stop, :normal, state}
  end

  def handle_info(
        {:wx, _, _frame, _, {:wxSize, :size, {x, y}, _}},
        %{webview: webview, terminal: terminal} = state
      ) do
    :wxWebView.setSize(webview, {round(x / 2), 0, round(x / 2), y})
    :wxTextCtrl.setSize(terminal, {round(x / 2), y})
    {:noreply, state}
  end

  def handle_info({:wx, _, terminal, _, evt}, %{bindings: bindings} = state)
      when elem(evt, 1) == :char and elem(evt, 4) == 13 do
    line = :wxTextCtrl.getNumberOfLines(terminal) - 1

    {result, new_bindings} =
      terminal
      |> :wxTextCtrl.getLineText(line)
      |> then(&"#{&1}")
      |> String.trim()
      |> Code.eval_string(bindings)

    :wxTextCtrl.appendText(terminal, ['\n', String.to_charlist(inspect(result)), '\n'])

    {:noreply, %{state | bindings: Keyword.merge(new_bindings, bindings)}}
  end

  def handle_info({:wx, _, terminal, _, evt}, state) when elem(evt, 1) == :char do
    keyCode = elem(evt, 4)
    :wxTextCtrl.writeText(terminal, [keyCode])
    {:noreply, state}
  end

  def handle_info(_event, state) do
    {:noreply, state}
  end
end
