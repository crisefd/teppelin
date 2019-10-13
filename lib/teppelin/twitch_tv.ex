defmodule Teppelin.TwitchTV do

  use GenServer 

  @base_url Application.get_env(:teppelin, :twitch_base_url)
  @client_id Application.get_env(:teppelin, :twitch_client_id)
  @api_version Application.get_env(:teppelin, :api_version)
  @timeout 6_000
  @me TwitchTV

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: @me)
  end

  def search_streams(search_term) do
    IO.puts "Teppelin.TwitchTV.search_streams #{search_term}"
    GenServer.call(@me, {:search_streams, search_term})
  end

  
  def init([]) do
    IO.puts "Teppelin.TwitchTV.init"
    streams =  get_live_streams_aux()
    TeppelinWeb.Endpoint.broadcast_from(self(), "twitch", "live_streams", %{streams: streams}) 
    {:ok, 
     %{ streams: streams,
        search_term: nil}, 
     @timeout }
  end

  def handle_info(:timeout, %{search_term: search_term}) do
    IO.puts "Teppelin.TwitchTV.handle_info 1 #{search_term}"
    streams = get_live_streams_aux()
    if search_term == nil do
       TeppelinWeb.Endpoint.broadcast_from(self(), "twitch", "live_streams", %{streams: streams})
    else
       TeppelinWeb.Endpoint.broadcast_from(self(), "twitch", "live_streams", %{streams: streams |> filter_streams(search_term)})
    end 
   
    {:noreply, %{ streams: streams,
                  search_term: search_term}, 
      @timeout}
  end

  # def handle_info(:timeout, %{streams: streams, search_term: search_term} = state) do
  #      IO.puts "Teppelin.TwitchTV.handle_info 2 #{search_term}"
  #     streams = 
  #       cond do
  #         search_term == nil -> get_live_streams_aux()
  #           true -> get_live_streams_aux() |> filter_streams(search_term)
  #       end
  #     TeppelinWeb.Endpoint.broadcast_from(self(), "twitch", "live_streams", %{streams: streams}) 
  #    {:noreply, state, @timeout}
  # end

  def handle_call({:search_streams, search_term}, _from, %{streams: streams}) do
    filtered_streams =  streams |> filter_streams(search_term)
    IO.puts "Teppelin.TwitchTV.handle_cast search_term : #{search_term} size: #{length(filtered_streams)}"
    TeppelinWeb.Endpoint.broadcast_from(self(), "twitch", "live_streams", %{streams: filtered_streams}) 
    {:reply, streams, %{ streams: streams, search_term: search_term }} 
  end

  def handle_call(_, _from, state) do
    IO.puts "facepalm #{inspect state}"
    {:reply, nil,  state}
  end

   defp get_live_streams_aux() do
    full_url = "#{@base_url}/streams?stream_type=live"
    headers = ["Client-ID": @client_id,
               "Accept": @api_version,
               "User-Agent": "Teppelin app"]
    {:ok, streams} = get(full_url, headers, :eager)
    streams 
  end

  defp filter_streams(streams, nil), do: streams

  defp filter_streams(streams, search_term) do
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