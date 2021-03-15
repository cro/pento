defmodule PentoWeb.WrongLive do
  use Phoenix.LiveView

  def mount(_params, session, socket) do
    right = Enum.random(1..11) |> to_string()

    {:ok,
     assign(socket,
       score: 0,
       message: "Guess a number.",
       right: right,
       status: "lose",
       user: Pento.Accounts.get_user_by_session_token(session["user_token"]),
       session_id: session["live_socket_id"]
     )}
  end

  def handle_event("guess", %{"number" => guess} = data, socket) do
    IO.inspect(data)

    {score, message, status} =
      cond do
        guess == socket.assigns.right ->
          win(guess, socket.assigns.score)

        true ->
          lose(guess, socket.assigns.score)
      end

    new_right =
      if guess == socket.assigns.right do
        Enum.random(1..11) |> to_string()
      else
        socket.assigns.right
      end

    {:noreply, assign(socket, message: message, score: score, right: new_right, status: status)}
  end

  def win(guess, score) do
    {score + 1, "Your guess was #{guess}, YOU WIN!", "win"}
  end

  def lose(guess, score) do
    {score - 1, "Your guess was #{guess}, Try again.", "lose"}
  end

  def render(assigns) do
    ~L"""
    <h1>Your score: <%= @score %></h1>
    <h2>
      <%= @message %>
    </h2>
    <h2>
      <%= for n <- 1..10 do %>
        <a href="#" phx-click="guess" phx-value-number="<%= n %>"><%= n %></a>
      <% end %>
      <%= if @status=="win" do %>
      <%= live_patch to: live_path(@socket, __MODULE__), replace: true do %>
        <button>Try again!</button>
        <% end %>
      <% end %>
    </h2>
    <pre>
      <%= @user.email %>
      <%= @session_id %>
    </pre>
    """
  end
end
