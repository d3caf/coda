defmodule CodaWeb.AdminLive do
  use CodaWeb, :live_view

  alias Coda.Blog
  alias Ecto.Changeset

  @initial_state preview?: false, rendered_md: ""

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(changeset: Blog.change_post(%Blog.Post{})) |> assign(@initial_state)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-2 gap-6 items-start">
        <.form class="grid grid-cols-1 gap-6" let={f} for={@changeset} phx-change="change" phx-submit="save">
            <div>
            <%= label f, :title %>
            <%= text_input f, :title, class: "form-input block w-full mt-1" %>
            <%= error_tag f, :title %>
            </div>

            <div>
            <.editor form={f} />
            </div>

            <div>
            <%= submit "Save", disabled: not @changeset.valid?, class: "bg-violet-500 py-2 px-3 text-white text-sm font-semibold rounded-md shadow focus:outline-none disabled:bg-gray-300" %>
            </div>
        </.form>

        <.preview content={@rendered_md} />
    </div>
    """
  end

  defp editor(assigns) do
    ~H"""
        <div>
        <%= label @form, :content %>
        <%= textarea @form, :content, class: "form-input block w-full mt-1", rows: 25 %>
        </div>
    """
  end

  defp preview(%{content: content} = assigns) when content == "" do
    ~H"""
    <div class="bg-neutral-500/10 text-neutral-500 py-4 px-2">
        Write something...
    </div>
    """
  end

  defp preview(assigns) do
    ~H"""
        <div class="border-2 py-4 px-2 prose">
            <%= raw @content %>
        </div>
    """
  end

  defp preview_disabled?(assigns) do
    content = Changeset.fetch_field!(assigns.changeset, :content)
    assigns.preview? or is_nil(content) or String.length(content) < 1
  end

  @impl true
  def handle_event("change", %{"post" => params}, socket) do
    changeset = %Blog.Post{} |> Blog.change_post(params)

    {:noreply,
     socket |> assign(changeset: changeset, rendered_md: Earmark.as_html!(params["content"]))}
  end

  def handle_event("save", %{"post" => params}, %{assigns: assigns} = socket)
      when assigns.changeset.valid? do
    {:ok, _} = Blog.create_post(params)
    {:noreply, socket |> assign(changeset: Blog.change_post(%Blog.Post{}))}
  end

  def handle_event("handle_tab", %{"preview?" => "true"}, %{assigns: assigns} = socket) do
    {:ok, html, _} = Earmark.as_html(Changeset.fetch_field!(assigns.changeset, :content))

    {:noreply, socket |> assign(preview?: true, rendered_md: html)}
  end

  def handle_event("handle_tab", %{"preview?" => _}, socket),
    do: {:noreply, socket |> assign(preview?: false)}
end
