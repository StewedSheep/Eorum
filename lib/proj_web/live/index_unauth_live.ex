defmodule ProjWeb.IndexUnAuthLive do
  use ProjWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  # defp get_user_from_session(session) do
  #   if user_token = session["user_token"] do
  #     Proj.Accounts.get_user_by_session_token(user_token)
  #   else
  #     nil
  #   end
  # end

  def render(assigns) do
    ~H"""
    <%!-- <div class="gap-0 h-16 inline-flex items-center relative select-none">
    <input id="down-radio" class="peer/down hidden" type="radio" name="vote" value="down">
    <input id="blank-radio" class="peer/blank hidden" type="radio" name="vote" value="blank" checked="checked">
    <input id="up-radio" class="peer/up hidden" type="radio" name="vote" value="up">

    <label class="peer/down-btn aspect-square cursor-pointer w-12 peer-checked/down:invisible" for="down-radio" style="background-image: url('https://cdn.hashnode.com/res/hashnode/image/upload/v1728932385888/51fc087e-ca44-4f12-869c-4e50409390b2.png');" aria-label="Downvote"></label>
    <label class="absolute aspect-square bg-no-repeat bg-cover cursor-pointer left-0 opacity-0 pointer-events-none w-12 transition-opacity peer-hover/down-btn:opacity-100 peer-checked/down:animate-vote-sprite peer-checked/down:pointer-events-auto peer-checked/down:opacity-100 peer-checked/down:hover:opacity-80" for="blank-radio" style="background-image: url('https://cdn.hashnode.com/res/hashnode/image/upload/v1728932412479/c91aef3d-6588-4883-b503-2db3b6594ba0.png');" aria-label="Remove downvote"></label>
    <div class="group flex items-center h-8 mx-1 overflow-hidden text-2xl">
        <div class="flex flex-col font-semibold items-center transition duration-700 translate-y-0 peer-checked/up:group-[]:-translate-y-8 peer-checked/down:group-[]:translate-y-8">
            <span class="text-red-700">-1</span>
            <span>0</span>
            <span class="text-green-800">1</span>
        </div>
    </div>
    <label class="peer/up-btn aspect-square cursor-pointer rotate-180 w-12 peer-checked/up:invisible" for="up-radio" style="background-image: url('https://cdn.hashnode.com/res/hashnode/image/upload/v1728932385888/51fc087e-ca44-4f12-869c-4e50409390b2.png');" aria-label="Upvote"></label>
    <label class="absolute aspect-square bg-no-repeat bg-cover cursor-pointer opacity-0 pointer-events-none right-0 w-12 transition-opacity peer-hover/up-btn:opacity-100 peer-checked/up:animate-vote-sprite peer-checked/up:pointer-events-auto peer-checked/up:opacity-100 peer-checked/up:hover:opacity-80" for="blank-radio" style="background-image: url('https://cdn.hashnode.com/res/hashnode/image/upload/v1728932423782/2e233a8b-db52-431f-9f1b-7458214ac960.png');" aria-label="Remove upvote"></label>
    </div> --%>
    """
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end
end
