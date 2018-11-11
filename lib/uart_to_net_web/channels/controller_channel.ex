defmodule UTWeb.ControllerChannel do
  use UTWeb, :channel

  def join("web:controller", _params, socket) do
    {:ok, %{}, socket}
  end

  def handle_in(event, %{"payload" => payload}, socket) do
    UT.Translator.send_to_uc(event, payload)
    {:reply, :ok, socket}
  end

  def handle_in(event, _params, socket) do
    UT.Translator.send_to_uc(event, << >>)
    {:reply, :ok, socket}
  end

end
