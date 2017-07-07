defmodule SNSUtils.EndpointDeleter do


  @doc """
  The File needs JSON in SNS Endpoint Format
  """
  def execute(file_path) do
    case File.read(file_path) do
      {:ok, body} ->
        Poison.decode!(body)
        |> Enum.map(&(&1["endpoint_arn"]))
        |> Enum.each(&(delete_endpoint_arn(&1)))

      _ ->
        IO.puts "error"
    end
  end

  def delete_endpoint_arn(endpoint_arn) do
    case ExAws.SNS.delete_endpoint(endpoint_arn) |> ExAws.request do
      {:ok, _} ->
        IO.puts "Delete Success: #{endpoint_arn}"

      _ ->
        IO.puts "Delete EndpointARN Failed. #{endpoint_arn}"
    end
  end
end
