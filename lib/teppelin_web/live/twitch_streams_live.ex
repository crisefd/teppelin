defmodule TeppelinWeb.TwitchStreamsLive do
  use Phoenix.LiveView

  def render(assigns) do
    TeppelinWeb.LiveStreamsView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    if connected?(socket) do
      TeppelinWeb.Endpoint.subscribe("twitch")
    end

    {:ok, init_data(socket)}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{
          event: "live_streams",
          topic: "twitch",
          payload: %{streams: streams}
        },
        socket
      ) do
    {:noreply, assign(socket, streams: streams, streams_count: length(streams))}
  end

  def handle_info(:search, socket = %{assigns: %{search_term: search_term}}) do
    Teppelin.TwitchTV.search_streams(search_term)
    {:noreply, assign(socket, loading: false)}
  end

  def handle_event("search", %{"value" => search_term}, socket = %{assigns: %{loading: false}}) do
    timer_ref = Process.send_after(self(), :search, 1000)

    {:noreply,
     assign(socket,
       search_term: search_term,
       timer_ref: timer_ref,
       loading: true
     )}
  end

  def handle_event("search", %{"value" => search_term}, %{assigns: %{loading: true}} = socket) do
    {:noreply, assign(socket, search_term: search_term)}
  end

  defp init_data(socket) do
    assign(socket,
      search_term: nil,
      streams: [],
      loading: false,
      timer_ref: nil,
      streams_count: 0
    )
  end
end
