defmodule SNS.DupEndpointFilter do

  @doc """
  The File needs JSON in SNS Endpoint Format
  """
  def execute(file_path) do
    {:ok, file} = File.open("dup_endpoints.json", [:write])

    case File.read(file_path) do
      {:ok, body} ->
        dup_endpoints =
          Poison.decode!(body)
          |> filter_duplicate([])

        IO.binwrite(file, Poison.encode!(dup_endpoints))

      {:error, r} ->
        IO.puts "error"
    end

    File.close(file)
  end

  def filter_duplicate([], acc), do: acc
  def filter_duplicate([_|[]], acc), do: acc

  def filter_duplicate([head|tail], acc) do
    [next|_] = tail
    case head["token"] == next["token"] do
      true ->
        filter_duplicate(tail, [head|[next|acc]])
      _ ->
        filter_duplicate(tail, acc)
    end
  end

  def list_duplicate_endpoint_tokens do
    {:ok, file} = File.open("dup_tokens.csv", [:write])

    case File.read("dup_endpoints.json") do
      {:ok, body} ->
        Poison.decode!(body)
        |> select_dup_tokens([])
        |> Enum.each(&(IO.puts(file, &1)))

      _ ->
        IO.puts "error"
    end

    File.close(file)
  end

  def select_dup_tokens([], acc), do: acc
  def select_dup_tokens([_|[]], acc), do: acc

  def select_dup_tokens([head|tail], acc) do
    [next|_] = tail

    case head["token"] == next["token"] do
      true ->
        select_dup_tokens(tail, [head["token"]|acc])
      _ ->
        select_dup_tokens(tail, acc)
    end
  end

  def select_delete_target_arns do
    {:ok, file} = File.open("delete_target_arns.json", [:write])

    correct_arns =
      File.stream!("correct_arns.csv")
      |> Stream.map(&(String.trim(&1)))
      |> Enum.to_list

    case File.read("dup_endpoints.json") do
      {:ok, body} ->
        target_arns =
          Poison.decode!(body)
          |> filter_undelete_endpoints([], correct_arns)

        IO.binwrite(file, Poison.encode!(target_arns))

      _ ->
        IO.puts "error"
    end

    File.close(file)
  end

  def filter_undelete_endpoints([], acc, _), do: acc
  def filter_undelete_endpoints([_|[]], acc, _), do: acc

  def filter_undelete_endpoints([head|tail], acc, correct_arns) do
    case Enum.member?(correct_arns, head["endpoint_arn"]) do
      true ->
        filter_undelete_endpoints(tail, acc, correct_arns)
      _ ->
        filter_undelete_endpoints(tail, [head|acc], correct_arns)

    end
  end
end
