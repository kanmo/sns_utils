defmodule SNSUtils.EndpointToDeleteExtractor do

  def execute(correct_arn_file_path, dup_endpoints_file_path) do
    {:ok, file} = File.open("arn_to_delete_target.json", [:write])

    correct_arns =
      File.stream!(correct_arn_file_path)
      |> Stream.map(&(String.trim(&1)))
      |> Enum.to_list

    case File.read(dup_endpoints_file_path) do
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
