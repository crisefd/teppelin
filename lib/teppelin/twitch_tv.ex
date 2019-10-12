defmodule Teppelin.TwitchTV do

  @me TwitchTV
  @base_url Application.get_env(:teppelin, :twitch_base_url)
  @client_id Application.get_env(:teppelin, :twitch_client_id)
  @api_version Application.get_env(:teppelin, :api_version)
  @timeout 15_000

   def get_live_streams(pid, search_term) do
    full_url = "#{@base_url}/streams?stream_type=live"
    headers = ["Client-ID": @client_id,
               "Accept": @api_version,
               "User-Agent": "Teppelin app"]
    {:ok, streams} = get(full_url, headers, :eager)
    streams = streams |> filter_streams(search_term)
    IO.puts "#results lenght: {length(streams)}"
    IO.puts "PID: #{inspect pid}"
    send(pid, {:live_streams, streams})
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