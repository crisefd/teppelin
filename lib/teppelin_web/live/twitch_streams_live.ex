defmodule TeppelinWeb.TwitchStreamsLive do
  use Phoenix.LiveView

  def render(assigns) do
    TeppelinWeb.TwitchStreamsView.render("index.html", assigns)
  end

  def mount(session, socket) do
    twitch_pid 
      = Process.spawn(Teppelin.TwitchTV, 
                      :get_live_streams, [self()], [:link])
    {:ok, assign(socket, twitch_pid: twitch_pid)}
  end

  def handle_info({:live_streams, streams}, socket) do
    {:noreply, assign(socket, streams: streams)}
  end

end