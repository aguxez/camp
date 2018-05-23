defmodule CampWeb.RoomChannel do
  @moduledoc false

  use Phoenix.Channel

  require IEx

  alias Camp.Streamer

  def join("room:lobby", _msg, socket) do
    {:ok, socket}
  end

  def handle_in("song", %{"body" => song_id}, socket) do
    chunk = Streamer.get_song(song_id).chunk

    push(socket, "song", %{chunk: chunk})

    {:noreply, socket}
  end
end
