defmodule Codebattle.Tournament.Server do
  use GenServer
  require Logger
  alias Codebattle.Tournament

  import Tournament.Helpers

  @type tournament_id :: pos_integer()

  # API
  def start_link(tournament_id) do
    GenServer.start(__MODULE__, tournament_id, name: server_name(tournament_id))
  end

  def get_tournament(id) do
    try do
      GenServer.call(server_name(id), :get_tournament)
    catch
      :exit, {:noproc, _} ->
        nil

      :exit, reason ->
        Logger.error("Error to get tournament: #{inspect(reason)}")
        nil
    end
  end

  def get_matches(id, player_ids) do
    try do
      GenServer.call(server_name(id), {:get_matches, player_ids})
    catch
      :exit, {:noproc, _} ->
        nil

      :exit, reason ->
        Logger.error("Error to get tournament: #{inspect(reason)}")
        nil
    end
  end

  def update_tournament(tournament) do
    try do
      GenServer.call(server_name(tournament.id), {:update, tournament})
    catch
      :exit, reason ->
        Logger.error("Error to send tournament update: #{inspect(reason)}")
        {:error, :not_found}
    end
  end

  @spec finish_round_after(tournament_id, non_neg_integer(), pos_integer()) ::
          :ok | {:error, :not_found}
  def finish_round_after(tournament_id, round, timeout_in_seconds) do
    try do
      GenServer.call(server_name(tournament_id), {:finish_round_after, round, timeout_in_seconds})
    catch
      :exit, reason ->
        Logger.error("Error to send tournament update: #{inspect(reason)}")
        {:error, :not_found}
    end
  end

  def handle_event(tournament_id, event_type, params) do
    # try do
    GenServer.call(server_name(tournament_id), {event_type, params})
    # catch
    #   :exit, reason ->
    #     Logger.error("Error to send tournament update: #{inspect(reason)}")
    #     {:error, :not_found}
    # end
  end

  # SERVER
  def init(tournament_id) do
    Codebattle.PubSub.subscribe("game:tournament:#{tournament_id}")

    tournament =
      tournament_id
      |> Tournament.Context.get_from_db!()
      |> Tournament.Context.mark_as_live()

    {:ok, %{tournament: tournament}}
  end

  def handle_call({:update, new_tournament}, _from, state) do
    broadcast_tournament_update(new_tournament)
    {:reply, :ok, %{state | tournament: new_tournament}}
  end

  def handle_call({:finish_round_after, round, timeout_in_seconds}, _from, state) do
    Process.send_after(
      self(),
      {:finish_round_force, round},
      :timer.seconds(timeout_in_seconds)
    )

    {:reply, :ok, state}
  end

  def handle_call(:get_tournament, _from, state) do
    {:reply, state.tournament, state}
  end

  def handle_call({:get_matches, player_ids}, _from, state) do
    matches = get_matches_by_players(state.tournament, player_ids)

    {:reply, matches, state}
  end

  def handle_call({event_type, params}, _from, state = %{tournament: tournament}) do
    %{module: module} = tournament

    new_tournament =
      if map_size(params) == 0 do
        apply(module, event_type, [tournament])
      else
        apply(module, event_type, [tournament, params])
      end

    broadcast_tournament_event_by_type(event_type, params, new_tournament)

    {:reply, tournament, Map.merge(state, %{tournament: new_tournament})}
  end

  def handle_info({:stop_round_break, round}, %{tournament: tournament}) do
    if tournament.current_round == round and
         in_break?(tournament) and
         not is_finished?(tournament) do
      new_tournament = tournament.module.stop_round_break(tournament)

      {:noreply, %{tournament: new_tournament}}
    else
      {:noreply, %{tournament: tournament}}
    end
  end

  def handle_info({:finish_round_force, round}, %{tournament: tournament}) do
    if tournament.current_round == round and
         not in_break?(tournament) and
         not is_finished?(tournament) do
      new_tournament = tournament.module.finish_round(tournament)

      broadcast_tournament_update(new_tournament)

      {:noreply, %{tournament: new_tournament}}
    else
      {:noreply, %{tournament: tournament}}
    end
  end

  def handle_info({:start_rematch, match_ref, round}, %{tournament: tournament}) do
    if tournament.current_round == round and
         not in_break?(tournament) and
         not is_finished?(tournament) do
      new_tournament = tournament.module.start_rematch(tournament, match_ref)

      broadcast_tournament_update(new_tournament)

      {:noreply, %{tournament: new_tournament}}
    else
      {:noreply, %{tournament: tournament}}
    end
  end

  def handle_info(
        %{
          topic: "game:tournament:" <> _t_id,
          event: "game:tournament:finished",
          payload: payload
        },
        %{tournament: tournament}
      ) do
    match = get_match(tournament, payload.ref)

    if tournament.current_round == match.round and
         not in_break?(tournament) and
         not is_finished?(tournament) do
      new_tournament =
        tournament.module.finish_match(tournament, Map.put(payload, :game_id, match.game_id))

      # TODO: add match_finished_event pls, instead of full tournament update
      broadcast_tournament_update(new_tournament)
      {:noreply, %{tournament: new_tournament}}
    else
      {:noreply, %{tournament: tournament}}
    end
  end

  def handle_info(_message, state) do
    {:noreply, state}
  end

  def tournament_topic_name(tournament_id), do: "tournament:#{tournament_id}"

  defp broadcast_tournament_update(tournament) do
    Codebattle.PubSub.broadcast("tournament:updated", %{tournament: tournament})
  end

  def broadcast_tournament_event_by_type(:join, %{users: users}, tournament) do
    Enum.each(users, &broadcast_tournament_event_by_type(:join, %{user: &1}, tournament))
  end

  def broadcast_tournament_event_by_type(:join, params, tournament) do
    player = Tournament.Helpers.get_player(tournament, params.user.id)

    Codebattle.PubSub.broadcast("tournament:player:joined", %{
      tournament_id: tournament.id,
      player: player
    })
  end

  def broadcast_tournament_event_by_type(:leave, params, tournament) do
    Codebattle.PubSub.broadcast("tournament:player:left", %{
      tournament_id: tournament.id,
      player_id: params.user_id
    })
  end

  def broadcast_tournament_event_by_type(:start, _params, tournament) do
    Codebattle.PubSub.broadcast("tournament:started", %{tournament: tournament})
  end

  def broadcast_tournament_event_by_type(:stop_round_break, _params, _tournament) do
    :noop
  end

  def broadcast_tournament_event_by_type(_default_event, _params, _tournament) do
    # TODO: updated
  end

  defp server_name(id), do: {:via, Registry, {Codebattle.Registry, "tournament_srv::#{id}"}}
end
