# defmodule ProjWeb.ThreadCreate do
#   use ProjWeb, :live_view

#   alias Proj.Threads

#   def render(assigns) do
#     ~H"""
#     <div class="mx-auto max-w-sm">
#       <.header class="text-center">
#         <a class="font-semibold text-brand text-white">
#           New Thread
#         </a>
#       </.header>

#       <.simple_form
#         for={@form}
#         id="thread_form"
#         phx-submit="save"
#         phx-change="validate"
#         phx-trigger-action={@trigger_submit}
#         method="post"
#       >
#         <.error :if={@check_errors}>
#           Oops, something went wrong! Please check the errors below.
#         </.error>

#         <.input field={@form[:email]} type="email" label="Email" required />
#         <.input field={@form[:username]} type="text" label="Username" required />
#         <.input field={@form[:password]} type="password" label="Password" required />

#         <:actions>
#           <.button phx-disable-with="Creating post..." class="w-full">Post</.button>
#         </:actions>
#       </.simple_form>
#     </div>
#     """
#   end


# def mount(_params, _session, socket) do
#   changeset = Threads.list_threads()

#   socket =
#     socket
#     |> assign(trigger_submit: false, check_errors: false)
#     |> assign_form(changeset)

#   {:ok, socket, temporary_assigns: [form: nil]}
# end

# def handle_event("save", %{"thread" => thread_params}, socket) do
# end

# def handle_event("validate", %{"thread" => thread_params}, socket) do
# end

# defp assign_form(socket, %Ecto.Changeset{} = changeset) do
#   form = to_form(changeset, as: "thread")

#   if changeset.valid? do
#     assign(socket, form: form, check_errors: false)
#   else
#     assign(socket, form: form)
#   end
# end
# end
