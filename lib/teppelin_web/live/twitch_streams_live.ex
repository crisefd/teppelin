defmodule TeppelinWeb.TwitchStreamsLive do
  use Phoenix.LiveView

  def render(assigns) do
    TeppelinWeb.LiveStreamsView.render("index.html", assigns)
  end

  def mount(_session, socket) do
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

  def handle_info({:search_streams, search_term}, socket) do
     IO.puts "TeppelinWeb.TwitchStreamsLive.handle_info 2"
    Teppelin.TwitchTV.search_streams(search_term)
    {:noreply, assign(socket, search_term: search_term)}
  end

  def handle_info(nil, socket) do
    IO.puts "hello world"
    {:noreply, socket}
  end

  def handle_params(%{"query" => q} = _params, _uri, socket) do
     send(self(), {:search_streams, q})
     {:noreply, assign(socket,  search_term: q)}
  end

   def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end
 
  def handle_event("search", %{"query" => q}, socket) do
    send(self(), {:search_streams, q})
    {:noreply, assign(socket,  search_term: q)}
  end

  def handle_event("search", _, socket) do
    IO.puts "Hola mundo"
    {:noreply, socket}
  end

  defp init_data(socket) do
    IO.puts "TeppelinWeb.TwitchStreamsLive.init_data: #{inspect socket.assigns}"
    assign(socket,
           search_term: nil, 
           streams: [],
           streams_count: 0)
  end


end