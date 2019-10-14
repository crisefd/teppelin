defmodule Teppelin.TwitchTV do
  use GenServer

  @base_url Application.get_env(:teppelin, :twitch_base_url)
  @client_id Application.get_env(:teppelin, :twitch_client_id)
  @api_version Application.get_env(:teppelin, :api_version)
  @timeout 5_000
  @me TwitchTV

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: @me)
  end

  def search_streams(search_term) do
    GenServer.cast(@me, {:search_streams, search_term})
  end

  def init([]) do
    streams = get_live_streams()
    TeppelinWeb.Endpoint.broadcast_from(self(), "twitch", "live_streams", %{streams: streams})
    {:ok, %{streams: streams, search_term: nil}, @timeout}
  end

  def handle_info(:timeout, %{search_term: search_term}) do
    streams = get_live_streams()

    if search_term == nil or search_term == "" do
      TeppelinWeb.Endpoint.broadcast_from(self(), "twitch", "live_streams", %{streams: streams})
    else
      TeppelinWeb.Endpoint.broadcast_from(self(), "twitch", "live_streams", %{
        streams: streams |> filter_streams(search_term)
      })
    end
    {:noreply, %{streams: streams, search_term: search_term}, @timeout}
  end

  def handle_cast({:search_streams, search_term}, %{streams: streams}) do
    filtered_streams = streams |> filter_streams(search_term)

    TeppelinWeb.Endpoint.broadcast_from(self(), "twitch", "live_streams", %{
      streams: filtered_streams
    })

    {:noreply, %{streams: streams, search_term: search_term}, @timeout}
  end

  defp get_live_streams() do
    full_url = "#{@base_url}/streams?stream_type=live&limit=100"
    headers = ["Client-ID": @client_id, Accept: @api_version, "User-Agent": "Teppelin app"]
    {:ok, streams} = get(full_url, headers, :eager)
    streams
  end

  defp filter_streams(streams, nil), do: streams

  defp filter_streams(streams, search_term) do
    game = String.capitalize(search_term)
    regex = ~r{#{game}}i

    streams
    |> Enum.filter(fn item ->
      cond do
        Regex.run(regex, item[:game]) == nil -> false
        true -> true
      end
    end)
  end

  defp get(url, headers, :eager) do
    HTTPoison.get(url, headers)
    |> handle_response(:eager)
  end

  defp handle_response(
         {_, %{status_code: status_code, body: body}},
         :eager
       ) do
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
