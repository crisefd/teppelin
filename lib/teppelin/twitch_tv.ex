defmodule Teppelin.TwitchTV do
  # use GenServer, restart: :transient

  @base_url Application.get_env(:teppelin, :twitch_base_url)
  @client_id Application.get_env(:tepplin, :twitch_client_id)

  #def start_link(_) do
 #   GenServer.start_link(__MODULE__, :no_args)
 # end

   def get_live_streams(pid, search_term) do
    full_url = "#{@base_url}/streams?stream_type=live"
    headers = ["Client-ID": @client_id,
               "User-Agent": "Teppelin app"]
    #GenServer.cast(__MODULE__, {full_url, headers, search_term, pid})
    IO.puts "base_url: #{@base_url} | client_id: #{@client_id}"
    {:ok, streams} = get(full_url, headers, :eager)
    IO.puts "get_live_streams: #{inspect streams}"
    send(pid, {:live_streams, streams |> filter_streams(search_term)})
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

 # def init(:no_args) do
   # {:ok, nil}
  #end

 # def handle_call({full_url, headers, search_term , pid}, from, _state) do
  #  {:ok, streams} = get(full_url, headers, :eager)
  #  send(pid,
  #      {:live_streams, streams |> filter_streams(search_term)})
 #   {:noreply, streams}
 # end

  def handle_cast({full_url, headers, search_term , pid}, _state) do
    IO.puts "handle_cast"
     {:ok, streams} = get(full_url, headers, :eager)
      send(pid,
        {:live_streams, streams |> filter_streams(search_term)})
      IO.inspect streams
      {:noreply, streams}
  end


  # defp get(url, headers, to_pid, :lazy) do
  #   Stream.resource(
  #     fn ->  # start_fun
  #       HTTPoison.get!(url, headers, %{},
  #                      [stream_to: self(), async: :once])
  #     end,
  #     fn %HTTPoison.AsyncResponse{id: id} = resp -> # next_fun
  #       receive do
  #         %HTTPoison.AsyncStatus{id: ^id, code: code} ->
  #           HTTPoison.stream_next(resp)
  #           {[], resp}

  #         %HTTPoison.AsyncHeaders{id: ^id, headers: headers} ->
  #           HTTPoison.stream_next(resp)
  #           {[], resp}

  #         %HTTPoison.AsyncChunk{id: ^id, chunk: chunk} ->
  #           HTTPoison.stream_next(resp)
  #           {[chunk], resp}

  #         %HTTPoison.AsyncEnd{id: ^id} ->
  #           {:halt, resp}
  #        after
  #           5_000 -> raise "receive timeout"
  #       end
  #     end,
  #     fn resp -> # end_fun
  #       :hackney.stop_async(resp.id) 
  #     end
  #     )
  # end

  defp get(url, headers, :eager) do
    HTTPoison.get(url, headers)
    |> handle_response(:eager)
  end

  defp handle_response({:ok,
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