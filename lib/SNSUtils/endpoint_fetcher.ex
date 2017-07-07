defmodule SNSUtils.EndpointFetcher do

  def execute(platform_application_arn) do
    {:ok, file} = File.open("endpoints.json", [:write])
    # default setting, 2000 times execute(get 100 endpoints a one time.)
    endpoints =
      fetch_endpoints(2000, [], platform_application_arn)
      |> Enum.sort(&(String.to_integer(&1[:token], 16) <= String.to_integer(&2[:token], 16)))

    IO.binwrite(file, Poison.encode!(endpoints))
    File.close(file)
  end

  def fetch_endpoints(num, acc, platform_application_arn, next_token \\ [])
  def fetch_endpoints(0, acc, _, _) do
    IO.puts "Try Finished!"
    acc

  end

  def fetch_endpoints(num, acc, platform_application_arn, next_token) do
    case ExAws.SNS.list_endpoints_by_platform_application(platform_application_arn, next_token) |> ExAws.request do
      {:ok, %{body: body}} ->
        next_token = body[:next_token]
        endpoints = enabled_endpoints(body[:endpoints])

        case next_token do
          "" ->
            IO.puts "Next Token not exists. Try Finished!"
            acc ++ endpoints
          _ ->
            fetch_endpoints(num - 1, acc ++ endpoints, platform_application_arn, [next_token: next_token])
        end

      _ ->
        IO.puts "SNS API Error Occurred"
    end
  end

  def enabled_endpoints(endpoints) do
    Enum.filter(endpoints, fn e -> e[:enabled] == "true" end)
  end

end
