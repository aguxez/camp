defmodule CampWeb.PageController do
  @moduledoc false

  use CampWeb, :controller

  alias Camp.Streamer

  plug(:scrub_params, "song" when action in [:send_song])

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def send_song(conn, %{"song" => song}) do
    {:ok, result, _} = TubEx.Video.search(song)

    result
    |> hd()
    |> Streamer.stream()

    conn
    |> put_session(:song_id, hd(result).video_id)
    |> put_flash(:success, "Working")
    |> redirect(to: page_path(conn, :song))
  end

  def song(conn, _params) do
    song_id = get_session(conn, :song_id)
    song_title = Streamer.get_song(song_id)

    case song_title do
      nil ->
        redirect(conn, to: "/")

      song ->
        render(conn, "song.html", song_id: song_id, song_title: song.title)
    end

  end
end
