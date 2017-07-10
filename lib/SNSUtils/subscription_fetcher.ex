defmodule SnsUtils.SubscriptionFetcher do

  def execute(topic_arn) do
    {:ok, file} = File.open("subscriptions.json", [:write])
    subscriptions = fetch_subscriptions(2000, [], topic_arn)

    IO.binwrite(file, Poison.encode!(subscriptions))
    File.close(file)
  end

  def fetch_subscriptions(num, acc, topic_arn, next_token \\ [])
  def fetch_subscriptions(0, acc, _, _) do
    IO.puts "Try Finished!"
    acc
  end

  def fetch_subscriptions(num, acc, topic_arn, next_token) do
    case ExAws.SNS.list_subscriptions_by_topic(topic_arn, next_token) |> ExAws.request do
      {:ok, %{body: body}} ->
        next_token = body[:next_token]
        subscriptions = body[:subscriptions]

        case next_token do
          "" ->
            IO.puts "Next Token not exists. Try Finished!"
            acc ++ subscriptions

          _ ->
            fetch_subscriptions(num - 1, acc ++ subscriptions, topic_arn, [next_token: next_token])
        end

      _ ->
        IO.puts "SNS API Error Occurred"
    end
  end

end
