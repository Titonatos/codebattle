defmodule Codebattle.Tournament.ArenaTest do
  use Codebattle.DataCase, async: false

  alias Codebattle.Tournament

  import Codebattle.Tournament.Helpers

  setup do
    insert(:task, level: "easy", name: "2")

    :ok
  end

  describe "complete players" do
    test "add bots to complete teams" do
      user1 = insert(:user)

      {:ok, tournament} =
        Tournament.Context.create(%{
          "starts_at" => "2022-02-24T06:00",
          "name" => "Test Swiss",
          "user_timezone" => "Etc/UTC",
          "level" => "easy",
          "creator" => user1,
          "break_duration_seconds" => 0,
          "type" => "arena",
          "state" => "waiting_participants",
          "use_clan" => "true",
          "players_limit" => 200
        })

      Tournament.Server.handle_event(tournament.id, :join, %{user: user1})
      Tournament.Server.handle_event(tournament.id, :start, %{user: user1})

      tournament = Tournament.Context.get(tournament.id)

      assert players_count(tournament) == 2

      assert [
               %{
                 duration_sec: nil,
                 finished_at: nil,
                 game_id: _,
                 id: 0,
                 level: "easy",
                 player_ids: [_, _],
                 player_results: %{},
                 round_id: _,
                 round_position: 0,
                 started_at: ~N[2019-01-05 19:11:45],
                 state: "playing",
                 winner_id: nil
               }
             ] = get_matches(tournament)
    end

    test "distributes uniformly into pairs with clans" do
      creator = insert(:user)
      users1 = insert_list(10, :user, %{clan_id: 1, clan: "1"})
      users2 = insert_list(20, :user, %{clan_id: 2, clan: "2"})
      users3 = insert_list(30, :user, %{clan_id: 3, clan: "3"})
      users4 = insert_list(40, :user, %{clan_id: 4, clan: "4"})

      {:ok, tournament} =
        Tournament.Context.create(%{
          "starts_at" => "2022-02-24T06:00",
          "name" => "Test Swiss",
          "user_timezone" => "Etc/UTC",
          "level" => "easy",
          "creator" => creator,
          "break_duration_seconds" => 0,
          "type" => "arena",
          "use_clan" => "true",
          "state" => "waiting_participants",
          "players_limit" => 200
        })

      Tournament.Server.handle_event(tournament.id, :join, %{users: users1})
      Tournament.Server.handle_event(tournament.id, :join, %{users: users2})
      Tournament.Server.handle_event(tournament.id, :join, %{users: users3})
      Tournament.Server.handle_event(tournament.id, :join, %{users: users4})
      Tournament.Server.handle_event(tournament.id, :start, %{user: creator})

      tournament = Tournament.Context.get(tournament.id)
      # matches = get_matches(tournament) |> Enum.count()

      assert players_count(tournament) == 100
    end
  end
end
