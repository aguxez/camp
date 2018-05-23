defmodule Camp.Streamer do
  @moduledoc false

  use GenServer

  alias Porcelain.Process, as: Proc

  @yt_dl "/usr/bin/youtube-dl"

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: :streamer)
  end

  def stream(video) do
    GenServer.call(:streamer, {:stream, video}, 120_000)
  end

  def get_song(id) do
    GenServer.call(:streamer, {:get_song, id})
  end

  def s, do: GenServer.call(:streamer, :s)

  def init(state) do
    schedule_clean()

    {:ok, state}
  end

  defp schedule_clean do
    Process.send_after(self(), :clean, 60_000 * 40)
  end

  def handle_info(:clean, _state) do
    schedule_clean()

    {:noreply, %{}}
  end

  def handle_call(:s, _from, s), do: {:reply, s, s}

  def handle_call({:stream, video}, _from, state) do
    id = video.video_id
    url = "https://www.youtube.com/watch?v=" <> id
    data_map = %{title: video.title, chunk: ""}

    case Map.has_key?(state, video.video_id) do
      true ->
        {:reply, state[id][:chunk], state}

      false ->
        data = do_stream(url)
        new_state = Map.put(data_map, :chunk, data)

        {:reply, data, Map.merge(state, %{id => new_state})}
    end
  end

  def handle_call({:get_song, id}, _from, state) do
    {:reply, Map.get(state, id), state}
  end

  def do_stream(url) do
    IO.inspect("DO STREAM")

    %Proc{out: youtube} =
      Porcelain.spawn(
        @yt_dl,
        [
          "-q", "-f", "249",
          "--audio-quality", "8",
          "-o", "-", url
        ],
        out: :stream
      )

    youtube
    |> Enum.join()
    |> Base.encode64()
  end
end
