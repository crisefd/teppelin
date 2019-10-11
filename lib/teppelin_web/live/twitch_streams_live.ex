defmodule TeppelinWeb.TwitchStreamsLive do
  use Phoenix.LiveView

  def render(assigns) do
   ~L"""
    <div id="cover">
      <form method="get" action="" phx-submit="search">
        <div class="tb">
          <div class="td">
            <input type="text" placeholder="Search" name="query" required></div>
          <div class="td" id="s-cover">
            <button type="submit" >
              <div id="s-circle"></div>
              <span></span>
            </button>
          </div>
        </div>
      </form>
    </div>
  """
  # TeppelinWeb.LiveStreamsView.render("index.html", assigns)
  end

  def mount(_session, socket) do
     _pid = Process.spawn(Teppelin.TwitchTV, :get_live_streams, [self(), nil], [:link])
    {:ok, assign(socket, search_term: "", streams: [])}
  end

  def handle_info({:live_streams, streams}, socket) do
   # filtered_streams = streams |> Teppelin.TwitchTV.filter_streams(search_term)
   IO.puts "handle_info"
   IO.inspect streams
    {:noreply, assign(socket, streams: streams)}
  end

  def handle_event("search", %{"q" => q}, socket = %{assigns: %{streams: streams}}) do
    IO.puts "q #{q}"
    streams = streams |> Teppelin.TwitchTV.filter_streams(q)
    IO.inspect streams
    {:noreply, assign(socket,  search_term: q)}
  end

end