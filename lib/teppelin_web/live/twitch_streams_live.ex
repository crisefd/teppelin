defmodule TeppelinWeb.TwitchStreamsLive do
  use Phoenix.LiveView

  def render(assigns) do
    TeppelinWeb.TwitchStreamsView.render("index.html", assigns)
  end

  def mount(session, socket) do
    twitch_pid 
      = Process.spawn(Teppelin.TwitchTV, 
                      :get_live_streams, [self()], [:link])
    {:ok, assign(socket, twitch_pid: twitch_pid, search_term: "")}
  end

  def handle_info({:live_streams, streams}, socket = %{ assigns: %{ search_term: search_term} }) do
    filtered_streams = streams |> Teppelin.TwitchTV.filter_streams(search_term)
    {:noreply, assign(socket, streams: filtered_streams)}
  end

   def handle_event("search", %{"search_term" => search_term}, socket) do
     {:noreply, assign(socket,  search_term: search_term)}
   end

end