defmodule Teppelin.TwitchTV do

  @base_url Application.get_env(:teppelin, :twitch_base_url)
  @client_id Application.get_env(:tepplin, :twitch_client_id)

  def get_live_streams(pid, game) do
    game = String.capitalize(game)
    full_url = "#{@base_url}/streams?stream_type=live&game=#{game}"
    headers = ["Client-ID": "3arfvc5f6s5s8j1k07rlvoo3a1q3h7",
               "User-Agent": "Teppelin app"]
   {:ok, streams} = get(full_url, headers)
   send(pid, {:live_streams, streams})
  end


  defp get(url, headers, to_pid, :lazy) do
    Stream.resource(
      fn ->  # start_fun
        HTTPoison.get!(url, headers, %{},
                       [stream_to: self(), async: :once])
      end,
      fn %HTTPoison.AsyncResponse{id: id} = resp -> # next_fun
        receive do
          %HTTPoison.AsyncStatus{id: ^id, code: code} ->
            HTTPoison.stream_next(resp)
            {[], resp}

          %HTTPoison.AsyncHeaders{id: ^id, headers: headers} ->
            HTTPoison.stream_next(resp)
            {[], resp}

          %HTTPoison.AsyncChunk{id: ^id, chunk: chunk} ->
            HTTPoison.stream_next(resp)
            {[chunk], resp}

          %HTTPoison.AsyncEnd{id: ^id} ->
            {:halt, resp}
         after
            5_000 -> raise "receive timeout"
        end
      end,
      fn resp -> # end_fun
        :hackney.stop_async(resp.id) 
      end
      )
  end

  defp get(url, headers, to_pid, :eager) do
    HTTPoison.get(url, headers)
    |> handle_response(:eager)
  end

  defp handle_response({:ok,
                        %HTTPoison.Response{status_code: status_code, body: body}},
                        :eager) do
    streams = 
      case check_for_errors(status_code, body) do
        {:error, _} -> []
        data -> data
      end
    {:ok, streams}
  end

  defp check_for_errors(200, body), do: body |> parse_data()
  defp check_for_errors(_, _body), do: {:error, body}

  defp parse_data(data) do
    data
    |> Poison.decode!(keys: :atoms)
    |> Map.get(:streams)
  end

end