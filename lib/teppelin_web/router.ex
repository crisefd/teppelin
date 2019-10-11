defmodule TeppelinWeb.Router do
  use TeppelinWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_layout, {TeppelinWeb.LayoutView, :app}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TeppelinWeb do
    pipe_through :browser

    # live "/", TwitchStreamsLive

    get "/", PageController, :index
  end


  # Other scopes may use custom stacks.
  # scope "/api", TeppelinWeb do
  #   pipe_through :api
  # end
end