defmodule Mix.Tasks.Hex.User.Register do
  use Mix.Task
  alias Mix.Tasks.Hex.Util

  @shortdoc "Register a new hex user"

  @moduledoc """
  Registers a new hex user.

  `mix hex.user.register`
  """

  @switches [clean_pass: :boolean]

  def run(args) do
    { opts, _, _ } = OptionParser.parse(args, switches: @switches)
    clean? = Keyword.get(opts, :clean_pass, false)

    username = Mix.shell.prompt("Username:")  |> String.strip
    email    = Mix.shell.prompt("Email:")     |> String.strip
    password = Util.password_get("Password:", clean?) |> String.strip

    unless nil?(password) do
      confirm = Util.password_get("Password (confirm):", clean?) |> String.strip
      if password != confirm do
        Mix.raise "Entered passwords do not match"
      end
    end

    Mix.shell.info("Registering...")
    Hex.start_api
    create_user(username, email, password)
  end

  defp create_user(username, email, password) do
    case Hex.API.new_user(username, email, password) do
      { 201, _ } ->
        Util.generate_key(username, password)
      { code, body } ->
        Mix.shell.error("Registration of user #{username} failed (#{code})")
        Hex.Util.print_error_result(code, body)
    end
  end
end
