defmodule SNSUtils.DupTokenExtractor do

  @doc """
  The File needs JSON in SNS Endpoint Format
  """
  def execute(file_path) do
    {:ok, file} = File.open("dup_tokens.csv", [:write])

    case File.read(file_path) do
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
end
