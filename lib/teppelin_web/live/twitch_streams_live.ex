defmodule TeppelinWeb.TwitchStreamsLive do
  use Phoenix.LiveView

  def render(assigns) do
    TeppelinWeb.LiveStreamsView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    IO.puts "mount"
    if connected?(socket) do
      TeppelinWeb.Endpoint.subscribe("twitch")
    end
    {:ok, init_data(socket) }
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "live_streams", topic: "twitch", payload: %{streams: streams}}, socket) do
    IO.puts "TeppelinWeb.TwitchStreamsLive.handle_info 1 #{length(streams)}"
    {:noreply, 
     assign(socket, 
           streams: streams, streams_count: length(streams))}
  end

  # def handle_info({:search_streams, search_term}, socket) do
  #    IO.puts "TeppelinWeb.TwitchStreamsLive.handle_info 2"
  #   Teppelin.TwitchTV.search_streams(search_term)
  #   {:noreply, assign(socket, search_term: search_term)}
  # end

  def handle_info(:search, socket = %{assigns: %{search_term: search_term}}) do
    IO.puts "TeppelinWeb.TwitchStreamsLive.handle_info #{search_term}"
    Teppelin.TwitchTV.search_streams(search_term)
    {:noreply, assign(socket, loading: false)}
  end


  def handle_event("search", %{"value" => search_term}, socket = %{ assigns: %{ loading: false }}) do
    IO.puts "loaiding = false"
    timer_ref = Process.send_after(self(), :search, 1000)
    {:noreply, 
      assign(socket, 
             search_term: search_term,
             timer_ref: timer_ref,
             loading: true) }
  end

  def handle_event("search",  %{"value" => search_term}, %{assigns: %{loading: true}} = socket) do
    IO.puts "loaiding = true"
    {:noreply,
     assign(socket, search_term: search_term )}
  end

  def handle_event("search", _params, socket) do
    IO.puts "facepalm"
    System.halt(0)
    {:noreply, socket}
  end


  defp init_data(socket) do
    IO.puts "TeppelinWeb.TwitchStreamsLive.init_data: #{inspect socket.assigns}"
    assign(socket,
           search_term: nil, 
           streams: [],
           loading: false,
           timer_ref: nil,
           streams_count: 0)
  end


end