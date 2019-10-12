defmodule TeppelinWeb.TwitchStreamsLive do
  use Phoenix.LiveView

  @base_url Application.get_env(:teppelin, :twitch_base_url)
  @client_id Application.get_env(:teppelin, :twitch_client_id)
  @api_version Application.get_env(:teppelin, :api_version)

  def render(assigns) do
   ~L"""
    <div id="cover">
      <form method="get">
        <div class="tb">
          <div class="td">
            <input type="text" placeholder="Search" name="query" required></div>
          <div class="td" id="s-cover">
            <button phx-click="search" >
              <div id="s-circle"></div>
              <span></span>
            </button>
          </div>
        </div>
      </form>
    </div>

    <div>
    Streams: <%= @streams_count %>
     </div>
  """
  # TeppelinWeb.LiveStreamsView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    {:ok, assign(socket, search_term: nil, streams: [], streams_count: 0)}
  end


  def handle_params(%{"query" => q} = _params, _uri, socket) do
     streams = get_live_streams(q)
     streams_count = length(streams)
      IO.puts "results lenght: #{streams_count}"
     {:noreply, assign(socket,  search_term: q, streams: streams, streams_count: streams_count)}
  end

   def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end
 
  def handle_event("search", %{"query" => q}, socket) do
     IO.puts "query: #{q}"
     streams = get_live_streams(q)
     streams_count = length(streams)
     IO.puts "results lenght: #{streams_count}"
    {:noreply, assign(socket,  search_term: q, streams: streams, streams_count: streams_count)}
  end

  def get_live_streams(search_term) do
    full_url = "#{@base_url}/streams?stream_type=live"
    headers = ["Client-ID": @client_id,
               "Accept": @api_version,
               "User-Agent": "Teppelin app"]
    {:ok, streams} = get(full_url, headers, :eager)
    streams |> filter_streams(search_term)
  end

  def filter_streams(streams, nil), do: streams

  def filter_streams(streams, search_term) do
     game = String.capitalize(search_term)
     regex = ~r{#{game}}i
     streams
     |> Enum.filter( fn item ->
        cond  do
          Regex.run(regex, item[:game]) == nil -> false
          true -> true 
        end
      end)
  end


  defp get(url, headers, :eager) do
    HTTPoison.get(url, headers)
    |> handle_response(:eager)
  end

  defp handle_response({_,
                        %{status_code: status_code, body: body}},
                        :eager) do
    streams = 
      case check_for_errors(status_code, body) do
        {:error, _} -> []
        data -> data
      end
    {:ok, streams}
  end

  defp check_for_errors(200, body), do: body |> parse_data()
  defp check_for_errors(_, body), do: {:error, body}

  defp parse_data(data) do
    data
    |> Poison.decode!(keys: :atoms)
    |> Map.get(:streams)
  end

end