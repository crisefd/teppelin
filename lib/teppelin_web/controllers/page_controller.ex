defmodule TeppelinWeb.PageController do
  use TeppelinWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
     Phoenix.LiveView.Controller.live_render(conn, TeppelinWeb.TwitchStreamsLive, session: %{})
  end
end
