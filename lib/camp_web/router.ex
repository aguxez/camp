defmodule CampWeb.Router do
  use CampWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", CampWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/song", PageController, :song)
    post("/retrieve_song", PageController, :send_song)
  end

  # scope "/api", CampWeb do
  #   pipe_through :api
  # end

  # Other scopes may use custom stacks.
  # scope "/api", CampWeb do
  #   pipe_through :api
  # end
end
