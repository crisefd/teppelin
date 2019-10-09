defmodule TeppelinWeb.PageController do
  use TeppelinWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
